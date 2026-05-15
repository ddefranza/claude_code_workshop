---
name: get-recommended
description: Reads Semantic Scholar paper IDs from BibTeX filenames in ./literature, fetches recommendations for each, exports BibTeX for each new paper, saves them to ./literature, and logs all recommendations to ./logs/03_recommended_log.md. Skips papers already present.
tools: Read, Write, mcp__semantic-scholar__get_recommendations, mcp__semantic-scholar__export_bibtex
---

List all `.bib` files in `./literature`. Extract the Semantic Scholar paper ID from each filename (the filename stem is the paperId).

For each paperId:
1. Call `mcp__semantic-scholar__get_recommendations("paperId")`.
2. For each returned paper:
   - If `./literature/<paperId>.bib` already exists, skip it.
   - Call `mcp__semantic-scholar__export_bibtex(paper_ids=paperId, include_abstract=True)`.
   - Save the result as `./literature/<paperId>.bib`.

Write `./logs/03_recommended_log.md` appending each saved BibTeX entry in this format:

```md
## Recommendations Log

### Source: <source paperId>
<bibtex entry>
<bibtex entry>
...
```

Do nothing else.