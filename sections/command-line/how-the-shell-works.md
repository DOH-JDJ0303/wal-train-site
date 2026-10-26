---
layout: lecture
section: command-line
order: 1
title: How the Shell Works
description: Prompts, commands, options and arguments — and how the shell finds your files.
duration: 45 min
objectives:
  - Identify the prompt, command, options, and arguments in a command line
  - Explain the difference between absolute and relative paths
  - Use built-in help to learn about a command
---

## The prompt

When the shell is ready for input it shows a **prompt**. It often includes your username, the computer's name, and the directory you're in:

```text
student@laptop:~/course$
```

Everything you type after the `$` is a command. In this course, when a block shows both the prompt and what comes back, the lines starting with `$` are what you type and the rest is output. The **Copy** button copies only the commands.

## Anatomy of a command

```console
$ ls -l data
total 8
-rw-r--r--  1 student  staff  1040 Nov 16 09:41 sample01.fastq
-rw-r--r--  1 student  staff   134 Nov 16 09:41 samplesheet.csv
```

| Part | Example | What it is |
|------|---------|------------|
| Command | `ls` | The program to run |
| Option (flag) | `-l` | Changes how the command behaves — here, a *long* listing |
| Argument | `data` | What the command acts on |

{% include question.html id="shell-what-is-prompt" %}

## The file system is a tree

Files live inside directories, which live inside other directories, all the way up to the **root**, written `/`.

```text
/
└── home/
    └── student/          ← your home directory (~)
        └── course/
            └── data/
                ├── sample01.fastq
                └── samplesheet.csv
```

There are two ways to refer to a location:

- An **absolute path** starts from the root and always begins with `/` — for example `/home/student/course/data`.
- A **relative path** starts from wherever you are now — for example `data/sample01.fastq` when you're inside `course`.

A few shortcuts are worth memorizing:

| Shortcut | Means |
|----------|-------|
| `~` | Your home directory |
| `.` | The current directory |
| `..` | The directory one level up |

## Getting help

Most commands describe their own options. Try either of these:

```bash
ls --help
man ls
```

`man` opens the full manual page; press <kbd>Space</kbd> to scroll and <kbd>q</kbd> to quit.

> On macOS, many commands don't support `--help`. Use `man <command>` instead.
{: .note}

## Summary

- The shell runs **commands**, which take **options** and **arguments**.
- Every file has a **path**; absolute paths start with `/`, relative paths start from where you are.
- `--help` and `man` tell you what a command can do.

In the next activity you'll put this into practice by moving around your course folder.
