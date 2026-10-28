---
layout: lecture
section: classification-subtyping
order: 1
title: What Is a Species?
description: Why species identification comes first, and why species definitions for bacteria, viruses, and fungi are less consistent than they appear.
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

Virus taxa are classified and named by the **International Committee on Taxonomy of Viruses (ICTV)**, which "is solely responsible for the classification of viruses into taxa and naming them" [1]. The ICTV defines a virus species as:

> "a monophyletic group of viruses whose properties can be distinguished from those of other species by multiple criteria" [1]

The definition does not say which criteria to use. Expert study groups for each virus family set their own, which can include sequence identity, host range, genome organization, and disease, and these criteria have not been applied consistently: there is "considerable variation in the way in which these criteria have been applied to viruses in different families" [1]. There is no single identity threshold like the ~95% ANI used for bacteria, and a single viral species can contain viruses that are genetically very different from one another.

**Influenza A is a clear example.** All influenza A viruses belong to one species (*Alphainfluenzavirus influenzae* in current virus taxonomy), yet that species includes many hemagglutinin (HA) and neuraminidase (NA) subtypes, including H1N1, H3N2, and H5N1. HA genes from different subtypes differ far more than two bacteria of the same species would. Influenza viruses can also swap whole gene segments (reassortment), so different segments of the same virus can have different histories.

For influenza, then, "species" tells us relatively little on its own. The useful information comes from the next level down: subtype, lineage, clade, and genotype.

<details class="hint" markdown="1">
<summary>References for this section</summary>

1. Simmonds P, Adams MJ, Benkő M, *et al.* (2017). Consensus statement: Virus taxonomy in the age of metagenomics. *Nature Reviews Microbiology* 15:161–168. [doi:10.1038/nrmicro.2016.177](https://doi.org/10.1038/nrmicro.2016.177)
</details>

## Fungi: phases, names, and hybrids

Defining fungal species is just as complicated as it is for bacteria and viruses, for reasons of its own. A review of fungal taxonomy concludes that "a single set of criteria do not sufficiently describe the diversity seen among fungal lineages" [1].

### One fungus, two forms, two names

Many fungi have two phases in their life cycle: a **sexual** phase (the *teleomorph*) and an **asexual** phase (the *anamorph*). The two can look so different under the microscope and in culture that they were long described as separate organisms, and for much of the history of mycology a single species could carry **one name for each phase** [1, 2].

*Cryptococcus neoformans*, a major cause of fungal meningitis, is a public health example. It was described from its asexual, yeast form. When its sexual form was discovered in 1975, it was given a separate genus and species name, *Filobasidiella neoformans* [3]. Both names referred to the same organism.

Mycologists have since moved to a "one fungus, one name" approach, and older phase-specific names are now treated as synonyms [2]. But those names remain in the literature, in reference databases, and in older reports, so the same organism can still appear under more than one name.

### *Candida*: the "dustbin" genus

The emphasis on the sexual stage shaped fungal names in another way. For a long time, *Candida* served as a "dustbin genus" for many asexual yeasts [6]. Yeasts were placed in it largely because they had no known sexual state, not because they were closely related, so *Candida* became **polyphyletic**: its species are scattered across the yeast family tree rather than forming one natural group [6].

Genome sequencing is now being used to sort these yeasts into genera that reflect their actual relationships. A 2024 phylogenomic study compared 304 single-copy genes from 155 yeast strains and proposed 13 new genera, 55 new combinations of genus and species names, and 9 new species [6]. Among the changes, *Candida auris*, a multidrug-resistant pathogen of major public health concern, was moved with its close relatives in the *C. haemuli* clade into a new genus, ***Candidozyma***. *Candida auris* is now ***Candidozyma auris*** [6].

> Expect to see both names for some time. Older reports, guidelines, reference databases, and laboratory systems may still use *Candida auris*, so search for both when looking up an organism.
{: .tip}

### Hybrids between species

Fungi can also form **hybrids between two different species**. When the genomes of two species combine in a single cell, the result is called **allopolyploidy** [1]. This is comparable to horizontal gene transfer in bacteria or reassortment in influenza, which also mix genetic material from different sources. In fungi, though, it can happen at the scale of the **whole genome**: a hybrid carries a full genome from each parent species.

The result is a lineage that belongs fully to neither parent, a hybrid quasispecies that does not fit neatly into either parent's name. Two examples among human pathogens:

- ***Cryptococcus* "AD" hybrids** combine the genomes of *C. neoformans* and *C. deneoformans*, two species that differ by roughly 10–15% across the genome. These hybrids account for up to 40% of cryptococcal infections in Europe [4].
- ***Candida metapsilosis*** appears to be a hybrid species: the clinical strains studied all trace back to a single past hybridization between two parental lineages that differ by about 4.5% [5].

Changes in ploidy (the number of genome copies) and mobile genetic elements add further complexity, and some fungi that look identical turn out to be genetically distinct "cryptic" species [1].

<details class="hint" markdown="1">
<summary>References for this section</summary>

1. Stengel A, Stanke KM, Quattrone AC, Herr JR (2022). Improving taxonomic delimitation of fungal species in the age of genomics and phenomics. *Frontiers in Microbiology* 13:847067. [doi:10.3389/fmicb.2022.847067](https://doi.org/10.3389/fmicb.2022.847067)
2. Taylor JW (2011). One Fungus = One Name: DNA and fungal nomenclature twenty years after PCR. *IMA Fungus* 2:113–120. [doi:10.5598/imafungus.2011.02.02.01](https://doi.org/10.5598/imafungus.2011.02.02.01)
3. Kwon-Chung KJ (1975). A new genus, *Filobasidiella*, the perfect state of *Cryptococcus neoformans*. *Mycologia* 67:1197–1200. [doi:10.2307/3758842](https://doi.org/10.2307/3758842)
4. Samarasinghe H, You M, Jenkinson TS, Xu J, James TY (2020). Hybridization facilitates adaptive evolution in two major fungal pathogens. *Genes* 11:101. [doi:10.3390/genes11010101](https://doi.org/10.3390/genes11010101)
5. Pryszcz LP, *et al.* (2015). The genomic aftermath of hybridization in the opportunistic pathogen *Candida metapsilosis*. *PLoS Genetics* 11:e1005626. [doi:10.1371/journal.pgen.1005626](https://doi.org/10.1371/journal.pgen.1005626)
6. Liu F, *et al.* (2024). Phylogenomic analysis of the *Candida auris*-*Candida haemuli* clade and related taxa in the Metschnikowiaceae, and proposal of thirteen new genera, fifty-five new combinations and nine new species. *Persoonia* 52:22–43. [doi:10.3767/persoonia.2024.52.02](https://doi.org/10.3767/persoonia.2024.52.02)
</details>

## Why this matters for outbreak work

- A **species call is a starting point**, not the finest resolution. It tells you which methods and references apply next.
- **The same word means different things** for different organisms. "Same species" may imply near-identity for one pathogen and substantial diversity for another.
- **Thresholds do not transfer** between organisms. A cutoff that works for one species should not be applied to another without evidence.
- **Names can change or have synonyms**, especially for fungi. Check older reports and databases for alternative names of the same organism.

The next lecture covers the methods used to make the species call itself.
