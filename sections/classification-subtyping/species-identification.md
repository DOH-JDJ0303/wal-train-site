---
layout: lecture
section: classification-subtyping
order: 2
title: Genome-Based Species Identification
description: "From single marker genes (16S rRNA and ITS) to whole-genome k-mer methods: how each approach works and where it falls short."
---

## Single-gene identification

Before whole genomes were routine, organisms were identified by sequencing a single **marker gene**: one that is found in every member of a group, is conserved enough to amplify with the same primers, and varies enough to tell taxa apart. Which marker works depends on the kind of organism, and for viruses there is no universal one.

### Bacteria: 16S rRNA

The 16S ribosomal RNA gene is present in all bacteria and contains conserved regions, which make it easy to amplify, alongside variable regions that differ between taxa. For decades it was the standard molecular method for bacterial identification, and it remains widely used for mixed-community (amplicon) studies.

Its main limitation is resolution. **16S does not always resolve organisms to the species level**, because closely related species can have identical or nearly identical 16S sequences, and short partial-gene sequences resolve even less than the full gene [1]. Examples include:

- *Escherichia coli* and *Shigella* spp.: 16S sequences are more than 99.5% similar and cannot separate them [2]
- Members of the *Bacillus cereus* group, including *B. anthracis*: some strains differ by a single nucleotide [3]
- *Streptococcus pneumoniae* and *S. mitis*: 16S sequences are more than 99% identical [4]

![A circular bacterial genome of about 5 million base pairs, with seven short marks for the 16S rRNA gene copies, each about 1,500 base pairs]({{ '/assets/images/16s-genome.svg' | relative_url }})

Many genomes also carry several copies of the 16S gene (up to 15), and in most genomes the copies are not identical to one another [5, 6]. A single gene captures only a tiny fraction of the genome, so whole-genome methods such as average nucleotide identity (ANI) are generally preferred when a genome sequence is available [7–9].

<details class="hint" markdown="1">
<summary>References for this section</summary>

