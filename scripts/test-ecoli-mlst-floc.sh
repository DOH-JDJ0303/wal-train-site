#!/usr/bin/env bash
# =============================================================================
#  Test run for the activity
#  "Catalogued Names vs. Agnostic Clusters: MLST and Floc"
#  (sections/classification-subtyping/ecoli-mlst-floc.md)
#
#  Runs every step of the activity in order, using the same commands learners
#  are given, then checks the results the activity relies on:
#
#    1. All three assemblies download from NCBI
#    2. MLST: every isolate has an ST
#    3. MLST: GCA_032856485.1 and GCA_058079015.1 share an ST
#    4. MLST: GCA_040936765.1 has a different ST from the other two
#    5. Floc: all three isolates are in the same cluster
#
#  It also writes expected_outputs.md, with text you can paste into the
#  activity's "Expected output" blocks.
#
#  Usage:
#    scripts/test-ecoli-mlst-floc.sh [options]
#
#  Options:
#    -w DIR        Working directory (default: ./ecoli-mlst-floc-test)
#    -e NAME       micromamba environment to use (default: typing)
#    -c            Create the micromamba environment if it does not exist,
#                  and install Floc into it if it is missing
#    -h            Show this help
#
#  Requirements: micromamba (or tools already on PATH), git, unzip, awk, join.
# =============================================================================
set -euo pipefail

ACCESSIONS=(GCA_032856485.1 GCA_040936765.1 GCA_058079015.1)
ODD_ONE="GCA_040936765.1"    # expected to have a different ST from the other two
SCHEME="ecoli_achtman_4"
FLOC_REPO="https://github.com/DOH-JDJ0303/floc"

WORKDIR="./ecoli-mlst-floc-test"
ENV_NAME="typing"
CREATE_ENV=0

usage() { sed -n '2,/^# ====/p' "$0" | sed 's/^# \{0,1\}//; /^====/d'; exit "${1:-0}"; }

while getopts "w:e:ch" opt; do
  case $opt in
    w) WORKDIR=$OPTARG ;;
    e) ENV_NAME=$OPTARG ;;
    c) CREATE_ENV=1 ;;
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

TOOLS=(datasets mlst)
missing_tools() { local t; for t in "${TOOLS[@]}"; do command -v "$t" > /dev/null || echo "$t"; done; }

# ---- 0. software -------------------------------------------------------------
step "Checking software"
for t in git unzip awk join; do command -v "$t" > /dev/null || die "'$t' is required but not installed."; done

if [ -n "$(missing_tools)" ] || ! command -v floc > /dev/null; then
  command -v micromamba > /dev/null || die "Missing tools and micromamba is not available."
  eval "$(micromamba shell hook --shell bash)"
  if ! micromamba env list --json | grep -q "/envs/$ENV_NAME\""; then
    [ "$CREATE_ENV" = 1 ] || die "micromamba environment '$ENV_NAME' not found. Rerun with -c to create it."
    info "Creating micromamba environment '$ENV_NAME' ..."
    micromamba create -y -n "$ENV_NAME" -c conda-forge -c bioconda python=3.11 ncbi-datasets-cli mlst
  fi
  micromamba activate "$ENV_NAME"
  [ -z "$(missing_tools)" ] || die "Still missing after activating '$ENV_NAME': $(missing_tools | tr '\n' ' ')"
fi

mkdir -p "$WORKDIR"
WORKDIR=$(cd "$WORKDIR" && pwd)
cd "$WORKDIR"
info "Working in $WORKDIR"

if ! command -v floc > /dev/null; then
  [ "$CREATE_ENV" = 1 ] || die "Floc is not installed. Rerun with -c to install it."
  info "Installing Floc into '$ENV_NAME' ..."
  [ -d floc ] || git clone --quiet "$FLOC_REPO"
  pip install -q "setuptools<70" wheel
  pip install -q --no-build-isolation floc/
fi
info "datasets $(datasets --version 2>&1 | awk '{print $NF}')"
info "$(mlst --version 2>&1)"
info "floc     $(floc --version 2>&1)"

# ---- 1. download assemblies ----------------------------------------------------
step "Downloading assemblies"
printf '%s\n' "${ACCESSIONS[@]}" > accessions.txt
rm -rf ncbi_dataset ecoli.zip assemblies
datasets download genome accession --inputfile accessions.txt \
  --include genome --filename ecoli.zip
