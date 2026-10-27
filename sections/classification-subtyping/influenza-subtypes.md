---
layout: activity
section: classification-subtyping
order: 5
title: "One Species, Many Subtypes: Influenza A"
nav_title: "Activity: Influenza A subtypes"
description: Compare two influenza A genomes with FastANI, classify their segments with CDC LABEL, and see how differences are concentrated in the HA and NA segments.
objectives:
  - Download influenza genomes from NCBI with the `datasets` command-line tool
  - Measure whole-genome and per-segment similarity with FastANI
  - Classify influenza segments and subtypes with CDC LABEL
  - Explain why the ~95% ANI species rule does not apply to influenza
prerequisites:
  - Completed the lecture [Subtyping Below the Species Level](../subtyping/)
  - "Completed [When Names and Genomes Disagree: E. coli and Shigella](../ecoli-shigella/), including the `species-id` micromamba environment"
  - "A Linux or macOS terminal with Perl installed (LABEL does not run natively on Windows; use WSL)"
---

<!-- TODO (instructor): replace FLU_1_ACCESSION and FLU_2_ACCESSION in the
     "Download the two genomes" step, then fill in the expected-output
     blocks marked TODO with the real results. -->

In the *E. coli* and *Shigella* activity, two bacteria with different names turned out to be nearly identical across the genome. In this activity you'll see the opposite: two viruses that belong to the **same species** — influenza A — but are far more different from each other than the ~95% ANI rule for bacteria would allow.

Influenza A genomes are made of **eight separate RNA segments**, each carrying one or two genes:

| Segment | Gene(s) | Role |
|---------|---------|------|
| PB2, PB1, PA | Polymerase subunits | Copy the viral genome |
| **HA** | Hemagglutinin | Surface protein; binds host cells; main target of antibodies |
| NP | Nucleoprotein | Packages the viral RNA |
| **NA** | Neuraminidase | Surface protein; releases new virus from cells |
| MP | Matrix proteins | Structure and assembly |
| NS | Non-structural proteins | Counter the host immune response |

Influenza A **subtypes** — H1N1, H3N2, H5N1, and so on — are named after the HA and NA segments.

## Set up the software

Activate the environment from the *E. coli* and *Shigella* activity. It already contains the NCBI `datasets` tool and FastANI:

```bash
micromamba activate species-id
mkdir -p ~/course/influenza && cd ~/course/influenza
```

<details class="hint" markdown="1">
<summary>Don't have the <code>species-id</code> environment?</summary>

Create a smaller one with just the tools needed here:

```bash
micromamba create -y -n species-id -c conda-forge -c bioconda ncbi-datasets-cli fastani
micromamba activate species-id
```
</details>

LABEL is distributed by CDC on GitHub, with the third-party programs it needs already bundled. Download it and check that it runs by listing its modules:

```bash
git clone https://github.com/CDCgov/label.git
label/LABEL -S
```

