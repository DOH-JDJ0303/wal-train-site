---
layout: activity
section: classification-subtyping
order: 3
title: "When Names and Genomes Disagree: E. coli and Shigella"
nav_title: "Activity: E. coli vs. Shigella"
description: Download two genome assemblies, identify their species with Mash and ShigaPass, measure their similarity with FastANI, and work out why the answers disagree.
objectives:
  - Download genome assemblies from NCBI with the `datasets` command-line tool
  - Identify species from the closest RefSeq genome with Mash
  - Identify *Shigella* and its serotype with ShigaPass
  - Measure genome-wide similarity with FastANI
  - Explain why whole-genome methods struggle to separate *E. coli* from *Shigella*
prerequisites:
  - Completed the lecture [Genome-Based Species Identification](../species-identification/)
  - A Linux, macOS, or WSL terminal with [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) installed
  - Several GB of free disk space for the Mash reference database
---

<!-- TODO (instructor): fill in the expected-output blocks marked TODO.
     scripts/test-ecoli-shigella.sh runs the whole activity and prints them. -->

You have two bacterial genome assemblies from NCBI. In this activity you'll identify their species in two different ways — by finding the most similar genome in a large reference database, and by looking for the specific genes that define *Shigella* — and compare the answers. Along the way you'll see why *Escherichia coli* and *Shigella*, named as different genera, are one of the most confusing cases in bacterial taxonomy.

## Set up the software

Create a micromamba environment with the NCBI `datasets` tool, Mash, FastANI, and BLAST (which ShigaPass needs):

```bash
micromamba create -y -n species-id -c conda-forge -c bioconda ncbi-datasets-cli mash fastani blast
micromamba activate species-id
```

ShigaPass is a shell script distributed on GitHub. Download it into a folder for this activity:

```bash
mkdir -p ~/course/ecoli-shigella && cd ~/course/ecoli-shigella
git clone https://github.com/imanyass/ShigaPass.git
chmod +x ShigaPass/SCRIPT/ShigaPass.sh
```

Check that each tool runs:

```bash
datasets --version
mash --version
fastANI --version
ShigaPass/SCRIPT/ShigaPass.sh -v
```

## Download the Mash reference database

Mash compares your genomes against a pre-built *sketch* of every genome in NCBI RefSeq. Download it into a `db` folder. The file is large, so this step can take a while.

```bash
mkdir -p db
curl -L -o db/refseq.genomes.k21s1000.msh \
  https://gembox.cbcb.umd.edu/mash/refseq.genomes.k21s1000.msh
```

> If the download stops part-way, rerun the same `curl` command with `-C -` added to resume it.
{: .tip}

## Download the two assemblies

The `datasets` tool downloads genomes from NCBI by accession number. Download both assemblies in one package:

```bash
datasets download genome accession GCA_052160995.1 GCA_055444035.1 \
  --include genome --filename genomes.zip
unzip -o genomes.zip
```

`datasets` puts each assembly in its own folder under `ncbi_dataset/data/`. Copy them to short, simple names:

```bash
cp ncbi_dataset/data/GCA_052160995.1/*_genomic.fna genome_A.fna
cp ncbi_dataset/data/GCA_055444035.1/*_genomic.fna genome_B.fna
ls -lh genome_*.fna
```

> We won't look at the species names attached to these assemblies yet. The point is to see what each method concludes on its own.
{: .note}

## Identify the species with Mash

Compare each genome to every genome in the RefSeq sketch. `mash dist` reports the reference, the query, the Mash distance, a p-value, and the number of shared hashes. Sorting on the distance (column 3) puts the closest genomes first:

```bash
for g in genome_A genome_B; do
  mash dist db/refseq.genomes.k21s1000.msh $g.fna | sort -gk3 > $g.mash.tsv
done
```

The reference IDs are file names, not species names. The species names are stored in the sketch's metadata. Extract the metadata once, then print the five closest genomes for each assembly with their distance and description:

```bash
mash info -t db/refseq.genomes.k21s1000.msh > db/refseq.info.tsv
for g in genome_A genome_B; do
  echo "== $g"
  head -n 5 $g.mash.tsv |
    awk -F '\t' 'NR == FNR { desc[$3] = $4; next } { print $3 "\t" desc[$1] }' \
      db/refseq.info.tsv -
done
```

<!-- TODO: paste the expected top hits here (scripts/test-ecoli-shigella.sh prints them) -->
```text
== genome_A
0.00...    [...] NZ_... Shigella flexneri ...
== genome_B
...
```
{: .output}

{% include question.html id="ecoli-shigella-mash" %}

## Identify the species with ShigaPass

ShigaPass is built specifically to tell *Shigella* apart from *E. coli*. Instead of comparing whole genomes, it looks for particular genes:

