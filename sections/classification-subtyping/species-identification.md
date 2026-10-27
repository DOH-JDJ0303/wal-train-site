---
layout: lecture
section: classification-subtyping
order: 2
title: Genome-Based Species Identification
description: From a single marker gene to whole-genome k-mer methods — how each approach works and where it falls short.
---

## Single-gene identification: 16S rRNA

The 16S ribosomal RNA gene is present in all bacteria and contains conserved regions, which make it easy to amplify, alongside variable regions that differ between taxa. For decades it was the standard molecular method for bacterial identification, and it remains widely used for mixed-community (amplicon) studies.

Its main limitation is resolution. **16S does not always resolve organisms to the species level**, because closely related species can have identical or nearly identical 16S sequences. Examples include:

- *Escherichia coli* and *Shigella* spp.
- Members of the *Bacillus cereus* group, including *B. anthracis*
- *Streptococcus pneumoniae* and *S. mitis*

Many genomes also carry several copies of the 16S gene that are not identical to one another. A single gene captures only a tiny fraction of the genome, so whole-genome methods are generally preferred when a genome sequence is available.

## Whole-genome identification with k-mers

A **k-mer** is a short sequence of fixed length *k*. A genome can be broken into all of its overlapping k-mers, and two genomes can then be compared by how many k-mers they share. Because this avoids full alignment, k-mer methods are fast enough to compare a sample against thousands of reference genomes in seconds to minutes.

| Approach | Example tools | What it does |
|----------|---------------|--------------|
| Genome-to-genome distance | Mash, GAMBIT | Compares the whole sample to reference genomes and reports the closest matches |
| Read-by-read classification | Kraken2 | Assigns each read (or contig) to a taxon, giving a breakdown of what is in the sample |

## Mash with a RefSeq sketch

**Mash** reduces each genome to a small "sketch": a random subset of its k-mers chosen with a technique called MinHash. Comparing two sketches gives the **Mash distance**, which approximates how different the two genomes are — a Mash distance of about 0.05 roughly corresponds to 95% ANI.

A common approach is to compare a sample against a pre-built sketch of the NCBI **RefSeq** genome collection and look at the closest hits.

- **Strengths:** very fast; works on reads or assemblies; distances map onto the familiar ANI scale.
- **Watch out for:** the top hit is only as good as the reference labels. RefSeq includes misnamed genomes, and some species are much better represented than others, so look at several top hits rather than only the first.

## Kraken2

**Kraken2** matches k-mers against a database built from reference genomes. Each k-mer is linked to the *lowest common ancestor* of all genomes that contain it, so a k-mer shared by several species is assigned only to the genus or higher. Each read is then classified based on its k-mers.

- **Strengths:** classifies every read, so it can show **contamination or mixed samples** that a single "top hit" would hide; databases are available for bacteria, viruses, fungi, and human.
- **Watch out for:** results depend heavily on the database chosen; closely related species can share many k-mers, which pushes reads up to the genus level; low-level hits to unexpected organisms are common and usually reflect database artifacts rather than real contamination.

## GAMBIT

**GAMBIT** (Genomic Approximation Method for Bacterial Identification and Tracking) was designed for species identification of bacterial isolates in public health and clinical laboratories. It compares a fixed, targeted subset of each genome's k-mers — those that immediately follow a specific short sequence — against a curated database of about 50,000 RefSeq genomes.

Its key difference from a simple closest-match approach is that it uses **species-specific thresholds**. Each species has its own cutoff, based on how diverse that species is in the database. If a sample is too far from every species to fall within a threshold, GAMBIT reports a less specific answer (for example, the genus) instead of forcing a species call.

- **Strengths:** fast; curated database; thresholds that reflect the real diversity of each species, so it avoids over-confident calls.
- **Watch out for:** designed for bacterial isolates; species missing from the database cannot be identified.

## Choosing and combining methods

No method is perfect, and in practice laboratories often use more than one:

- Use a **whole-genome method** (Mash, GAMBIT) for the species call on an isolate.
- Use a **read-level classifier** (Kraken2) to check for contamination or mixed samples.
- When methods disagree, or the call is unexpected for the specimen, investigate before moving on — check sample quality, contamination, and whether the organism belongs to a group with known naming problems.

> A species call should match what you expected from the specimen and the laboratory work. A surprising result is a reason to investigate, not to accept the top hit.
{: .tip}

In the next activity you'll run several of these methods on two genomes where species names and genome similarity don't line up. After that, once the species is established, we'll look at how to describe organisms at a finer scale.
