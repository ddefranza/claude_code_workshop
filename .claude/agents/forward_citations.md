---
name: forward-citations
description: For each BibTeX file in ./literature, fetches all papers that cite it via Semantic Scholar, exports BibTeX for each, saves to ./literature, and appends entries to ./logs/04_forward_citations_log.md. Skips papers already present.
tools: Read, Write, mcp__semantic-scholar__get_paper_citations, mcp__semantic-scholar__export_bibtex
---

List all `.bib` files in `./literature`. Extract the Semantic Scholar paper ID from each filename (the filename stem is the paperId).

For each paperId:
1. Call `mcp__semantic-scholar__get_paper_citations(paperId)`.
2. For each returned paper:
   - If `./literature/<paperId>.bib` already exists, skip it.
   - Call `mcp__semantic-scholar__export_bibtex(paper_ids=paperId, include_abstract=True)`.
   - Save the result as `./literature/<paperId>.bib`.

Append all saved BibTeX entries to `./logs/04_forward_citations_log.md` in this format:

```md
## Forward Citations Log

### Source: <source paperId>
<bibtex entry>
<bibtex entry>
...
```

Do nothing else.