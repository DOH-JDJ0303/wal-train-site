#!/usr/bin/env bash
# =============================================================================
#  Test run for the activity
#  "When Names and Genomes Disagree: E. coli and Shigella"
#  (sections/classification-subtyping/ecoli-shigella.md)
#
#  Runs every step of the activity in order, using the same commands learners
#  are given, then checks the results the activity relies on:
#
#    1. Both assemblies download from NCBI
#    2. FastANI: the two isolates share >= 95% ANI
#    3. GAMBIT: isolate A is Escherichia coli; isolate B is Shigella
#    4. ShigaPass: isolate A is ipaH- / "Not Shigella/EIEC"
#    5. ShigaPass: isolate B is ipaH+ with a Shigella serotype
#
#  It also writes expected_outputs.md, with text you can paste into the
#  activity's "Expected output" blocks.
#
#  Usage:
#    scripts/test-ecoli-shigella.sh [options]
#
#  Options:
#    -w DIR        Working directory (default: ./ecoli-shigella-test)
#    -g DIR        Folder holding (or to download) the GAMBIT database files;
#                  reused between runs. Can also be set with the
#                  GAMBIT_DB_PATH environment variable. (default: <workdir>/db)
#    -e NAME       micromamba environment to use (default: species-id)
#    -c            Create the micromamba environment if it does not exist,
#                  or add missing tools to it
#    -t N          Threads for ShigaPass (default: 4)
#    -h            Show this help
#
#  Requirements: micromamba (or tools already on PATH), git, curl, unzip, awk.
# =============================================================================
set -euo pipefail

GENOME_A="GCA_052160995.1"   # reported as S. flexneri; actually E. coli
GENOME_B="GCA_055444035.1"   # S. flexneri
ANI_MIN=95
GAMBIT_DB_URL="https://storage.googleapis.com/jlumpe-gambit/public/databases/refseq-curated/1.0"
GAMBIT_DB_FILES=(gambit-refseq-curated-1.0.gdb gambit-refseq-curated-1.0.gs)
SHIGAPASS_REPO="https://github.com/imanyass/ShigaPass.git"

WORKDIR="./ecoli-shigella-test"
DBDIR="${GAMBIT_DB_PATH:-}"
ENV_NAME="species-id"
CREATE_ENV=0
THREADS=4

usage() { sed -n '2,/^# ====/p' "$0" | sed 's/^# \{0,1\}//; /^====/d'; exit "${1:-0}"; }

while getopts "w:g:e:ct:h" opt; do
  case $opt in
    w) WORKDIR=$OPTARG ;;
    g) DBDIR=$OPTARG ;;
    e) ENV_NAME=$OPTARG ;;
    c) CREATE_ENV=1 ;;
    t) THREADS=$OPTARG ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done
START_DIR=$(pwd)

