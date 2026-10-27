---
layout: activity
section: classification-subtyping
order: 3
title: "When Names and Genomes Disagree: E. coli and Shigella"
nav_title: "Activity: E. coli vs. Shigella"
description: Two isolates thought to be Shigella flexneri look like the same species by FastANI, until GAMBIT and ShigaPass show that one of them is E. coli.
objectives:
  - Download genome assemblies from NCBI with the `datasets` command-line tool
  - Compare genomes with FastANI and interpret the ~95% ANI species threshold
  - Identify species with GAMBIT
  - Confirm *Shigella* identification and serotype with ShigaPass
  - Explain why genome-wide similarity cannot separate *E. coli* from *Shigella*
prerequisites:
  - Completed the lecture [Genome-Based Species Identification](../species-identification/)
  - A Linux, macOS, or WSL terminal with [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) installed
  - A few GB of free disk space for the GAMBIT database
---

<!-- TODO (instructor): fill in the expected-output blocks marked TODO. -->

Two bacterial isolates have been reported as ***Shigella flexneri***, and you've been asked to check whether they are the same species. In this activity you'll compare them in three ways (overall genome similarity, a curated species classifier, and a check for the genes that define *Shigella*) and see why the first answer is misleading.

## Set up the software

Create a micromamba environment with the NCBI `datasets` tool, FastANI, GAMBIT, and BLAST (which ShigaPass needs):

```bash
micromamba create -y -n species-id -c conda-forge -c bioconda ncbi-datasets-cli fastani gambit blast
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
fastANI --version
gambit --version
ShigaPass/SCRIPT/ShigaPass.sh -v
```

## Download the GAMBIT database

GAMBIT compares genomes against a curated database of RefSeq genomes. The database is two files; download both into a `db` folder. They are large, so this step can take a while.

```bash
mkdir -p db
for f in gambit-refseq-curated-1.0.gdb gambit-refseq-curated-1.0.gs; do
  curl -L -o db/$f \
    https://storage.googleapis.com/jlumpe-gambit/public/databases/refseq-curated/1.0/$f
done
```

> If a download stops part-way, rerun the loop with `-C -` added to the `curl` command to resume it.
{: .tip}

## Download the two assemblies

The `datasets` tool downloads genomes from NCBI by accession number. Download both isolates in one package:

```bash
datasets download genome accession GCA_052160995.1 GCA_055444035.1 \
  --include genome --filename genomes.zip
unzip -o genomes.zip
```

`datasets` puts each assembly in its own folder under `ncbi_dataset/data/`. Copy them to short, simple names:

```bash
cp ncbi_dataset/data/GCA_052160995.1/*_genomic.fna isolate_A.fna
cp ncbi_dataset/data/GCA_055444035.1/*_genomic.fna isolate_B.fna
ls -lh isolate_*.fna
```

## Compare the two isolates with FastANI

If both isolates are *S. flexneri*, their genomes should be very similar. Check with **FastANI**, which estimates average nucleotide identity (ANI). FastANI cuts the query genome into 3,000 bp fragments, finds the matching region for each one in the reference genome, and averages the identity of the matches.

```bash
fastANI -q isolate_A.fna -r isolate_B.fna -o isolates_ani.txt
cat isolates_ani.txt
```

The output has five columns: the query, the reference, the **ANI**, the number of fragments that matched, and the total number of fragments in the query.

<!-- TODO: paste the expected FastANI line here -->
```text
isolate_A.fna    isolate_B.fna    ...
```
{: .output}

For bacteria, genomes that share about **95% ANI or more** are usually considered the same species.

{% include question.html id="ecoli-shigella-fastani" %}

## Identify each isolate with GAMBIT

FastANI tells you how similar the two isolates are to *each other*, but not what they are. To identify each one, classify them with **GAMBIT**, which compares each genome to its curated reference database and applies a separate distance threshold for every species:

```bash
gambit -d db query -o gambit.csv isolate_A.fna isolate_B.fna
cut -d, -f 1-3 gambit.csv
```

The columns show the isolate (`query`), GAMBIT's prediction (`predicted.name`), and how specific the prediction is (`predicted.rank`). The full `gambit.csv` also lists the closest reference genome for each isolate.

<!-- TODO: paste the expected GAMBIT output here -->
```text
query,predicted.name,predicted.rank
isolate_A,Escherichia coli,species
isolate_B,...
```
{: .output}

