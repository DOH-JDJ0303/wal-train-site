---
layout: activity
section: getting-started
order: 2
title: Set Up Your Workspace
description: Open a terminal, confirm your tools work, and download the course data.
duration: 30 min
objectives:
  - Open a terminal on your operating system
  - Create a folder for the course
  - Download the course data files
prerequisites:
  - A computer running macOS, Linux, or Windows 10/11
  - On Windows, [WSL installed](https://learn.microsoft.com/windows/wsl/install) (ask an instructor if you need help)
---

Work through each step in order. Tick the checkbox at the bottom of a step once you've finished it.

## Open a terminal

How you open a terminal depends on your operating system:

| System | How to open a terminal |
|--------|------------------------|
| **macOS** | Press <kbd>⌘</kbd> + <kbd>Space</kbd>, type **Terminal**, press <kbd>Enter</kbd> |
| **Windows (WSL)** | Open the Start menu, type **Ubuntu**, press <kbd>Enter</kbd> |
| **Linux** | Press <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd> |

You should see a window with a **prompt** ending in `$` (or `%` on macOS), followed by a blinking cursor. This is where you type commands.

## Check which shell you are using

Type the following command and press <kbd>Enter</kbd>:

```bash
echo $SHELL
```

You should see something like:

```text
/bin/bash
```
{: .output}

{% include question.html id="setup-shell-name" %}

## Create a course folder

Keeping all your course files in one place makes them easier to find. Go to your home directory and create a folder called `course`:

```bash
cd ~
mkdir -p course/data
```

The `-p` option tells `mkdir` to create the parent folder (`course`) as well as `data` inside it, and not to complain if they already exist.

> Avoid spaces in file and folder names. The shell uses spaces to separate parts of a command, so `my course` would be read as two separate things.
{: .note}

## Download the course data

Move into the data folder and download the two files you'll use in later activities:

```bash
cd ~/course/data
curl -O {{ '/assets/files/sample01.fastq' | absolute_url }}
curl -O {{ '/assets/files/samplesheet.csv' | absolute_url }}
```

`curl` downloads a file from the web; the `-O` option saves it using its original name.

<details class="hint" markdown="1">
<summary>Hint: <code>curl: command not found</code></summary>

Some minimal Linux installs don't include `curl`. Try `wget` instead:

```bash
wget {{ '/assets/files/sample01.fastq' | absolute_url }}
wget {{ '/assets/files/samplesheet.csv' | absolute_url }}
```
</details>

## Confirm the files arrived

List the contents of the folder:

```bash
ls -lh
```

You should see both files, with their sizes:

```text
-rw-r--r--  1 student  staff   1.0K Nov 16 09:41 sample01.fastq
-rw-r--r--  1 student  staff   134B Nov 16 09:41 samplesheet.csv
```
{: .output}

> Your username, dates, and exact sizes will differ — what matters is that both file names appear.
{: .checkpoint}

## Wrap-up
{: .no-step}

Your workspace is ready. In the next section you'll learn what the shell is actually doing when you type a command like `ls -lh`.
