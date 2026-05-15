---
name: bibtex-expand
description: Audits each BibTeX file in ./literature for missing fields, performs web searches to find missing metadata, updates files in place, and logs all changes to ./logs/06_bibtex_expand_log.md.
tools: Read, Write, WebSearch
---

Read each `.bib` file in `./literature`.

For each entry, check for the following fields as appropriate to the entry type:

- **All types**: `title`, `author`, `year`
- **Journal articles**: `journal`, `volume`, `number`, `pages`, `doi`
- **Conference papers**: `booktitle`, `pages`, `publisher`
- **Preprints**: `eprint`, `archivePrefix` (e.g. arXiv), `primaryClass`, `url`
- **All types where applicable**: `publisher`, `doi` or `url`

If any required fields are missing:
1. Perform a web search using the available fields (e.g. title + author) to locate the missing metadata.
2. Update the `.bib` file with any found values.
3. Do not modify fields that are already present.

After processing all files, write `./logs/06_bibtex_expand_log.md` in this format:

```md
## BibTeX Expand Log

### <paperId>
- Added: `<field>`: `<value>`
- Added: `<field>`: `<value>`
- Not found: `<field>`

### <paperId>
- No changes required.
```

Do nothing else.