> On macOS, CDC recommends downloading LABEL from its [releases page](https://github.com/CDCgov/label/releases) instead of cloning. Docker users can run `docker run --rm -itv $(pwd):/data ghcr.io/cdcgov/label:latest LABEL` in place of `label/LABEL`.
{: .note}

## Download the two genomes

Download both influenza genomes from NCBI in one package:

```bash
datasets download genome accession FLU_1_ACCESSION FLU_2_ACCESSION \
  --include genome --filename flu.zip
unzip -o flu.zip
cp ncbi_dataset/data/FLU_1_ACCESSION/*_genomic.fna virus_1.fna
cp ncbi_dataset/data/FLU_2_ACCESSION/*_genomic.fna virus_2.fna
```

Each file should contain eight sequences — one per segment. Check:

```bash
grep -c ">" virus_1.fna virus_2.fna
```

```text
virus_1.fna:8
virus_2.fna:8
```
{: .output}

## Compare the whole genomes with FastANI

Run FastANI on the two complete genomes, the same way you compared *E. coli* and *Shigella*:

```bash
fastANI -q virus_1.fna -r virus_2.fna --fragLen 500 -o flu_genome_ani.txt
cat flu_genome_ani.txt
```

Note the `--fragLen 500` option. FastANI normally splits genomes into 3,000 bp fragments, but every influenza segment is shorter than that — the longest is about 2,300 bp — so with the default setting, no fragments would be compared at all.

<!-- TODO: paste the expected FastANI line here once accessions are set -->
```text
virus_1.fna    virus_2.fna    ...
```
{: .output}

Look at the last two columns as well as the ANI: how many of the fragments found a match at all?

> FastANI does not report a result when two genomes are much less than about 80% identical. If the output file is **empty**, that is the answer: the genomes are too different for FastANI to measure.
{: .important}

{% include question.html id="flu-genome-ani" %}

## Classify the segments with LABEL

LABEL identifies what each sequence is by scoring it against statistical models (profile hidden Markov models) of known influenza segments and subtypes. The `irma-FLU` module — the same one used by CDC's IRMA assembler — labels each sequence by virus type, segment, and, for HA and NA, subtype.

Run LABEL on each virus separately:

```bash
mkdir -p label_out
label/LABEL -O label_out virus_1.fna virus_1 irma-FLU
label/LABEL -O label_out virus_2.fna virus_2 irma-FLU
```

Each run prints a table of results and saves it as `label_out/<project>_final.txt`:

```bash
cat label_out/virus_1_final.txt label_out/virus_2_final.txt
```

<!-- TODO: paste the expected LABEL tables here once accessions are set -->
```text
                    VIRUS STRAIN                CLADE
   ...segment 1...                              A_PB2
   ...segment 4...                              A_HA_H?
   ...segment 6...                              A_NA_N?
   ...
```
{: .output}

Each segment is labeled `A_` (influenza A) followed by the segment name. HA and NA segments also carry their subtype — for example, `A_HA_H3` and `A_NA_N2` together mean the virus is H3N2.

{% include question.html id="flu-label-subtype" %}

## Split the genomes into segments

LABEL also saves each segment as a separate FASTA file, inside a zip archive. Extract them and give each one a simple name, such as `virus_1_HA.fa`:

```bash
mkdir -p segments
for v in virus_1 virus_2; do
  unzip -o -q label_out/$v.zip -d label_out/
  for f in label_out/$v/FASTA/${v}_clade_*.fas; do
    seg=$(basename "$f" .fas | sed "s/^${v}_clade_A_//; s/_.*//")
    cp "$f" segments/${v}_${seg}.fa
  done
done
ls segments
```

The `sed` command trims a file name like `virus_1_clade_A_HA_H3.fas` down to just the segment, `HA`.

> You should see **16 files**: PB2, PB1, PA, HA, NP, NA, MP, and NS for each virus. If any are missing, check the LABEL output for that segment before continuing.
{: .checkpoint}

## Compare each segment with FastANI

Now compare the two viruses one segment at a time, and collect the results in a table:

```bash
printf "segment\tANI\n" > segment_ani.tsv
for seg in PB2 PB1 PA HA NP NA MP NS; do
  fastANI -q segments/virus_1_${seg}.fa -r segments/virus_2_${seg}.fa \
    --fragLen 500 -o ani_${seg}.txt 2> /dev/null
  ani=$(cut -f 3 ani_${seg}.txt)
  printf "%s\t%s\n" "$seg" "${ani:-below ~80% (no result)}" >> segment_ani.tsv
done
cat segment_ani.tsv
```

When FastANI has no result for a segment, the table records `below ~80% (no result)`.

<!-- TODO: paste the expected per-segment table here once accessions are set -->
```text
segment   ANI
PB2       ...
PB1       ...
PA        ...
HA        below ~80% (no result)
NP        ...
NA        below ~80% (no result)
MP        ...
NS        ...
```
{: .output}

{% include question.html id="flu-segment-most-different" %}

## What this shows
{: .no-step}

**One species, very different genomes.** Both viruses are influenza A — a single species — yet their genomes are far below the ~95% identity that would make two bacteria the same species. Viral species are defined by different rules, so an identity threshold that works for bacteria does not carry over.

**The differences are concentrated in HA and NA.** These segments encode the two surface proteins, which are the main targets of the immune response and change rapidly to escape it. HA and NA genes from different subtypes are so different that FastANI cannot even measure them. The internal segments, which are under less of this pressure, are much more alike.

**Segments have their own histories.** Influenza viruses can swap whole segments when two viruses infect the same cell (reassortment). Each segment can therefore come from a different ancestor, and the similarity between two viruses can vary greatly from one segment to the next — as your table shows.

**This is why influenza is classified below the species level.** Because "influenza A" groups together such different viruses, the useful labels are the **subtype** (from HA and NA), and below that the **clade** and **genotype**. These are what LABEL and similar tools assign.

{% include question.html id="flu-why-ha-na" %}
