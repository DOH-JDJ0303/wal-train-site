---
layout: activity
section: classification-subtyping
order: 7
title: "Optional: One Species, Many Subtypes: Influenza A"
nav_title: "Optional activity: Influenza A"
description: Compare two influenza A genomes with FastANI and classify their segments with CDC LABEL to see why one species can contain very different viruses.
objectives:
  - Download influenza genomes from NCBI with the `datasets` command-line tool
  - Measure whole-genome similarity with FastANI
  - Classify influenza segments and subtypes with CDC LABEL
  - Explain why the ~95% ANI species rule does not apply to influenza
prerequisites:
  - Completed the lecture [Subtyping Below the Species Level](../subtyping/)
  - "Completed [When Names and Genomes Disagree: E. coli and Shigella](../ecoli-shigella/), including the `species-id` micromamba environment"
  - "A Linux or macOS terminal with Perl installed (LABEL does not run natively on Windows; use WSL)"
---

<!-- Instructor note: virus_1 = GCF_000865725.1 (H1N1); virus_2 = GCF_000865085.1 (H3N2). -->

> This activity is **optional**. It extends the ideas from the rest of the section to viruses, and nothing later in the course depends on it.
{: .note}

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
datasets download genome accession GCF_000865725.1 GCF_000865085.1 \
  --include genome --filename flu.zip
unzip -o flu.zip
cp ncbi_dataset/data/GCF_000865725.1/*_genomic.fna virus_1.fna
cp ncbi_dataset/data/GCF_000865085.1/*_genomic.fna virus_2.fna
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

```text
virus_1.fna    virus_2.fna    85.5116    16    23
```
{: .output}

The two genomes share about **85.5%** ANI. Look at the last two columns too: only **16 of the 23** fragments found a match at all. The other 7 were too different to be matched, so the 85.5% describes only the parts of the genomes that FastANI *could* compare — the true genome-wide identity is lower still.

> FastANI does not report a result when two sequences are much less than about 80% identical. An **empty** output file means the sequences are too different for FastANI to measure.
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

```text
                                                     VIRUS STRAIN    CLADE
NC_002017.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_4_complete_sequence    A_HA_H1
NC_002016.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_7_complete_sequence    A_MP
NC_002018.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_6_complete_sequence    A_NA_N1
NC_002019.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_5_complete_sequence    A_NP
NC_002020.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_8_complete_sequence    A_NS
NC_002022.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_3_complete_sequence    A_PA
NC_002021.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_2_complete_sequence    A_PB1
NC_002023.1_Influenza_A_virus_(A/Puerto_Rico/8/1934(H1N1))_segment_1_complete_sequence    A_PB2
                                                     VIRUS STRAIN    CLADE
NC_007366.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_4_complete_sequence     A_HA_H3
NC_007367.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_7_complete_sequence     A_MP
NC_007368.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_6_complete_sequence     A_NA_N2
NC_007369.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_5_complete_sequence     A_NP
NC_007370.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_8_complete_sequence     A_NS
NC_007371.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_3_complete_sequence     A_PA
NC_007372.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_2_complete_sequence     A_PB1
NC_007373.1_Influenza_A_virus_(A/New_York/392/2004(H3N2))_segment_1_complete_sequence     A_PB2
```
{: .output}

Each segment is labeled `A_` (influenza A) followed by the segment name. HA and NA segments also carry their subtype — for example, `A_HA_H3` and `A_NA_N2` together mean the virus is H3N2.

{% include question.html id="flu-label-subtype" %}

## What this shows
{: .no-step}

**One species, very different genomes.** Both viruses are influenza A — a single species — yet their genomes share only about 85% identity, and roughly a third of the genome was too different for FastANI to compare at all. Two bacteria this different would never be called the same species. Viral species are defined by different rules, so an identity threshold that works for bacteria does not carry over.

**The subtype comes from HA and NA.** LABEL separated the two viruses by their HA and NA segments: H1 and N1 in one, H3 and N2 in the other. These segments encode the two surface proteins, which are the main targets of the immune response and change rapidly to escape it, so HA and NA genes from different subtypes are very different from one another.

**Segments have their own histories.** Influenza viruses can swap whole segments when two viruses infect the same cell (reassortment). Each segment can come from a different ancestor, so a single genome-wide number hides a lot: two viruses can share some segments closely and differ greatly in others.

**This is why influenza is classified below the species level.** Because "influenza A" groups together such different viruses, the useful labels are the **subtype** (from HA and NA), and below that the **clade** and **genotype**. These are what LABEL and similar tools assign.

{% include question.html id="flu-why-subtype" %}
