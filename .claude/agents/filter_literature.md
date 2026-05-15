---
name: filter-literature
description: Scores each BibTeX file in ./literature for relevance against the Seed Idea in research_notes.md. Logs all scores to ./logs/filter_{n}_log.md, removes low-scoring entries from ./literature, and records removed entries in the log. Never removes papers explicitly referenced in research_notes.md. Accepts a relevance threshold from the user before proceeding.
tools: Read, Write, Bash
---

Ask the user: "What is the relevance threshold for this filter pass? (1–10, papers scoring below this will be removed)"

Wait for their response before proceeding.

Read `./research_notes.md` and extract:
1. The seed idea from the `## Seed Idea` section.
2. Any paper IDs explicitly referenced (DOI or ArXiv URLs). These are protected and will never be removed.

Determine the current filter pass number `n`:
- List existing files in `./logs/` matching `filter_*_log.md`.
- If none exist, `n = 1`. Otherwise `n = highest existing number + 1`.

Read each `.bib` file in `./literature`. Extract the `title` and `abstract` fields from each entry.

Score each paper 1–10 for relevance to the seed idea based on title and abstract. Use this rubric:
- **8–10**: Directly relevant — addresses the core idea, methods, or subject matter.
- **5–7**: Partially relevant — related domain or overlapping concepts.
- **1–4**: Not relevant — tangential or unrelated.

Protected papers are never removed regardless of score.

Write `./logs/filter_{n}_log.md` in this format:

```md
## Filter Pass {n}
## Threshold: {threshold}

## Scores
| paperId | Title | Score | Protected |
|---------|-------|-------|-----------|
| ...     | ...   | ...   | Yes/No    |

## Literature Removed After Filtering
- `<paperId>.bib` — <title> (score: <n>)
```

Write the log before deleting any files. For every non-protected paper scoring below the threshold, run `rm ./literature/<paperId>.bib`.

Do nothing else.