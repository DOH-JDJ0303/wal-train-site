---
layout: lecture
section: sequence-data
order: 1
title: FASTA and FASTQ Formats
description: How sequences and their quality scores are stored as plain text.
duration: 40 min
objectives:
  - Recognize FASTA and FASTQ files and their parts
  - Explain what a Phred quality score represents
  - Choose a reliable way to count reads in a FASTQ file
---

## FASTA: sequences only

A FASTA file stores one or more sequences. Each record has a **header** line starting with `>`, followed by one or more lines of sequence:

```text
>segment_4_HA
ATGAAGGCAATACTAGTAGTTCTGCTATATACATTTGCAACCGCAAATGCAGACACATTATGTATAGG
TTATCATGCGAACAATTCAACAGACACTGTAGACACAGTACTAGAAAAGAATGTAACAGTAACACACT
>segment_6_NA
ATGAATCCAAATCAAAAGATAATAACCATTGGATCAATCTGTCTGGTAGTCGGACTAATTAGCCTAAT
```

FASTA is used for reference genomes, assembled consensus sequences, and databases.

## FASTQ: sequences plus quality

Sequencing reads usually come as FASTQ, which adds a quality score for **every base**. Each read takes exactly four lines:

```text
@sample01_read1 length=50
GCTAAAGACAATTACATAACATACACGTCAGCACGAAACTTGTTGGCCCA
+
HCGFDFCH@@GEADAFE?I@GHDDDHFHF@@CFI@?CIHIFCEID?FDAH
```

| Line | Starts with | Contains |
|------|-------------|----------|
| 1 | `@` | Read identifier and optional description |
| 2 | — | The base calls |
| 3 | `+` | Separator (sometimes repeats the identifier) |
| 4 | — | One quality character per base |

## Reading quality scores

Each quality character encodes a **Phred score** (*Q*). In the common *Phred+33* encoding, *Q* is the character's ASCII value minus 33:

| Character | Q | Chance the base call is wrong |
|-----------|---|-------------------------------|
| `+` | 10 | 1 in 10 |
| `5` | 20 | 1 in 100 |
| `?` | 30 | 1 in 1,000 |
| `I` | 40 | 1 in 10,000 |

A common rule of thumb is that bases at Q30 or above are high quality.

> Because `@` is also a valid quality character (Q31), a quality line can start with `@`. That makes `grep '^@'` an unreliable way to count reads — you'll see this for yourself in the next activity.
{: .important}

## Compressed files

FASTQ files are usually gzip-compressed and end in `.fastq.gz`. Most tools read them directly, and you can view them without unpacking:

```bash
zcat reads.fastq.gz | head -n 8
```

On macOS, use `gzcat` instead of `zcat`.

## Summary

- **FASTA**: `>` header + sequence. **FASTQ**: four lines per read, including quality.
- Quality characters map to Phred scores; higher means more confident.
- Count FASTQ reads by counting lines and dividing by four.