1. Johnson JS, *et al.* (2019). Evaluation of 16S rRNA gene sequencing for species and strain-level microbiome analysis. *Nature Communications* 10:5029. [doi:10.1038/s41467-019-13036-1](https://doi.org/10.1038/s41467-019-13036-1)
2. Devanga Ragupathi NK, *et al.* (2018). Accurate differentiation of *Escherichia coli* and *Shigella* serogroups: challenges and strategies. *New Microbes and New Infections* 21:58–62. [doi:10.1016/j.nmni.2017.09.003](https://doi.org/10.1016/j.nmni.2017.09.003)
3. Ash C, *et al.* (1991). Comparative analysis of *Bacillus anthracis*, *Bacillus cereus*, and related species on the basis of reverse transcriptase sequencing of 16S rRNA. *International Journal of Systematic Bacteriology* 41:343–346. [doi:10.1099/00207713-41-3-343](https://doi.org/10.1099/00207713-41-3-343)
4. Scholz CFP, Poulsen K, Kilian M (2012). Novel molecular method for identification of *Streptococcus pneumoniae* applicable to clinical microbiology and 16S rRNA sequence-based microbiome studies. *Journal of Clinical Microbiology* 50:1968–1973. [doi:10.1128/JCM.00365-12](https://doi.org/10.1128/JCM.00365-12)
5. Větrovský T, Baldrian P (2013). The variability of the 16S rRNA gene in bacterial genomes and its consequences for bacterial community analyses. *PLoS ONE* 8:e57923. [doi:10.1371/journal.pone.0057923](https://doi.org/10.1371/journal.pone.0057923)
6. Pei AY, *et al.* (2010). Diversity of 16S rRNA genes within individual prokaryotic genomes. *Applied and Environmental Microbiology* 76:3886–3897. [PMID 20418441](https://pubmed.ncbi.nlm.nih.gov/20418441/)
7. Richter M, Rosselló-Móra R (2009). Shifting the genomic gold standard for the prokaryotic species definition. *PNAS* 106:19126–19131. [doi:10.1073/pnas.0906412106](https://doi.org/10.1073/pnas.0906412106)
8. Jain C, *et al.* (2018). High throughput ANI analysis of 90K prokaryotic genomes reveals clear species boundaries. *Nature Communications* 9:5114. [doi:10.1038/s41467-018-07641-9](https://doi.org/10.1038/s41467-018-07641-9)
9. Chun J, *et al.* (2018). Proposed minimal standards for the use of genome data for the taxonomy of prokaryotes. *International Journal of Systematic and Evolutionary Microbiology* 68:461–466. [doi:10.1099/ijsem.0.002516](https://doi.org/10.1099/ijsem.0.002516)
</details>

### Fungi: ITS

Fungi do not have a 16S gene. Their ribosomal RNA genes are arranged differently, and the region most used for identification is the **internal transcribed spacer (ITS)**: two spacer regions (ITS1 and ITS2) that sit between the ribosomal RNA genes and are removed when the RNA is processed.

```text
... 18S rRNA | ITS1 | 5.8S rRNA | ITS2 | 28S rRNA ...
             \_________ ITS region _________/
```

Because the spacers are not part of the final ribosome, they change faster than the ribosomal genes around them, which helps separate species. In a large comparison of candidate markers, ITS had the highest probability of successful identification across the broadest range of fungi, and it was proposed as the primary DNA barcode for fungi in 2012 [1].

ITS has limitations that mirror those of 16S:

- **Some species share identical ITS sequences.** In *Aspergillus*, for example, ITS sequences are identical within several species complexes, so additional markers are needed [1]. Protein-coding genes such as β-tubulin and calmodulin are commonly used for *Aspergillus* [2].
- **ITS copies within one genome can differ**, much like 16S copies in bacteria [3].
- **No single marker works for every fungus** [1]. Combining ITS with protein-coding genes is often more effective for species-level identification [3].

As with bacteria, whole-genome methods avoid most of these problems when a genome sequence is available, but the hybrids and naming history described in the previous lecture can still complicate the answer.

<details class="hint" markdown="1">
<summary>References for this section</summary>

1. Schoch CL, *et al.* (2012). Nuclear ribosomal internal transcribed spacer (ITS) region as a universal DNA barcode marker for Fungi. *PNAS* 109:6241–6246. [doi:10.1073/pnas.1117018109](https://doi.org/10.1073/pnas.1117018109)
2. Geiser DM, *et al.* (2007). The current status of species recognition and identification in *Aspergillus*. *Studies in Mycology* 59:1–10. [doi:10.3114/sim.2007.59.01](https://doi.org/10.3114/sim.2007.59.01)
3. Stengel A, Stanke KM, Quattrone AC, Herr JR (2022). Improving taxonomic delimitation of fungal species in the age of genomics and phenomics. *Frontiers in Microbiology* 13:847067. [doi:10.3389/fmicb.2022.847067](https://doi.org/10.3389/fmicb.2022.847067)
</details>

### Viruses: no universal marker gene

Viruses have no equivalent of 16S rRNA or ITS. They do not have ribosomes of their own, and no gene is shared by all viruses: as a consensus statement on virus taxonomy puts it, "viruses lack universal genes that can be used to construct a unified phylogeny" [1].

Conserved genes can still be useful **within** particular groups. Examples include the RNA-dependent RNA polymerase (RdRp) of RNA viruses and the replication-associated protein (Rep) of many small circular DNA viruses [1]. But no single gene can identify any virus, so viral identification relies on targets specific to a virus or virus family, or on the whole genome, followed by lower-level labels such as subtype or clade (as with influenza).

<details class="hint" markdown="1">
<summary>References for this section</summary>

1. Simmonds P, Adams MJ, Benkő M, *et al.* (2017). Consensus statement: Virus taxonomy in the age of metagenomics. *Nature Reviews Microbiology* 15:161–168. [doi:10.1038/nrmicro.2016.177](https://doi.org/10.1038/nrmicro.2016.177)
</details>

## Whole-genome identification with k-mers

A **k-mer** is a short sequence of fixed length *k*. A genome can be broken into all of its overlapping k-mers, and two genomes can then be compared by how many k-mers they share. Because this avoids full alignment, k-mer methods are fast enough to compare a sample against thousands of reference genomes in seconds to minutes.

| Approach | Example tools | What it does |
|----------|---------------|--------------|
| Genome-to-genome distance | Mash, GAMBIT | Compares the whole sample to reference genomes and reports the closest matches |
| Read-by-read classification | Kraken2 | Assigns each read (or contig) to a taxon, giving a breakdown of what is in the sample |

## Mash with a RefSeq sketch

**Mash** reduces each genome to a small "sketch": a random subset of its k-mers chosen with a technique called MinHash. Comparing two sketches gives the **Mash distance**, which approximates how different the two genomes are; a Mash distance of about 0.05 roughly corresponds to 95% ANI.

A common approach is to compare a sample against a pre-built sketch of the NCBI **RefSeq** genome collection and look at the closest hits.

- **Strengths:** very fast; works on reads or assemblies; distances map onto the familiar ANI scale.
- **Watch out for:** the top hit is only as good as the reference labels. RefSeq includes misnamed genomes, and some species are much better represented than others, so look at several top hits rather than only the first.

## Kraken2

**Kraken2** matches k-mers against a database built from reference genomes. Each k-mer is linked to the *lowest common ancestor* of all genomes that contain it, so a k-mer shared by several species is assigned only to the genus or higher. Each read is then classified based on its k-mers.

- **Strengths:** classifies every read, so it can show **contamination or mixed samples** that a single "top hit" would hide; databases are available for bacteria, viruses, fungi, and human.
- **Watch out for:** results depend heavily on the database chosen; closely related species can share many k-mers, which pushes reads up to the genus level; low-level hits to unexpected organisms are common and usually reflect database artifacts rather than real contamination.

## GAMBIT

**GAMBIT** (Genomic Approximation Method for Bacterial Identification and Tracking) was designed for species identification of bacterial isolates in public health and clinical laboratories. It compares a fixed, targeted subset of each genome's k-mers (those that immediately follow a specific short sequence) against a curated database of about 50,000 RefSeq genomes.

Its key difference from a simple closest-match approach is that it uses **species-specific thresholds**. Each species has its own cutoff, based on how diverse that species is in the database. If a sample is too far from every species to fall within a threshold, GAMBIT reports a less specific answer (for example, the genus) instead of forcing a species call.

- **Strengths:** fast; curated database; thresholds that reflect the real diversity of each species, so it avoids over-confident calls.
- **Watch out for:** designed for bacterial isolates; species missing from the database cannot be identified.

## Choosing and combining methods

No method is perfect, and in practice laboratories often use more than one:

- Use a **whole-genome method** (Mash, GAMBIT) for the species call on an isolate.
- Use a **read-level classifier** (Kraken2) to check for contamination or mixed samples.
- When methods disagree, or the call is unexpected for the specimen, investigate before moving on: check sample quality, contamination, and whether the organism belongs to a group with known naming problems.

> A species call should match what you expected from the specimen and the laboratory work. A surprising result is a reason to investigate, not to accept the top hit.
{: .tip}

In the next activity you'll run several of these methods on two genomes where species names and genome similarity don't line up. After that, once the species is established, we'll look at how to describe organisms at a finer scale.
