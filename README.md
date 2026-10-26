# Training Course Site

A Jekyll site for GitHub Pages built for hands-on training courses. The course is split into **connected sections**; each section contains **lectures** and **step-by-step activities** with knowledge-check questions and copyable command-line code.

The visual theme (mustard on ivory, Futura-style type, hairline cards) follows the Western Region AMD Resources site. The course structure — sections of lectures and practicals, a question bank in `_data`, and a schedule — follows the CDC ID Bioinformatics Workshop site.

## Features

- **Course sidebar** listing every section, lecture, and activity, with the current section expanded
- **Previous / Next links** that run through the whole course in order, across section boundaries
- **Activities as numbered steps** — every `##` heading becomes a step card with a "done" checkbox and a progress bar (saved in the learner's browser)
- **Questions**: typed answers, multiple choice, or open-ended with a sample answer; hints after two wrong tries
- **Terminal-styled code blocks** with a Copy button; `console` blocks copy only the `$` command lines
- **Expected output** blocks, callouts (note, tip, warning, important, checkpoint), collapsible hints and solutions
- Completion check marks in the sidebar, a "Resume" button on the home page, and a schedule page driven by data

## Quick start

### Publish on GitHub Pages

1. Create a new repository and push these files to the `main` branch.
2. In the repository go to **Settings → Pages → Build and deployment** and set **Source** to **GitHub Actions**.
3. The workflow in `.github/workflows/jekyll.yml` builds and deploys the site on every push. It sets `baseurl` automatically.
4. Edit `_config.yml`: `title`, `tagline`, `url`, `baseurl`, `repository_url`, and the footer text.

### Preview locally

Requires Ruby 3.x and Bundler.

```bash
bundle install
bundle exec jekyll serve
```

Then open <http://localhost:4000/training-site/> (use your own `baseurl`).

## How the content is organized

```
_config.yml              site settings and header links
_data/course.yml         the ordered list of sections  ← start here
_data/questions.yml      the question bank
_data/schedule.yml       the Schedule page
sections/<section-id>/
    index.md             section overview   (layout: section)
    *.md                 lectures           (layout: lecture)
                         and activities     (layout: activity)
pages/                   Course overview, Schedule, Resources, About
_posts/                  "Updates" shown on the home page
assets/files/            data files learners download
templates/               copy these to start new pages
```

### Add a section

1. Add an entry to `_data/course.yml` (sections appear in the order listed):

   ```yaml
   - id: assembly
     title: Genome Assembly
     summary: One or two sentences shown on the home page and course overview.
   ```

2. Create `sections/assembly/index.md` from `templates/section-index.md`, with `section: assembly`.

### Add a lecture or activity

Copy `templates/lecture.md` or `templates/activity.md` into the section folder and set:

| Front matter | Purpose |
|--------------|---------|
| `section` | The section `id` it belongs to |
| `order` | Its position in the section (1, 2, 3…) |
| `title`, `description`, `duration` | Shown in headers, lists, and the sidebar |
| `objectives`, `prerequisites` | Shown in the summary box at the top |
| `slides`, `slides_file`, `slides_link`, `video` | Lectures only — optional embedded or linked media |

The sidebar, section page, course overview, home page counts, and previous/next links all update automatically. Links inside front matter are not processed by Liquid, so use relative links there, e.g. `[Setup](../../getting-started/setup/)`.

## Writing activities

**Steps.** Each `## Heading` in an activity becomes a numbered step. Text before the first `##` is the introduction. Add `{: .no-step}` on the line after a heading to end the steps (for a wrap-up):

```markdown
## Wrap-up
{: .no-step}
```

**Commands.** Use `bash` for commands learners run — these get the dark Terminal style:

````markdown
```bash
wc -l samplesheet.csv
```
````

Use `console` to show a prompt with output; the Copy button copies only lines beginning with `$ `.

**Expected output.** Use a `text` block followed by `{: .output}`:

````markdown
```text
4 samplesheet.csv
```
{: .output}
````

**Callouts.** A blockquote followed by a class:

```markdown
> `>` silently replaces an existing file.
{: .warning}
```

Available: `.note`, `.tip`, `.warning`, `.important`, `.checkpoint`.

**Hints and solutions** (collapsed until clicked):

```html
<details class="hint" markdown="1">
<summary>Hint</summary>

Markdown content here.
</details>
```

Use `class="solution"` for worked solutions.

**Links to course files.** `{{ '/assets/files/sample01.fastq' | absolute_url }}` gives a full URL learners can pass to `curl` or `wget`.

## Questions

Add questions to `_data/questions.yml`, then place them anywhere:

```liquid
{% include question.html id="fastq-count-reads" %}
```

```yaml
fastq-count-reads:
  type: text                     # text | choice | open
  question: "How many **reads** are in `sample01.fastq`?"
  answers: ["8", "eight"]        # case, spacing, leading "$ " are ignored
  hint: "Divide the line count by four."
  explanation: "32 lines ÷ 4 = **8 reads**."

fastq-lines-per-record:
  type: choice
  question: "How many lines make up one FASTQ record?"
  options: ["1", "2", "4"]
  answer: 3                      # 1-based number of the correct option

pipes-reflect:
  type: open
  question: "Why chain small commands together?"
  sample_answer: "Each tool does one job well…"
```

One-off questions can also be written inline:

```liquid
{% include question.html type="choice" question="Which command prints your location?"
   options="ls|pwd|cd" answer="2" explanation="`pwd` = print working directory." %}
```

Answers are visible in the page source, so these are for self-checks rather than graded assessment.

## Learner progress

Step checkboxes, lecture completion, open-question notes, and the "Resume" link are stored in the learner's browser (`localStorage`). Nothing is sent to a server, and clearing browser data resets progress.

## Customizing the look

All styling is in `assets/main.scss`. Colors are defined once at the top; the theme deliberately uses two mustards (`#DCAB4F` for fills, `#8B651C` for text and links) and keeps green, red, and purple for callouts and question feedback. Replace `assets/images/logo.svg` with your own logo (or change `logo` in `_config.yml`).
