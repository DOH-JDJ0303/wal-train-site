---
layout: lecture
section: classification-subtyping
order: 3
title: Subtyping Below the Species Level
description: Influenza subtypes and genotypes, bacterial MLST, and C. auris clades — and why subtyping comes before genome-wide analysis.
---

## Why subtype?

Once the species is known, **subtyping** divides it into smaller, named groups using a defined, shared method. Subtyping serves two main purposes.

**1. A consistent way to talk about organisms.** A subtype label, such as *H5N1 clade 2.3.4.4b*, *E. coli ST131*, or *C. auris clade I*, means the same thing in every laboratory that uses the same scheme. It lets public health partners describe and compare organisms at a finer scale than species without sharing and re-analyzing full genomes, and it connects a sample to what is already known about that group.

**2. An initial grouping before genome-wide analysis.** Genome-wide methods such as cgMLST, core-SNP analysis, and phylogenetics work best when the samples being compared are reasonably closely related. Grouping samples by subtype first keeps the genetic distance *within* each analysis group small:

- A **closer reference genome** can be chosen, so more reads map accurately.
- The **shared (core) genome is larger**, so more of each genome contributes to the comparison.
- Samples that are clearly unrelated, such as those from different subtypes, are **separated early** instead of distorting the analysis of the rest.

> Sharing a subtype does **not** mean samples are part of the same outbreak. Subtypes are often common and long-lived. They narrow down which samples to compare; genome-wide analysis is still needed to assess relatedness.
{: .important}

## Influenza: subtype, clade, and genotype

Because influenza A is a single, very diverse species, most of the useful classification happens below the species level, in several layers:

| Level | Based on | Example |
|-------|----------|---------|
| **Subtype** | Hemagglutinin (HA) and neuraminidase (NA) genes | H5N1, H3N2 |
| **Clade** | HA gene sequence, following an agreed nomenclature | H5 clade 2.3.4.4b |
| **Genotype** | The combination of lineages across all eight gene segments | B3.13, D1.1 |

**LABEL** (Lineage Assignment By Extended Learning), from CDC's Influenza Division (the team that also develops the IRMA assembler), assigns HA sequences to clades. It uses statistical models of sequence profiles (profile hidden Markov models) trained on reference sequences. Modules are available for H5 clades following the WHO/WOAH/FAO H5 nomenclature.

**GenoFLU**, developed by the USDA, assigns genotypes to H5N1 clade 2.3.4.4b viruses from North America. It compares each of the eight segments to a set of reference segment types, then matches the full combination of segment types to a table of named genotypes. Because influenza segments can reassort, the genotype captures history that the HA clade alone cannot. For example, genotypes B3.13 and D1.1 were both associated with infections in U.S. dairy cattle but differ in which of their segments came from North American influenza lineages.

## Bacteria: multilocus sequence typing (MLST)

**MLST** characterizes a bacterial isolate by the sequences of a small set of housekeeping genes — usually **seven**. Each distinct sequence of a gene is given an allele number, and the combination of seven allele numbers defines a **sequence type (ST)**.

```text
Gene:     adk  fumC  gyrB  icd  mdh  purA  recA
Allele:    53    40    47   13   36    28    29    →  ST131
```

Schemes and allele definitions are maintained in public databases such as PubMLST, and many species have their own scheme.

The **`mlst`** tool scans an assembled genome against the available schemes, detects the right scheme automatically, and reports the allele numbers and sequence type. It flags new or partial alleles, which usually need follow-up.

MLST is fast, widely used, and easy to communicate, but seven genes give limited resolution. Isolates with the same ST can be quite distant across the rest of the genome. Finer resolution comes from core genome MLST (cgMLST) and SNP-based methods, covered in the next course.

## Fungi: *Candida auris* clades

*Candida auris* (recently renamed *Candidozyma auris*) is divided into **clades** — six have been described — that are strongly associated with geography. Isolates from different clades differ by tens of thousands of SNPs, whereas isolates within an outbreak typically differ by only a handful. This makes the clade both a useful epidemiological label and a natural first grouping step: genome-wide comparisons are usually performed within a clade, against a reference from the same clade.

**AuriClass** predicts the *C. auris* clade from either sequencing reads or an assembly by computing Mash distances to a set of reference genomes from each clade. It runs in seconds to minutes and reports the clade prediction, the closest reference, and quality checks.

## Summary

| Organism | Subtyping level | Example tools |
|----------|-----------------|---------------|
| Influenza A | Subtype, HA clade, genotype | LABEL, GenoFLU |
| Bacteria | Sequence type (ST) | `mlst` |
| *C. auris* | Clade | AuriClass |

- Species identification tells you **which subtyping scheme applies**.
- Subtyping gives a **shared language** for describing organisms below the species level.
- Subtyping groups closely related samples so that **genome-wide analysis** compares like with like.
- The same subtype is **not evidence of an outbreak** on its own — that requires the higher-resolution methods in the next course.
