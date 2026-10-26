---
layout: page
title: Resources
permalink: /resources/
description: Files, references, and tools used throughout the course.
---

## Course files

| File | Used in |
|------|---------|
| [sample01.fastq]({{ '/assets/files/sample01.fastq' | relative_url }}) | Inspecting a FASTQ file |
| [samplesheet.csv]({{ '/assets/files/samplesheet.csv' | relative_url }}) | Working with files and pipes |

## Command-line quick reference

| Command | What it does |
|---------|--------------|
| `pwd` | Print the current working directory |
| `ls -lh` | List files with sizes in human-readable units |
| `cd <dir>` | Change directory (`cd ..` goes up one level, `cd ~` goes home) |
| `mkdir -p <dir>` | Make a directory, including any missing parents |
| `head -n 4 <file>` | Show the first 4 lines of a file |
| `wc -l <file>` | Count lines |
| `grep <pattern> <file>` | Show lines that match a pattern |
| `cmd1 \| cmd2` | Send the output of one command into another |
| `cmd > file` / `cmd >> file` | Write output to a file (overwrite / append) |

## Further reading

- [The Unix Shell](https://swcarpentry.github.io/shell-novice/) — Software Carpentry
- [FASTQ format](https://en.wikipedia.org/wiki/FASTQ_format) — overview of the format and quality encodings
- [Windows Subsystem for Linux](https://learn.microsoft.com/windows/wsl/install) — installing a Linux shell on Windows