- ***ipaH***, an invasion gene carried by *Shigella* and by enteroinvasive *E. coli* (EIEC), but not by other *E. coli*
- ***rfb*** genes, which make the O-antigen and define *Shigella* serotypes
- Supporting markers: the *fliC* flagellin allele, MLST, and CRISPR spacers

ShigaPass takes a text file listing the full paths to the assemblies. On the first run, add `-u` to build its internal databases:

```bash
readlink -f genome_A.fna genome_B.fna > shigapass_list.txt
ShigaPass/SCRIPT/ShigaPass.sh -l shigapass_list.txt -o shigapass_results \
  -p ShigaPass/SCRIPT/ShigaPass_DataBases -u
cut -d ';' -f 1,7,8,9 shigapass_results/ShigaPass_summary.csv
```

The last command shows the four columns that matter here: the genome (`Name`), whether *ipaH* was found, and the predicted serotype. The prediction is one of three kinds:

| `Predicted_Serotype` | Meaning |
|----------------------|---------|
| A serotype, such as `SS` or `SF1-5` | *Shigella* (`SB` *S. boydii*, `SD` *S. dysenteriae*, `SF` *S. flexneri*, `SS` *S. sonnei*) |
| `EIEC` | *ipaH* is present but no *Shigella* serotype matches — most likely enteroinvasive *E. coli* |
| `Not Shigella/EIEC` | *ipaH* is absent — not *Shigella* and not EIEC |

<!-- TODO: paste the expected ShigaPass summary here (scripts/test-ecoli-shigella.sh prints it) -->
```text
Name;ipaH;Predicted_Serotype;Predicted_FlexSerotype
genome_A;ipaH-;Not Shigella/EIEC;
genome_B;ipaH+;...;...
```
{: .output}

{% include question.html id="ecoli-shigella-ipah" %}

{% include question.html id="ecoli-shigella-which" %}

## Measure how similar the genomes really are

So far, each tool has given a *label*. Now measure how similar the two genomes actually are with **FastANI**, which estimates average nucleotide identity (ANI). FastANI cuts the query genome into 3,000 bp fragments, finds the matching region for each one in the reference genome, and averages the identity of the matches.

```bash
fastANI -q genome_A.fna -r genome_B.fna -o ecoli_shigella_ani.txt
cat ecoli_shigella_ani.txt
```

The output has five columns: the query, the reference, the **ANI**, the number of fragments that matched, and the total number of fragments in the query.

<!-- TODO: paste the expected FastANI line here (scripts/test-ecoli-shigella.sh prints it) -->
```text
genome_A.fna    genome_B.fna    ...
```
{: .output}

{% include question.html id="ecoli-shigella-fastani" %}

> For comparison, FastANI's own documentation reports an ANI of about 97.8% between *Shigella flexneri* 2a and *E. coli* K-12 — well above the ~95% line normally used to separate bacterial species.
{: .note}

## Why did the answers disagree?
{: .no-step}

Mash's closest RefSeq genome for genome A is labeled *Shigella flexneri*, yet ShigaPass found no *ipaH* and no *Shigella* serotype genes in it. Genome A is an *E. coli* that the nearest-genome approach misidentified as *S. flexneri*; genome B is the true *Shigella*. Neither tool is broken — they are answering different questions.

**Genome-wide, *Shigella* is *E. coli*.** As your FastANI result shows, by whole-genome similarity *E. coli* and the four *Shigella* species fall within a single species boundary (around 95% average nucleotide identity), and *Shigella* lineages sit *within* the *E. coli* family tree. *Shigella* is named as a separate genus because of its clinical history and the disease it causes, which depend on a small set of genes — most importantly a large plasmid carrying the invasion genes. That is not how we usually define bacterial species.

**Mash reports the nearest labeled genome.** A Mash top hit is simply the closest genome in the database, and the "species" is whatever name that reference genome carries. Because *E. coli* and *Shigella* are intermixed across the same family tree, the closest genome to an *E. coli* can easily be one labeled *Shigella* — and the reverse. The distance is small either way. Reference labels are also not always correct, which adds to the problem.

**ShigaPass checks the genes that define the name.** Because the *Shigella* label rests on specific genes rather than overall similarity, a targeted tool that looks for *ipaH* and the serotype-defining *rfb* genes is the right way to decide. Even *ipaH* alone is not enough, because EIEC carries it too; ShigaPass combines several markers to separate *Shigella* from EIEC.

{% include question.html id="ecoli-shigella-why" %}

### Takeaways

- A species name is only as consistent as the definition behind it. *E. coli* and *Shigella* are separated by a few genes, not by genome-wide distance.
- Nearest-genome methods are excellent for most species calls, but their answer is only as good as the reference labels behind them.
- When a species call drives the public health response — shigellosis and *E. coli* infections are reported and investigated differently — confirm it with an organism-specific tool.
- The species call decides what comes next: the reference genome, the typing scheme, and which samples are compared. An error here carries through every later step.
