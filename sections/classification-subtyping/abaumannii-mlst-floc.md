---
layout: activity
section: classification-subtyping
order: 6
title: "Stable Names vs. Fine Resolution: MLST and Floc"
nav_title: "Activity: MLST vs. Floc"
description: Type a set of Acinetobacter baumannii genomes with MLST and cluster them with Floc, then compare how much detail each gives and how stable their names are.
objectives:
  - Download a set of genome assemblies from a list of accessions
  - Assign sequence types with `mlst`
  - Cluster genomes by k-mer distance with Floc, adding new genomes to an existing database
  - Compare the resolution and naming stability of MLST and k-mer clustering
prerequisites:
  - Completed the lecture [Subtyping Below the Species Level](../subtyping/)
  - A Linux, macOS, or WSL terminal with [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) installed
---

<!-- TODO (instructor): replace the placeholder accessions in the
     "Download the assemblies" step, then fill in the expected-output
     blocks marked TODO with the real results. -->

*Acinetobacter baumannii* is a major cause of healthcare-associated infections, and a few lineages — the "international clones" — account for most antibiotic-resistant cases worldwide. In this activity you'll describe the same set of *A. baumannii* genomes in two ways:

- **MLST**, which assigns each genome a **sequence type (ST)** from seven housekeeping genes, using names shared by laboratories worldwide.
- **Floc**, which groups genomes into **clusters** by comparing k-mers across the whole genome.

You'll see that the two approaches trade off **resolution** against **naming stability**.

## Set up the software

Create an environment with the NCBI `datasets` tool and `mlst`. Floc is installed from its source code into the same environment:

```bash
micromamba create -y -n typing -c conda-forge -c bioconda python=3.11 ncbi-datasets-cli mlst
micromamba activate typing

mkdir -p ~/course/abaumannii && cd ~/course/abaumannii
git clone https://github.com/DOH-JDJ0303/floc
pip install "setuptools<70" wheel
pip install --no-build-isolation floc/
```

Check that each tool runs:

```bash
datasets --version
mlst --version
floc --version
```

<details class="hint" markdown="1">
<summary>Prefer Docker for Floc?</summary>

Floc is also available as a container. Replace `floc` in the commands below with:

```bash
docker run --rm -v "$PWD":/work -w /work public.ecr.aws/o8h2f0o1/floc:1.1 floc
```
</details>

## Download the assemblies

Save the list of accessions to a file, one per line:

```bash
cat > accessions.txt << 'EOF'
ACCESSION_01
ACCESSION_02
ACCESSION_03
EOF
```

Download all of them in one package with `--inputfile`, then copy each assembly to a file named after its accession:

```bash
datasets download genome accession --inputfile accessions.txt \
  --include genome --filename abaumannii.zip
unzip -o -q abaumannii.zip

mkdir -p assemblies
for d in ncbi_dataset/data/GC*/; do
  acc=$(basename "$d")
  cp "$d"/*_genomic.fna assemblies/"$acc".fna
done
ls assemblies | wc -l
```

> The number printed should match the number of lines in `accessions.txt`.
{: .checkpoint}

## Assign sequence types with MLST

*A. baumannii* has two MLST schemes, named after the institutes that developed them: **Oxford** and **Pasteur**. The Pasteur scheme is the one most often used to name the international clones — for example, Pasteur ST2 corresponds to International Clone 2 (IC2). In `mlst`, the Pasteur scheme is called `abaumannii_2`.

Type every assembly with the Pasteur scheme. `--nopath` keeps the output tidy by dropping the folder name:

```bash
mlst --nopath --scheme abaumannii_2 assemblies/*.fna > mlst.tsv
cut -f 1,3 mlst.tsv
```

Each line shows the file name and its ST. Now count how many genomes belong to each ST:

```bash
cut -f 3 mlst.tsv | sort | uniq -c | sort -rn
```

<!-- TODO: paste the expected ST counts here once accessions are set -->
```text
     ... 2
     ... ...
```
{: .output}

> A `-` in place of an ST means `mlst` found the alleles but they don't match a known ST, or an allele was missing. Run `mlst --full` to see a status for each genome.
{: .tip}

{% include question.html id="abaum-st-count" %}

## Cluster the first batch with Floc

In routine surveillance, genomes don't arrive all at once — they arrive over weeks and months. To mimic this, split the assemblies into two batches:

