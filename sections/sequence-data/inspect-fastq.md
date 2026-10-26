---
layout: activity
section: sequence-data
order: 2
title: Inspecting a FASTQ File
description: Use command-line tools to look inside a FASTQ file, count its reads, and summarize its contents.
duration: 75 min
objectives:
  - Display individual FASTQ records
  - Count reads reliably
  - Extract sequences and calculate read length and GC content
prerequisites:
  - "`sample01.fastq` downloaded to `~/course/data` (from [Set Up Your Workspace](../../getting-started/setup/))"
  - Comfortable with pipes and `wc` (from [Working with Files and Pipes](../../command-line/files-and-pipes/))
---

Move into your data folder before you begin:

```bash
cd ~/course/data
```

## Look at the first record

Print the first four lines of the file — exactly one read:

```bash
head -n 4 sample01.fastq
```

```text
@sample01_read1 length=50
GCTAAAGACAATTACATAACATACACGTCAGCACGAAACTTGTTGGCCCA
+
HCGFDFCH@@GEADAFE?I@GHDDDHFHF@@CFI@?CIHIFCEID?FDAH
```
{: .output}

{% include question.html id="fastq-lines-per-record" %}

## Count the reads

Count the lines in the file:

```bash
wc -l sample01.fastq
```

```text
32 sample01.fastq
```
{: .output}

{% include question.html id="fastq-count-reads" %}

## Spot the counting trap

A tempting shortcut is to count lines that start with `@`. Try it:

```bash
grep -c "^@" sample01.fastq
```

```text
10
```
{: .output}

That's two more than the real number of reads.

{% include question.html id="fastq-grep-trap" %}

<details class="hint" markdown="1">
<summary>Hint: find the extra lines</summary>

Print every line that starts with `@`, with its line number:

```bash
grep -n "^@" sample01.fastq
```

Header lines are always lines 1, 5, 9, … — any other line number is a quality line.
</details>

A safer pattern matches the full read-name prefix:

```bash
grep -c "^@sample01_" sample01.fastq
```

```text
8
```
{: .output}

## Extract just the sequences

The sequence is the 2nd line of every 4. `awk` can select lines by number — `NR` is the current line number and `%` gives the remainder after division:

```bash
awk 'NR % 4 == 2' sample01.fastq | head -n 3
```

```text
GCTAAAGACAATTACATAACATACACGTCAGCACGAAACTTGTTGGCCCA
ATACGCCTTTACTTGCTGTGTCCACCCCATCGGACTGGCATTTTTATTAC
GAGGCGCGCCCTCCTGAAGTGCGTGGACACTCGCTATGAATCTCTGATTT
```
{: .output}

## Measure read length

Print each sequence's length, then keep only the unique values:

```bash
awk 'NR % 4 == 2 {print length($0)}' sample01.fastq | sort -u
```

{% include question.html id="fastq-read-length" %}

## Calculate GC content

Count the G and C bases across all reads, then count all bases:

```bash
awk 'NR % 4 == 2' sample01.fastq | grep -o "[GC]" | wc -l
awk 'NR % 4 == 2' sample01.fastq | tr -d '\n' | wc -c
```

```text
200
400
```
{: .output}

> 200 of 400 bases are G or C, so the GC content is **50%**. If your numbers differ, check that you copied the `awk` pattern exactly.
{: .checkpoint}

## Look at base quality

Compare the quality lines of read 1 and read 3:

```bash
sed -n '4p;12p' sample01.fastq
```

```text
HCGFDFCH@@GEADAFE?I@GHDDDHFHF@@CFI@?CIHIFCEID?FDAH
4*4+++)+27053+262037.+11+))543*147+/6,66,)-,-1,52.
```
{: .output}

Read 3's quality string is full of low-value characters like `+`, `)`, and `*`.

{% include question.html id="fastq-quality-meaning" %}

{% include question.html
   type="open"
   question="Read 3 has much lower quality than read 1. What might you do with low-quality reads before using the data in an analysis?"
   sample_answer="Trim low-quality bases from the ends of reads, or filter out reads whose average quality falls below a threshold (for example Q20 or Q30), using a tool such as fastp or Trimmomatic." %}

## Wrap-up
{: .no-step}

You've inspected a FASTQ file entirely from the command line: viewing records, counting reads, and calculating length and GC content. These same commands work on files with millions of reads.
