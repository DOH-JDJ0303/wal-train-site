---
layout: activity
section: command-line
order: 3
title: Working with Files and Pipes
description: Look inside files, search them, and chain commands together with pipes and redirection.
duration: 60 min
objectives:
  - View the contents of text files with `cat`, `head`, and `less`
  - Count and search with `wc` and `grep`
  - Combine commands with `|` and save results with `>` and `>>`
prerequisites:
  - Completed [Navigating the File System](../navigating/)
---

All the commands in this activity run inside your data folder. Start there:

```bash
cd ~/course/data
```

## View a whole file

`cat` prints a file's entire contents to the screen. It's best for short files:

```bash
cat samplesheet.csv
```

```text
sample,fastq,collection_date
sample01,sample01.fastq,2026-09-14
sample02,sample02.fastq,2026-09-15
sample03,sample03.fastq,2026-09-15
```
{: .output}

## View part of a file

For large files, look at just the beginning or end:

```bash
head -n 2 samplesheet.csv
tail -n 1 samplesheet.csv
```

To scroll through a file page by page, use `less`. Press <kbd>q</kbd> to quit:

```bash
less sample01.fastq
```

## Count lines

`wc` counts lines, words, and characters. The `-l` option counts lines only.

{% include question.html id="pipes-count-lines" %}

<details class="solution" markdown="1">
<summary>Show the command</summary>

```bash
wc -l samplesheet.csv
```

```text
4 samplesheet.csv
```
{: .output}
</details>

## Search with grep

`grep` prints only the lines that match a pattern. Find every sample collected on 15 September:

```bash
grep "2026-09-15" samplesheet.csv
```

```text
sample02,sample02.fastq,2026-09-15
sample03,sample03.fastq,2026-09-15
```
{: .output}

## Connect commands with a pipe

The pipe `|` sends the output of one command into the next. Count the matching samples without creating a temporary file:

```bash
grep "2026-09-15" samplesheet.csv | wc -l
```

```text
2
```
{: .output}

Pull out just the sample names (the first comma-separated column), skipping the header line:

```bash
tail -n +2 samplesheet.csv | cut -d "," -f 1
```

```text
sample01
sample02
sample03
```
{: .output}

{% include question.html id="pipes-reflect" %}

## Save results to a file

Use `>` to write output to a new file, and `>>` to add to the end of an existing one:

```bash
tail -n +2 samplesheet.csv | cut -d "," -f 1 > sample_names.txt
echo "sample04" >> sample_names.txt
cat sample_names.txt
```

```text
sample01
sample02
sample03
sample04
```
{: .output}

> `>` silently replaces a file that already exists. Double-check the file name before you press <kbd>Enter</kbd>.
{: .warning}

{% include question.html id="pipes-redirect" %}

## Wrap-up
{: .no-step}

You've learned the core toolkit: view, count, search, pipe, and redirect. In the next section you'll use exactly these commands on sequencing data.
