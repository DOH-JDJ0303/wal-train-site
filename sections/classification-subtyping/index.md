---
layout: section
section: classification-subtyping
title: Taxonomic Classification and Genomic Subtyping
---
**Taxonomy is a way of sorting organisms into groups with consistent names.** Those names do two jobs for us in public health genomics:

- **They let us communicate.** When one laboratory reports *Salmonella enterica* or *Candidozyma auris*, every partner knows what kind of organism is meant without re-analyzing the data.
- **They give us a first level of grouping.** Knowing the species lets us make generalizations about how a sample should be treated: which reference genome to use, which typing scheme applies, which resistance and virulence genes to look for, which samples it can sensibly be compared with, and what public health response it may need.

Species identification is therefore usually the first classification we perform with genomic data, and the answer shapes every analysis that follows.

Taxonomy only helps when groups are defined consistently, and they are not always. In the hands-on activities you'll see this from both directions: *Escherichia coli* and *Shigella*, named as different genera but nearly identical genome-wide, and influenza A, a single species whose members can be very different.

## In this course

1. **What a species is**, and why species definitions differ between bacteria, fungi, and viruses.
2. **How we identify species from genomes**, from marker genes (16S rRNA for bacteria, ITS for fungi) to k-mer-based methods.
   - *Activity:* *E. coli* and *Shigella*: two genus names, one species by genome-wide similarity.
3. **How we subtype below the species level**, from organism-specific schemes to general k-mer clustering, giving consistent, more granular labels that help us communicate and group samples before genome-wide analysis.
   - *Activity:* *E. coli*: comparing MLST and Floc for closely related isolates that don't share a sequence type.
   - *Optional activity:* Influenza A: one species, with genomes far more different than the bacterial species rule allows, classified by subtype instead.