unzip -o -q ecoli.zip
mkdir -p assemblies
for d in ncbi_dataset/data/GC*/; do
  acc=$(basename "$d")
  cp "$d"/*_genomic.fna assemblies/"$acc".fna
done
ls assemblies
for acc in "${ACCESSIONS[@]}"; do
  check "$acc downloaded" test -s assemblies/"$acc".fna
done

# ---- 2. MLST -------------------------------------------------------------------
step "MLST ($SCHEME)"
mlst --nopath --scheme "$SCHEME" assemblies/*.fna > mlst.tsv 2> mlst.log
cut -f 1,3 mlst.tsv | tee mlst_st.txt
echo
cut -f 1,3- mlst.tsv | tee mlst_alleles.txt
echo
mlst --nopath --full --scheme "$SCHEME" assemblies/*.fna 2> /dev/null | tee mlst_full.tsv

st_of() { awk -F '\t' -v f="$1.fna" '$1 == f { print $3 }' mlst.tsv; }
for acc in "${ACCESSIONS[@]}"; do
  st=$(st_of "$acc")
  check "MLST: $acc has an ST (got '${st:-none}')" bash -c "[[ '$st' =~ ^[0-9]+$ ]]"
done
ST_A=$(st_of GCA_032856485.1); ST_C=$(st_of GCA_058079015.1); ST_ODD=$(st_of "$ODD_ONE")
check "MLST: GCA_032856485.1 and GCA_058079015.1 share an ST (got $ST_A, $ST_C)" test "$ST_A" = "$ST_C"
check "MLST: $ODD_ONE has a different ST (got $ST_ODD vs $ST_A, $ST_C)" \
  bash -c "[ '$ST_ODD' != '$ST_A' ] && [ '$ST_ODD' != '$ST_C' ]"

# ---- 3. Floc -------------------------------------------------------------------
step "Floc"
rm -rf floc_db
floc assemblies -o floc_db > floc.log 2>&1 || die "Floc failed; see $WORKDIR/floc.log"
cat floc_db/clusters.csv | tee floc_clusters.txt
N_CLUSTERS=$(tail -n +2 floc_db/clusters.csv | cut -d, -f 2 | sort -u | wc -l | tr -d ' ')
N_SAMPLES=$(tail -n +2 floc_db/clusters.csv | wc -l | tr -d ' ')
check "Floc: all ${#ACCESSIONS[@]} isolates clustered (got $N_SAMPLES)" test "$N_SAMPLES" -eq "${#ACCESSIONS[@]}"
check "Floc: all isolates in one cluster (got $N_CLUSTERS clusters)" test "$N_CLUSTERS" -eq 1

# ---- 4. compare ----------------------------------------------------------------
step "STs vs. Floc clusters"
cut -f 1,3 mlst.tsv | sed 's/\.fna\t/\t/' | sort > st.tsv
tail -n +2 floc_db/clusters.csv | tr ',' '\t' | sort > floc.tsv
{ printf "sample\tST\tfloc\n"; join -t $'\t' st.tsv floc.tsv; } | tee compare.txt
echo
ls floc_db/sigs

# ---- expected outputs for the activity page ------------------------------------
{
  echo "# Expected outputs for ecoli-mlst-floc.md"
  echo
  echo "Generated $(date '+%Y-%m-%d %H:%M') by scripts/test-ecoli-mlst-floc.sh"
  echo
  echo "## Assign sequence types with MLST"
  echo; echo '```text'; cat mlst_st.txt; echo '```'; echo '{: .output}'; echo
  echo "## Compare the allele profiles"
  echo; echo '```text'; cat mlst_alleles.txt; echo '```'; echo '{: .output}'; echo
  echo "(For reference, mlst --full:)"
  echo; echo '```text'; cat mlst_full.tsv; echo '```'; echo
  echo "## Cluster the isolates with Floc"
  echo; echo '```text'; cat floc_clusters.txt; echo '```'; echo '{: .output}'; echo
  echo "## Compare STs with Floc clusters"
  echo; echo '```text'; cat compare.txt; echo '```'; echo '{: .output}'
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