```bash
mkdir -p batch1 batch2
n=$(ls assemblies/*.fna | wc -l)
ls assemblies/*.fna | head -n $((n / 2)) | xargs -I{} cp {} batch1/
ls assemblies/*.fna | tail -n +$((n / 2 + 1)) | xargs -I{} cp {} batch2/
```

Cluster the first batch. Floc sketches each genome with sourmash, compares the sketches, and groups genomes that are within a distance of 0.03 of one another (the default):

```bash
floc batch1 -o floc_db
cat floc_db/clusters.csv
```

`clusters.csv` lists each sample (`sid`) and its cluster number. Floc also saves a k-mer sketch (a *signature*) for every genome in `floc_db/sigs/`. These signatures, with their cluster numbers, are the Floc database.

## Add the second batch

Now the second batch "arrives". Give Floc the new assemblies **and** the existing signatures, writing back to the same database:

```bash
floc batch2 floc_db/sigs -o floc_db
cat floc_db/clusters.csv
```

New genomes are added to an existing cluster when they fall within the threshold, or start a new cluster when they don't. Genomes from the first batch keep the cluster numbers they already had.

## Compare STs with Floc clusters

Put each genome's ST and Floc cluster side by side. The `join` command matches rows from two files by sample name:

```bash
cut -f 1,3 mlst.tsv | sed 's/\.fna\t/\t/' | sort > st.tsv
tail -n +2 floc_db/clusters.csv | tr ',' '\t' | sort > floc.tsv

printf "sample\tST\tfloc\n"
join -t $'\t' st.tsv floc.tsv | sort -t $'\t' -k2,2n -k3,3n
```

Then count how many Floc clusters there are within each ST:

```bash
join -t $'\t' st.tsv floc.tsv | cut -f 2,3 | sort -u | cut -f 1 | sort | uniq -c
```

The first column is the number of Floc clusters; the second is the ST.

<!-- TODO: paste the expected joined table here once accessions are set -->
```text
sample    ST    floc
...
```
{: .output}

{% include question.html id="abaum-resolution" %}

## Simulate a second laboratory

MLST sequence types are assigned against a single, curated, worldwide database, so ST2 means the same thing in every laboratory. Floc cluster numbers are assigned in the order clusters are discovered in *your* database.

To see what that means, imagine a second laboratory that received exactly the same genomes, but in the opposite order — batch 2 first, then batch 1:

```bash
floc batch2 -o floc_lab2
floc batch1 floc_lab2/sigs -o floc_lab2

tail -n +2 floc_lab2/clusters.csv | tr ',' '\t' | sort > floc_lab2.tsv
printf "sample\tST\tlab1\tlab2\n"
join -t $'\t' st.tsv floc.tsv | join -t $'\t' - floc_lab2.tsv | sort -t $'\t' -k3,3n
```

<!-- TODO: paste the expected comparison table here once accessions are set -->
```text
sample    ST    lab1    lab2
...
```
{: .output}

{% include question.html id="abaum-stability" %}

## What this shows
{: .no-step}

**MLST is coarse but stable.** Seven housekeeping genes change slowly, so many genomes share the same ST — even genomes that differ substantially across the rest of the genome. A dominant clone such as ST2 can contain a great deal of diversity. In exchange, the names are fixed and global: an ST is defined once in a curated database, and every laboratory assigns the same ST to the same genome, today and in the future.

**Floc is finer but its names are local.** Comparing k-mers across the whole genome splits large STs into smaller groups of more closely related genomes. But cluster numbers depend on the history of the database — which genomes it has seen, and in what order. Two laboratories can find exactly the same groups and still give them different numbers.

**Keep the database to keep the names.** Because Floc adds new genomes to existing clusters, the numbers stay stable for as long as you keep adding to the same signatures. Rebuilding from scratch, or starting a new database, can renumber everything. Cluster names are reliable within one program's ongoing surveillance, but should not be compared between programs unless they share the database.

**Use both.** In practice, they answer different questions:

| | MLST | Floc |
|---|---|---|
| Based on | 7 housekeeping genes | k-mers across the whole genome |
| Resolution | Coarse | Finer (set by the distance threshold) |
| Names | Global, curated, permanent | Local to one database |
| Best for | Communicating with other laboratories; linking to published knowledge | Grouping genomes within ongoing surveillance before SNP or cgMLST analysis |

Report the ST so partners know what you're talking about, and use the cluster to decide which genomes to compare at higher resolution.
