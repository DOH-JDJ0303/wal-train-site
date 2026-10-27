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
#    2. Mash: the closest RefSeq genome to genome A is labeled Shigella flexneri
#    3. ShigaPass: genome A is ipaH- / "Not Shigella/EIEC"
#    4. ShigaPass: genome B is ipaH+ with a Shigella serotype
#    5. FastANI: the two genomes share >= 95% ANI
#
#  It also writes expected_outputs.md, with text you can paste into the
#  activity's "Expected output" blocks.
#
#  Usage:
#    scripts/test-ecoli-shigella.sh [options]
#
#  Options:
#    -w DIR        Working directory (default: ./ecoli-shigella-test)
#    -d DIR        Folder for the Mash RefSeq sketch; reused between runs
#                  (default: <workdir>/db)
#    -e NAME       micromamba environment to use (default: species-id)
#    -c            Create the micromamba environment if it does not exist
#    -t N          Threads for ShigaPass (default: 4)
#    -h            Show this help
#
#  Requirements: micromamba (or tools already on PATH), git, curl, unzip, awk.
# =============================================================================
set -euo pipefail

GENOME_A="GCA_052160995.1"   # E. coli; closest RefSeq genome labeled S. flexneri
GENOME_B="GCA_055444035.1"   # Shigella
ANI_MIN=95
MASH_URL="https://gembox.cbcb.umd.edu/mash/refseq.genomes.k21s1000.msh"
SHIGAPASS_REPO="https://github.com/imanyass/ShigaPass.git"

WORKDIR="./ecoli-shigella-test"
DBDIR=""
ENV_NAME="species-id"
CREATE_ENV=0
THREADS=4

usage() { sed -n '2,/^# ====/p' "$0" | sed 's/^# \{0,1\}//; /^====/d'; exit "${1:-0}"; }

while getopts "w:d:e:ct:h" opt; do
  case $opt in
    w) WORKDIR=$OPTARG ;;
    d) DBDIR=$OPTARG ;;
    e) ENV_NAME=$OPTARG ;;
    c) CREATE_ENV=1 ;;
    t) THREADS=$OPTARG ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done

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

TOOLS=(datasets mash fastANI blastn makeblastdb)
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
    micromamba create -y -n "$ENV_NAME" -c conda-forge -c bioconda ncbi-datasets-cli mash fastani blast
  fi
  micromamba activate "$ENV_NAME"
  [ -z "$(missing_tools)" ] || die "Still missing after activating '$ENV_NAME': $(missing_tools | tr '\n' ' ')"
fi
info "datasets $(datasets --version 2>&1 | awk '{print $NF}')"
info "mash     $(mash --version 2>&1)"
info "fastANI  $(fastANI --version 2>&1 | head -n 1)"

mkdir -p "$WORKDIR"
WORKDIR=$(cd "$WORKDIR" && pwd)
DBDIR=${DBDIR:-$WORKDIR/db}
mkdir -p "$DBDIR"
DBDIR=$(cd "$DBDIR" && pwd)
cd "$WORKDIR"
info "Working in $WORKDIR"

if [ ! -d ShigaPass ]; then
  git clone --quiet "$SHIGAPASS_REPO"
fi
chmod +x ShigaPass/SCRIPT/ShigaPass.sh
info "$(ShigaPass/SCRIPT/ShigaPass.sh -v 2>&1 | grep -i version | head -n 1)"

# ---- 1. Mash reference database ------------------------------------------------
step "Mash RefSeq sketch"
MSH="$DBDIR/refseq.genomes.k21s1000.msh"
if [ -s "$MSH" ] && mash info -H "$MSH" > /dev/null 2>&1; then
  info "Using existing $MSH"
else
  info "Downloading (large file; resumes if interrupted) ..."
  curl -L -C - -o "$MSH" "$MASH_URL"
fi
if [ ! -s "$DBDIR/refseq.info.tsv" ]; then
  mash info -t "$MSH" > "$DBDIR/refseq.info.tsv"
fi

# ---- 2. download assemblies ----------------------------------------------------
step "Downloading assemblies $GENOME_A and $GENOME_B"
rm -rf ncbi_dataset genomes.zip
datasets download genome accession "$GENOME_A" "$GENOME_B" \
  --include genome --filename genomes.zip