# ---- helpers -----------------------------------------------------------------
step()  { printf '\n\033[1;33m== %s\033[0m\n' "$*"; }
info()  { printf '   %s\n' "$*"; }
die()   { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

PASSES=0; FAILS=0; RESULTS=()
check() {  # check "description" <command...>
  local desc=$1; shift
  if "$@" > /dev/null 2>&1; then
    RESULTS+=("PASS  $desc"); PASSES=$((PASSES + 1))
  else
    RESULTS+=("FAIL  $desc"); FAILS=$((FAILS + 1))
  fi
}

TOOLS=(datasets gambit fastANI blastn makeblastdb python3)
PACKAGES="ncbi-datasets-cli fastani gambit blast"
missing_tools() { local t; for t in "${TOOLS[@]}"; do command -v "$t" > /dev/null || echo "$t"; done; }

# ---- 0. software -------------------------------------------------------------
step "Checking software"
for t in git curl unzip awk; do command -v "$t" > /dev/null || die "'$t' is required but not installed."; done

if [ -n "$(missing_tools)" ]; then
  command -v micromamba > /dev/null || die "Missing tools: $(missing_tools | tr '\n' ' ')and micromamba is not available."
  eval "$(micromamba shell hook --shell bash)"
  if ! micromamba env list --json | grep -q "/envs/$ENV_NAME\""; then
    [ "$CREATE_ENV" = 1 ] || die "micromamba environment '$ENV_NAME' not found. Rerun with -c to create it."
    info "Creating micromamba environment '$ENV_NAME' ..."
    micromamba create -y -n "$ENV_NAME" -c conda-forge -c bioconda $PACKAGES
  fi
  micromamba activate "$ENV_NAME"
  if [ -n "$(missing_tools)" ] && [ "$CREATE_ENV" = 1 ]; then
    info "Adding missing tools to '$ENV_NAME' ..."
    micromamba install -y -n "$ENV_NAME" -c conda-forge -c bioconda $PACKAGES
  fi
  [ -z "$(missing_tools)" ] || die "Still missing after activating '$ENV_NAME': $(missing_tools | tr '\n' ' ')(rerun with -c to install them)"
fi
info "datasets $(datasets --version 2>&1 | awk '{print $NF}')"
info "gambit   $(gambit --version 2>&1 | head -n 1)"
info "fastANI  $(fastANI --version 2>&1 | head -n 1)"

mkdir -p "$WORKDIR"
WORKDIR=$(cd "$WORKDIR" && pwd)
DBDIR=${DBDIR:-$WORKDIR/db}
case $DBDIR in /*) ;; *) DBDIR="$START_DIR/$DBDIR" ;; esac
mkdir -p "$DBDIR"
DBDIR=$(cd "$DBDIR" && pwd)
cd "$WORKDIR"
info "Working in $WORKDIR"

if [ ! -d ShigaPass ]; then
  git clone --quiet "$SHIGAPASS_REPO"
fi
chmod +x ShigaPass/SCRIPT/ShigaPass.sh
info "$(ShigaPass/SCRIPT/ShigaPass.sh -v 2>&1 | grep -i version | head -n 1)"

# ---- 1. GAMBIT database -------------------------------------------------------
step "GAMBIT database"
for f in "${GAMBIT_DB_FILES[@]}"; do
  if [ -s "$DBDIR/$f" ]; then
    info "$f already installed in $DBDIR (skipping download)"
  else
    info "Downloading $f (large file; resumes if interrupted) ..."
    curl -L -C - -o "$DBDIR/$f" "$GAMBIT_DB_URL/$f"
  fi
done

# ---- 2. download assemblies ----------------------------------------------------
step "Downloading assemblies $GENOME_A and $GENOME_B"
rm -rf ncbi_dataset genomes.zip
datasets download genome accession "$GENOME_A" "$GENOME_B" \
  --include genome --filename genomes.zip
unzip -o -q genomes.zip
cp ncbi_dataset/data/"$GENOME_A"/*_genomic.fna isolate_A.fna
cp ncbi_dataset/data/"$GENOME_B"/*_genomic.fna isolate_B.fna
ls -lh isolate_*.fna
check "isolate_A.fna downloaded ($GENOME_A)" test -s isolate_A.fna
check "isolate_B.fna downloaded ($GENOME_B)" test -s isolate_B.fna

# ---- 3. FastANI ----------------------------------------------------------------
step "FastANI"
fastANI -q isolate_A.fna -r isolate_B.fna -o isolates_ani.txt > fastani.log 2>&1
cat isolates_ani.txt
ANI=$(cut -f 3 isolates_ani.txt | head -n 1)
check "FastANI: ANI >= $ANI_MIN (got ${ANI:-no result})" \
  awk -v a="${ANI:-0}" -v m="$ANI_MIN" 'BEGIN { exit !(a >= m) }'

# ---- 4. GAMBIT -----------------------------------------------------------------
step "GAMBIT"
gambit -d "$DBDIR" query -o gambit.csv isolate_A.fna isolate_B.fna
# Print the key columns; descriptions can contain commas, so parse as CSV
python3 - gambit.csv > gambit_short.txt << 'PY'
import csv, sys
rows = list(csv.DictReader(open(sys.argv[1])))
cols = ["query", "predicted.name", "predicted.rank"]
print("\t".join(cols))
for r in rows:
    print("\t".join(r.get(c, "") for c in cols))
PY
cat gambit_short.txt
gambit_pred() {  # gambit_pred <row number, 1 = isolate A>
  awk -F '\t' -v n="$1" 'NR == n + 1 { print $2 }' gambit_short.txt
}
PRED_A=$(gambit_pred 1)
PRED_B=$(gambit_pred 2)
check "GAMBIT: isolate A is Escherichia coli (got '${PRED_A:-none}')" grep -qi "escherichia coli" <<< "$PRED_A"
check "GAMBIT: isolate B is Shigella (got '${PRED_B:-none}')" grep -qi "shigella" <<< "$PRED_B"

# ---- 5. ShigaPass --------------------------------------------------------------
step "ShigaPass"
readlink -f isolate_A.fna isolate_B.fna > shigapass_list.txt
SP_UPDATE=""
ls ShigaPass/SCRIPT/ShigaPass_DataBases/IPAH/*.nin > /dev/null 2>&1 || SP_UPDATE="-u"
ShigaPass/SCRIPT/ShigaPass.sh -l shigapass_list.txt -o shigapass_results \
  -p ShigaPass/SCRIPT/ShigaPass_DataBases -t "$THREADS" $SP_UPDATE > shigapass.log 2>&1 ||
  info "ShigaPass exited with a non-zero status; see $WORKDIR/shigapass.log"
SUMMARY=shigapass_results/ShigaPass_summary.csv
[ -s "$SUMMARY" ] || die "ShigaPass did not produce $SUMMARY (see shigapass.log)"
cut -d ';' -f 1,7,8,9 "$SUMMARY" | tee shigapass_short.txt

sp_field() { awk -F ';' -v n="$1" -v f="$2" '$1 == n { print $f }' "$SUMMARY"; }
check "ShigaPass: isolate A is ipaH-"                      test "$(sp_field isolate_A 7)" = "ipaH-"
check "ShigaPass: isolate A is 'Not Shigella/EIEC'"        test "$(sp_field isolate_A 8)" = "Not Shigella/EIEC"
check "ShigaPass: isolate B is ipaH+"                      test "$(sp_field isolate_B 7)" = "ipaH+"
SERO_B=$(sp_field isolate_B 8)
check "ShigaPass: isolate B has a Shigella serotype (got '${SERO_B:-none}')" \
  bash -c "[[ '$SERO_B' =~ ^S[BDFS] ]]"

# ---- expected outputs for the activity page ------------------------------------
{
  echo "# Expected outputs for ecoli-shigella.md"
  echo
  echo "Generated $(date '+%Y-%m-%d %H:%M') by scripts/test-ecoli-shigella.sh"
  echo
  echo "## Compare the two isolates with FastANI"
  echo; echo '```text'; cat isolates_ani.txt; echo '```'; echo '{: .output}'; echo
  echo "## Identify each isolate with GAMBIT"
  echo; echo '```text'; tr '\t' ',' < gambit_short.txt; echo '```'; echo '{: .output}'; echo
  echo "## Confirm with ShigaPass"
  echo; echo '```text'; cat shigapass_short.txt; echo '```'; echo '{: .output}'
} > expected_outputs.md

# ---- summary -------------------------------------------------------------------
step "Summary"
for r in "${RESULTS[@]}"; do
  case $r in PASS*) printf '   \033[32m%s\033[0m\n' "$r" ;; *) printf '   \033[31m%s\033[0m\n' "$r" ;; esac
done

echo
info "$PASSES passed, $FAILS failed"
info "Expected-output blocks written to $WORKDIR/expected_outputs.md"
[ "$FAILS" -eq 0 ]
