---
layout: lecture
section: classification-subtyping
order: 1
title: What Is a Species?
description: Why species identification comes first, and why species definitions are less consistent than they appear.
---

## Species identification comes first

When a sample is sequenced, the first question is usually *what organism is this?* Species identification is the first level of classification we perform with genomic data, and nearly every downstream decision depends on it:

- **Which reference genome** to compare against
- **Which typing scheme** applies (an MLST scheme, a clade system, an influenza subtype)
- **Which samples** can meaningfully be compared with each other
- **Which interpretation guidelines** apply (for example, what counts as "closely related" for that organism)

An incorrect or overly broad species call carries forward into every later step, so it is worth understanding what a species call actually means.

```text
Species             e.g. Escherichia coli · Candidozyma auris · Influenza A
  └── Subtype         e.g. MLST sequence type · clade · HA/NA subtype
        └── Genome-wide relatedness   cgMLST, core-SNP, phylogenetics
```

## There is no single species definition

"Species" sounds like a fixed biological unit, but in microbiology it is partly a practical convention. Definitions differ between groups of organisms, and they have changed over time as methods have changed:

- Many species names were assigned long before genome sequencing, based on morphology, biochemistry, disease, or host.
- Some names are kept for historical or clinical reasons even when genomes suggest otherwise.
- Bacteria, fungi, and viruses are each classified under different rules and by different bodies.

As a result, two organisms in the "same species" may be far more different from each other in one group than in another. This is a common source of confusion when people compare results across organisms.

## Bacteria: the ~95% ANI convention

For bacteria, the most widely used genomic yardstick is **average nucleotide identity (ANI)**: the average identity of the regions two genomes share. Genomes that share roughly **95–96% ANI** or more are generally considered the same species.

This works well for most bacteria, but there are well-known exceptions where names and genomes disagree:

| Example | What the genomes say | What the names say |
|---------|----------------------|--------------------|
| *Escherichia coli* and *Shigella* spp. | Fall within the same ANI species boundary | Kept as separate genera for clinical and historical reasons |
| *Bacillus anthracis* and *B. cereus* | Above the ANI species threshold of each other | Named as separate species because of distinct disease and virulence plasmids |

> The ANI threshold is a convention that fits most bacteria, not a law of nature. When a species call looks surprising, check whether the organism belongs to a group where names and genomic boundaries are known to disagree.
{: .note}

## Viruses: species can be very diverse

Viral species are defined differently, and the ~95% identity idea does not carry over. A single viral species can contain viruses that are genetically very different from one another.

**Influenza A is a clear example.** All influenza A viruses belong to one species (*Alphainfluenzavirus influenzae* in current virus taxonomy), yet that species includes many hemagglutinin (HA) and neuraminidase (NA) subtypes, including H1N1, H3N2, and H5N1. HA genes from different subtypes differ far more than two bacteria of the same species would. Influenza viruses can also swap whole gene segments (reassortment), so different segments of the same virus can have different histories.

For influenza, then, "species" tells us relatively little on its own. The useful information comes from the next level down: subtype, lineage, clade, and genotype.

## Why this matters for outbreak work

- A **species call is a starting point**, not the finest resolution. It tells you which methods and references apply next.
- **The same word means different things** for different organisms. "Same species" may imply near-identity for one pathogen and substantial diversity for another.
- **Thresholds do not transfer** between organisms. A cutoff that works for one species should not be applied to another without evidence.

The next lecture covers the methods used to make the species call itself.
