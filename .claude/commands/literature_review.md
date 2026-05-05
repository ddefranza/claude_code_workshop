# Literature Review Pipeline

Run the full literature review pipeline for this project: search → expand → filter → summarise → suggest new queries, then optionally loop.

## Usage

```
/literature_review query="<your search query>"
```

The project name is inferred from the current directory name.

---

## Pipeline

### Step 1 — Establish project context

Derive the project name from the current working directory:

```bash
basename $(pwd)
```

The search query comes from the `query` argument supplied in the invocation. If no `query` argument was provided, read `research_notes.md` and check for a `## Seed Idea` section — use that text as the query. If neither is available, ask the user for a query before proceeding.

---

### Step 2 — Literature search

Invoke the `literature-search` subagent:

```
Use the literature-search agent for project "<project_name>" with query "<query>"
```

Wait for it to complete before proceeding.

---

### Step 3 — Literature expansion

Invoke the `lit-expansion` subagent:

```
Use the lit-expansion agent to expand the bibliography
```

Wait for it to complete before proceeding.

---

### Step 4 — Literature filter

Invoke the `lit-filter` subagent:

```
Use the lit-filter agent for the project "<project_name>"
```

Wait for it to complete before proceeding.

---

### Step 5 — Literature summary

Invoke the `lit-summary` subagent:

```
Use the lit-summary agent for the project "<project_name>"
```

Wait for it to complete before proceeding.

---

### Step 6 — Query suggestion

Invoke the `query-suggest` subagent:

```
Use the query-suggest agent for the project "<project_name>"
```

Wait for it to complete and read its output. The subagent will have appended three recommended queries to `research_notes.md` and printed them to the console.

---

### Step 7 — Present options to the user

Display the three suggested queries clearly, numbered, with their category and rationale summary. Then present the following prompt **and stop — do not proceed until the user responds**:

```
════════════════════════════════════════════════════
  Literature review complete for iteration N.

  Suggested queries for the next iteration:

    [1] "<query 1>"  (Gap-filling)
        <one-line rationale>

    [2] "<query 2>"  (Methodological)
        <one-line rationale>

    [3] "<query 3>"  (Adjacent domain)
        <one-line rationale>

  Would you like to continue with a new query?

    • Type 1, 2, or 3 to run the pipeline with that query
    • Type a custom query to use your own
    • Type "stop" (or press Enter) to finish
════════════════════════════════════════════════════
```

---

### Step 8 — Handle the user's response

**If the user types `stop`, presses Enter, or gives any indication they want to finish:**

Print:
```
✅ Literature review complete.
   Project      : <project_name>
   Iterations   : <N>
   Queries used : <list of all queries run this session>
   Notes file   : <project_name>/research_notes.md
```
Then stop.

**If the user selects query 1, 2, or 3, or types a custom query:**

- Set `query` to the selected or typed query.
- Increment the iteration counter.
- Clear `bibtex_output/references/` and `bibtex_output/citations/` so the expansion step starts fresh for the new query (the seed files in `bibtex_output/` are also replaced by the new search):

  ```bash
  rm -rf bibtex_output/references bibtex_output/citations bibtex_output/filtered
  rm -f bibtex_output/*.bib
  ```

- Return to **Step 2** and run the full pipeline again with the new query.

---

## Notes

- The `## Query Log` in `research_notes.md` accumulates entries across all iterations. It is never cleared between loops.
- The `## Literature Review` and `## Query Recommendations` sections in `research_notes.md` also accumulate — each iteration appends a new section, building a growing research record.
- If any subagent fails, print the error and ask the user whether to retry that step or abort the pipeline.
