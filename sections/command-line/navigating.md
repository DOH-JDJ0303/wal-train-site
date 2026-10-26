---
layout: activity
section: command-line
order: 2
title: Navigating the File System
description: Find out where you are, look around, and move between directories.
duration: 45 min
objectives:
  - Use `pwd`, `ls`, and `cd` to explore the file system
  - Move using both absolute and relative paths
  - Use tab completion and command history to work faster
prerequisites:
  - Completed [Set Up Your Workspace](../../getting-started/setup/)
---

## Find out where you are

Open your terminal and print your **working directory** — the folder the shell is currently "in":

```bash
pwd
```

You'll see an absolute path to your home directory, such as:

```text
/home/student
```
{: .output}

{% include question.html id="nav-pwd" %}

## Look around

List what's in your home directory, then list it again with more detail:

```bash
ls
ls -l
```

Now add `-a` to include **hidden** files, whose names start with a dot:

```bash
ls -la
```

> You can combine single-letter options: `ls -la` is the same as `ls -l -a`.
{: .tip}

## Move into your course folder

Change into the `course` directory you created earlier, then confirm where you are:

```bash
cd course
pwd
```

```text
/home/student/course
```
{: .output}

## Go up, and back down

Use `..` to move up one level, then return using a **relative** path:

```bash
cd ..
pwd
cd course/data
pwd
```

{% include question.html id="nav-parent" %}

## Use an absolute path

From anywhere, an absolute path takes you to the same place. First go somewhere else, then jump straight back:

```bash
cd /tmp
cd ~/course/data
pwd
```

`~` is expanded to your home directory, so `~/course/data` is an absolute path in disguise.

{% include question.html id="nav-absolute-relative" %}

## Work faster: tab completion and history

1. Type `cd ~/cou` and press <kbd>Tab</kbd> — the shell fills in the rest of `course/`.
2. Press <kbd>↑</kbd> a few times to scroll back through the commands you've already run. Press <kbd>Enter</kbd> to run one again.
3. Run `history` to see a numbered list of everything you've typed.

```bash
history
```

> If <kbd>Tab</kbd> does nothing, there may be more than one match. Press it twice to list the options.
{: .note}

## Wrap-up
{: .no-step}

You can now find your way around any directory tree. Next, you'll look inside files and connect commands together.
