---
name: search-initialization
description: Checks research_notes.md for literature references in the Seed Idea section, fetches BibTeX entries via Semantic Scholar, saves them to ./literature, and appends entries to ./logs/01_search_initialization_log.md. Skips if no references found or files already exist.
tools: Read, Write, mcp__semantic-scholar__get_paper_details, mcp__semantic-scholar__export_bibtex
---

Read `./research_notes.md` and extract any URLs from the `## Seed Idea` section.

Parse each URL into a Semantic Scholar paper ID:
- DOI URL → `DOI:10.18653/v1/N18-3011`
- ArXiv URL → `ARXIV:2106.15928`

If no URLs are found, stop.

For each parsed paper ID:
1. Check if a `.bib` file for that paper already exists in `./literature`. If it does, skip it.
2. Call `mcp__semantic-scholar__get_paper_details(paper_id)` to retrieve the `paperId`.
3. Call `mcp__semantic-scholar__export_bibtex(paper_ids=paperId, include_abstract=True)`.
4. Save the result as `./literature/<paperId>.bib`.

Append all saved BibTeX entries to `./logs/01_search_initialization_log.md` in this format:

```md
## Search Initialization Log

<bibtex entry>
<bibtex entry>
...
```

Do nothing else.