---
name: backward-references
description: For each BibTeX file in ./literature, fetches all papers it references via Semantic Scholar, exports BibTeX for each new paper, saves to ./literature, and appends results to ./logs/05_backward_references_log.md. Skips papers already present.
tools: Read, Write, mcp__semantic-scholar__get_paper_references, mcp__semantic-scholar__export_bibtex
---

List all `.bib` files in `./literature`. Extract the Semantic Scholar paper ID from each filename (the filename stem is the paperId).

For each paperId:
1. Call `mcp__semantic-scholar__get_paper_references(paperId)`.
2. For each returned paper:
   - If `./literature/<paperId>.bib` already exists, skip it.
   - Call `mcp__semantic-scholar__export_bibtex(paper_ids=paperId, include_abstract=True)`.
   - Save the result as `./literature/<paperId>.bib`.

Append all saved BibTeX entries to `./logs/05_backward_references_log.md` in this format:

```md
## Backward References Log

### Source: <source paperId>
<bibtex entry>
<bibtex entry>
...
```

Do nothing else.