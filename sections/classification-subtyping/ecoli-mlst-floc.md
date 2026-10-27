---
layout: activity
section: classification-subtyping
order: 6
title: "Cataloged Names vs. Agnostic Clusters: MLST and Floc"
nav_title: "Activity: MLST vs. Floc"
description: Type three closely related E. coli isolates with MLST and cluster them with Floc, and see how a sequence type boundary can split isolates that should be compared.
objectives:
  - Download a set of genome assemblies from a list of accessions
  - Assign sequence types with `mlst` and compare allele profiles
  - Cluster genomes by k-mer distance with Floc
  - Compare a curated naming scheme with an agnostic, k-mer-based approach
prerequisites:
  - Completed the lecture [Subtyping Below the Species Level](../subtyping/)
  - A Linux, macOS, or WSL terminal with [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) installed
---

<!-- TODO (instructor): fill in the expected-output blocks marked TODO. -->

Subtyping is often used as a first grouping step: isolates that share a type are compared in more detail, and isolates that don't are set aside. In this activity you'll see what happens when that first step gives the wrong answer.

You have three *Escherichia coli* isolates from the [NCBI Pathogen Detection](https://www.ncbi.nlm.nih.gov/pathogens/) project. NCBI's genome-wide comparison shows that they are very closely related, only 10 to 18 single-nucleotide polymorphisms (SNPs) apart:

| SNP differences | GCA_032856485.1 | GCA_040936765.1 | GCA_058079015.1 |
|-----------------|:---------------:|:---------------:|:---------------:|
| GCA_032856485.1 | 0 | 12 | 10 |
| GCA_040936765.1 | 12 | 0 | 18 |
| GCA_058079015.1 | 10 | 18 | 0 |

Isolates this close together are the kind you would want to investigate as a possible cluster. You'll describe them in two ways:

- **MLST**, which assigns each isolate a **sequence type (ST)** from seven housekeeping genes. ST numbers come from a curated, worldwide catalog, so the same ST means the same thing in every laboratory.
- **Floc**, which groups isolates into **clusters** by comparing k-mers across the whole genome. No catalog is involved: clusters are created directly from the data.

## Set up the software

Create an environment with the NCBI `datasets` tool and `mlst`. Floc is installed from its source code into the same environment:

```bash
micromamba create -y -n typing -c conda-forge -c bioconda python=3.11 ncbi-datasets-cli mlst
micromamba activate typing

mkdir -p ~/course/ecoli-typing && cd ~/course/ecoli-typing
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

Save the three accessions to a file, one per line:

```bash
cat > accessions.txt << 'EOF'
GCA_032856485.1
GCA_040936765.1
GCA_058079015.1
EOF
```

Download all of them in one package with `--inputfile`, then copy each assembly to a file named after its accession:

```bash
datasets download genome accession --inputfile accessions.txt \
  --include genome --filename ecoli.zip
unzip -o -q ecoli.zip

mkdir -p assemblies
for d in ncbi_dataset/data/GC*/; do
  acc=$(basename "$d")
  cp "$d"/*_genomic.fna assemblies/"$acc".fna
done
ls assemblies
```

> You should see three `.fna` files, one for each accession.
{: .checkpoint}

## Assign sequence types with MLST

*E. coli* has more than one MLST scheme. The most widely used is the **Achtman** scheme, whose STs are assigned and curated by the EnteroBase database; in `mlst` it is called `ecoli_achtman_4`. Type all three isolates with it. `--nopath` keeps the output tidy by dropping the folder name:

```bash
mlst --nopath --scheme ecoli_achtman_4 assemblies/*.fna > mlst.tsv
cut -f 1,3 mlst.tsv
```

Each line shows the file and its ST.

<!-- TODO: paste the expected output here -->
```text
GCA_032856485.1.fna    ...
GCA_040936765.1.fna    ...
GCA_058079015.1.fna    ...
```
{: .output}

{% include question.html id="ecoli-st-compare" %}

## Compare the allele profiles

An ST is just a name for one combination of seven alleles. Look at the full allele profiles to see what separates the STs:

```bash
cut -f 1,3- mlst.tsv
```

<!-- TODO: paste the expected output here -->
```text
GCA_032856485.1.fna    ...    adk(...)  fumC(...)  gyrB(...)  icd(...)  mdh(...)  purA(...)  recA(...)
...
```
{: .output}

Each allele number stands for one exact gene sequence. A single nucleotide change anywhere in one of the seven genes creates a different allele, and a different allele means a different ST. ST numbers are labels, not distances: two STs can differ by one SNP in one gene, or by many changes in all seven.

{% include question.html id="ecoli-st-alleles" %}

## Cluster the isolates with Floc

Now cluster the same three isolates with Floc. Floc sketches each genome with sourmash, compares the sketches, and groups genomes that are within a distance of 0.03 of one another (the default):

```bash
floc assemblies -o floc_db
cat floc_db/clusters.csv
```

`clusters.csv` lists each sample (`sid`) and its cluster number.

<!-- TODO: paste the expected output here -->
```text
sid,cluster
...
```
{: .output}

## Compare STs with Floc clusters

Put each isolate's ST and Floc cluster side by side. The `join` command matches rows from two files by sample name:

```bash
cut -f 1,3 mlst.tsv | sed 's/\.fna\t/\t/' | sort > st.tsv
tail -n +2 floc_db/clusters.csv | tr ',' '\t' | sort > floc.tsv

printf "sample\tST\tfloc\n"
join -t $'\t' st.tsv floc.tsv
```

<!-- TODO: paste the expected output here -->
```text
sample             ST    floc
GCA_032856485.1    ...   ...
GCA_040936765.1    ...   ...
GCA_058079015.1    ...   ...
```
{: .output}

{% include question.html id="ecoli-floc-together" %}

## Where do cluster names come from?

Floc numbers clusters in the order it discovers them, and saves a k-mer sketch (a *signature*) for every genome, with its cluster number, in `floc_db/sigs/`:

```bash
ls floc_db/sigs
```

These signatures **are** the cluster database. When new genomes arrive, you give Floc the new assemblies together with the existing signatures, and it adds them to existing clusters or starts new ones. For example (you don't need to run this now):

```bash
floc new_assemblies floc_db/sigs -o floc_db
```

As long as you keep adding to the same signatures, cluster numbers stay put. But the numbers only mean something inside *this* database. Another laboratory, a rebuilt database, or a different distance threshold can give the same group of genomes a different number.

{% include question.html id="ecoli-floc-name" %}

## What this shows
{: .no-step}

**An ST boundary can split isolates that belong together.** These three isolates are only 10–18 SNPs apart across the whole genome, but they don't all share an ST. If you used ST to decide which isolates to compare, you would set GCA_040936765.1 aside and miss that it is closely related to the other two.

**MLST names are stable and easy to communicate, but they depend on a catalog.** An ST is defined once by curators and means the same thing everywhere, so "ST405" needs no further explanation. But STs are categories based on seven genes, not a measure of genome-wide distance: a single change in one gene gives a new ST. And when an isolate has a new allele or a new combination of alleles, it has no ST at all until someone submits it and a curator assigns one.

**K-mer clustering is agnostic.** Floc needs no catalog and no curators. It compares genomes directly, so every genome is placed into a group as soon as it is sequenced, and isolates that are close across the genome end up together regardless of their ST. This makes k-mer clustering useful for any organism, with or without an established scheme.

**But cluster names are harder to communicate.** A cluster number is just a label in one database. It depends on which genomes the database has seen, in what order, and with what settings, so it is not stable across laboratories or over time unless everyone shares the same database. "Cluster 1" means nothing to a partner who hasn't seen your data.

| | MLST | Floc |
|---|---|---|
| Based on | 7 housekeeping genes | k-mers across the whole genome |
| Names come from | A curated, worldwide catalog | The order clusters are found in one database |
| New types | Need human curation before they have a name | Grouped immediately, no curation needed |
| Closely related isolates | Can be split if one of the seven genes differs | Grouped by genome-wide similarity |
| Communicating results | Easy: names mean the same thing everywhere | Harder: names are local and can change |

**Use both.** Report the ST so partners know what you're talking about. Use genome-wide grouping, such as k-mer clusters, to decide which isolates to compare, and don't rule out a comparison just because the STs differ.
