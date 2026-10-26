---
layout: activity
section: your-section-id
order: 2
title: Activity Title
description: One sentence shown under the title and on section pages.
duration: 45 min
objectives:
  - What learners will do
prerequisites:
  - "Anything learners need first (quote lines that contain `backticks` or colons)"
---

Text before the first "##" heading is an introduction, not a step.

## First step title

Explain what to do, then give the command:

```bash
echo "run me"
```

Show what learners should see:

```text
run me
```
{: .output}

{% include question.html id="your-question-id" %}

## Second step title

<details class="hint" markdown="1">
<summary>Hint</summary>

Help for learners who get stuck.
</details>

<details class="solution" markdown="1">
<summary>Solution</summary>

```bash
the answer
```
</details>

## Wrap-up
{: .no-step}

A "##" heading marked {: .no-step} ends the steps and is not numbered.