unzip -o -q genomes.zip
cp ncbi_dataset/data/"$GENOME_A"/*_genomic.fna genome_A.fna
cp ncbi_dataset/data/"$GENOME_B"/*_genomic.fna genome_B.fna
ls -lh genome_*.fna
check "genome_A.fna downloaded ($GENOME_A)" test -s genome_A.fna
check "genome_B.fna downloaded ($GENOME_B)" test -s genome_B.fna

# ---- 3. Mash -------------------------------------------------------------------
step "Mash: closest RefSeq genomes"
for g in genome_A genome_B; do
  mash dist "$MSH" $g.fna | sort -gk3 > $g.mash.tsv
done
: > mash_top5.txt
for g in genome_A genome_B; do
  echo "== $g" | tee -a mash_top5.txt
  head -n 5 $g.mash.tsv |
    awk -F '\t' 'NR == FNR { desc[$3] = $4; next } { print $3 "\t" desc[$1] }' \
      "$DBDIR/refseq.info.tsv" - | tee -a mash_top5.txt
done
TOP_A=$(head -n 1 genome_A.mash.tsv |
  awk -F '\t' 'NR == FNR { desc[$3] = $4; next } { print desc[$1] }' "$DBDIR/refseq.info.tsv" -)
check "Mash top hit for genome A is labeled Shigella flexneri" grep -qi "shigella flexneri" <<< "$TOP_A"

# ---- 4. ShigaPass --------------------------------------------------------------
step "ShigaPass"
readlink -f genome_A.fna genome_B.fna > shigapass_list.txt
SP_UPDATE=""
ls ShigaPass/SCRIPT/ShigaPass_DataBases/IPAH/*.nin > /dev/null 2>&1 || SP_UPDATE="-u"
ShigaPass/SCRIPT/ShigaPass.sh -l shigapass_list.txt -o shigapass_results \
  -p ShigaPass/SCRIPT/ShigaPass_DataBases -t "$THREADS" $SP_UPDATE > shigapass.log 2>&1 ||
  info "ShigaPass exited with a non-zero status; see $WORKDIR/shigapass.log"
SUMMARY=shigapass_results/ShigaPass_summary.csv
[ -s "$SUMMARY" ] || die "ShigaPass did not produce $SUMMARY (see shigapass.log)"
cut -d ';' -f 1,7,8,9 "$SUMMARY" | tee shigapass_short.txt

sp_field() { awk -F ';' -v n="$1" -v f="$2" '$1 == n { print $f }' "$SUMMARY"; }
check "ShigaPass: genome A is ipaH-"                      test "$(sp_field genome_A 7)" = "ipaH-"
check "ShigaPass: genome A is 'Not Shigella/EIEC'"        test "$(sp_field genome_A 8)" = "Not Shigella/EIEC"
check "ShigaPass: genome B is ipaH+"                      test "$(sp_field genome_B 7)" = "ipaH+"
SERO_B=$(sp_field genome_B 8)
check "ShigaPass: genome B has a Shigella serotype (got '${SERO_B:-none}')" \
  bash -c "[[ '$SERO_B' =~ ^S[BDFS] ]]"

# ---- 5. FastANI ----------------------------------------------------------------
step "FastANI"
fastANI -q genome_A.fna -r genome_B.fna -o ecoli_shigella_ani.txt > fastani.log 2>&1
cat ecoli_shigella_ani.txt
ANI=$(cut -f 3 ecoli_shigella_ani.txt | head -n 1)
check "FastANI: ANI >= $ANI_MIN (got ${ANI:-no result})" \
  awk -v a="${ANI:-0}" -v m="$ANI_MIN" 'BEGIN { exit !(a >= m) }'

# ---- expected outputs for the activity page ------------------------------------
{
  echo "# Expected outputs for ecoli-shigella.md"
  echo
  echo "Generated $(date '+%Y-%m-%d %H:%M') by scripts/test-ecoli-shigella.sh"
  echo
  echo "## Identify the species with Mash"
  echo; echo '```text'; cat mash_top5.txt; echo '```'; echo '{: .output}'; echo
  echo "## Identify the species with ShigaPass"
  echo; echo '```text'; cat shigapass_short.txt; echo '```'; echo '{: .output}'; echo
  echo "## Measure how similar the genomes really are"
  echo; echo '```text'; cat ecoli_shigella_ani.txt; echo '```'; echo '{: .output}'
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
