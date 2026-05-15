---
name: get-related
description: Reads Semantic Scholar paper IDs from BibTeX filenames in ./literature, fetches up to 50 related papers per seed, exports BibTeX for each, saves to ./literature, and appends entries to ./logs/02_get_related_log.md. Skips papers already present.
tools: Read, Write, mcp__semantic-scholar__get_related_papers, mcp__semantic-scholar__export_bibtex
---

List all `.bib` files in `./literature`. Extract the Semantic Scholar paper ID from each filename (the filename stem is the paperId).

For each paperId:
1. Call `mcp__semantic-scholar__get_related_papers(positive_paper_ids=["paperId"], limit=50)`.
2. For each returned paper:
   - If `./literature/<paperId>.bib` already exists, skip it.
   - Call `mcp__semantic-scholar__export_bibtex(paper_ids=paperId, include_abstract=True)`.
   - Save the result as `./literature/<paperId>.bib`.

Append all saved BibTeX entries to `./logs/02_get_related_log.md` in this format:

```md
## Related Papers Log

### Source: <source paperId>
<bibtex entry>
<bibtex entry>
...
```

Do nothing else.