{% include question.html id="ecoli-shigella-gambit" %}

## Confirm with ShigaPass

Two tools now disagree about isolate A: by ANI it belongs with a *Shigella flexneri* isolate, but GAMBIT calls it *E. coli*. **ShigaPass** settles the question by looking for the genes that define *Shigella*, rather than overall similarity:

- ***ipaH***, an invasion gene carried by *Shigella* and by enteroinvasive *E. coli* (EIEC), but not by other *E. coli*
- ***rfb*** genes, which make the O-antigen and define *Shigella* serotypes
- Supporting markers: the *fliC* flagellin allele, MLST, and CRISPR spacers

ShigaPass takes a text file listing the full paths to the assemblies. On the first run, add `-u` to build its internal databases:

```bash
readlink -f isolate_A.fna isolate_B.fna > shigapass_list.txt
ShigaPass/SCRIPT/ShigaPass.sh -l shigapass_list.txt -o shigapass_results \
  -p ShigaPass/SCRIPT/ShigaPass_DataBases -u
cut -d ';' -f 1,7,8,9 shigapass_results/ShigaPass_summary.csv
```

The last command shows the four columns that matter here: the isolate (`Name`), whether *ipaH* was found, and the predicted serotype. The prediction is one of three kinds:

| `Predicted_Serotype` | Meaning |
|----------------------|---------|
| A serotype, such as `SS` or `SF1-5` | *Shigella* (`SB` *S. boydii*, `SD` *S. dysenteriae*, `SF` *S. flexneri*, `SS` *S. sonnei*) |
| `EIEC` | *ipaH* is present but no *Shigella* serotype matches; most likely enteroinvasive *E. coli* |
| `Not Shigella/EIEC` | *ipaH* is absent; not *Shigella* and not EIEC |

<!-- TODO: paste the expected ShigaPass summary here -->
```text
Name;ipaH;Predicted_Serotype;Predicted_FlexSerotype
isolate_A;ipaH-;Not Shigella/EIEC;
isolate_B;ipaH+;SF...;...
```
{: .output}

{% include question.html id="ecoli-shigella-ipah" %}

{% include question.html id="ecoli-shigella-which" %}

## What happened?
{: .no-step}

Both isolates were reported as *S. flexneri*, and FastANI placed them comfortably within the same species. Yet isolate A turned out to be *E. coli*: GAMBIT identified it as *E. coli*, and ShigaPass found none of the genes that define *Shigella*. Isolate B is the true *S. flexneri*.

**Genome-wide, *Shigella* is *E. coli*.** By whole-genome similarity, *E. coli* and the four *Shigella* species fall within a single species boundary, and *Shigella* lineages sit *within* the *E. coli* family tree. *Shigella* is named as a separate genus because of its clinical history and the disease it causes, which depend on a small set of genes, most importantly a large plasmid carrying the invasion genes. That is not how we usually define bacterial species, so **an ANI above 95% cannot tell *E. coli* and *Shigella* apart**.

**GAMBIT uses a curated database and species-specific thresholds.** Rather than applying one cutoff to everything, GAMBIT sets a separate distance threshold for each species based on how diverse that species is, and its reference set is curated to keep names consistent. That lets it separate groups that overlap genome-wide, where a single ANI threshold cannot.

**ShigaPass checks the genes that define the name.** Because the *Shigella* label rests on specific genes rather than overall similarity, a targeted tool that looks for *ipaH* and the serotype-defining *rfb* genes is the most direct way to confirm it. Even *ipaH* alone is not enough, because EIEC carries it too; ShigaPass combines several markers to separate *Shigella* from EIEC.

{% include question.html id="ecoli-shigella-why" %}

### Takeaways

- A species name is only as consistent as the definition behind it. *E. coli* and *Shigella* are separated by a few genes, not by genome-wide distance.
- The ~95% ANI rule works for most bacteria, but not here: two isolates can pass it and still carry different genus names.
- Classifiers built on curated references and species-specific thresholds, such as GAMBIT, handle these cases better than a single cutoff, but for organisms where a few genes define the name, confirm with an organism-specific tool like ShigaPass.
- The species call drives the public health response (shigellosis and *E. coli* infections are reported and investigated differently) and decides what comes next: the reference genome, the typing scheme, and which samples are compared.
