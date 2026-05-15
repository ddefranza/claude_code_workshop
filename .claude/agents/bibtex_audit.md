---
name: bibtex-audit
description: Audits each BibTeX file in ./literature for accuracy — verifying existence, author names, title, year, and publication details via web search. Records all issues and a summary to ./logs/reference_report.md. Flags PASS or FAIL status for the main session.
tools: Read, Write, WebSearch
---

Read each `.bib` file in `./literature`.

For each entry, verify the following via web search as needed:

1. **Existence**: The paper or source actually exists and is findable.
2. **Authors**: Names are spelled correctly and listed in the correct order.
3. **Title**: The title matches the actual published title exactly.
4. **Year**: The publication year is correct.
5. **Publication details**: Journal name, volume, issue, and page numbers are correct where given.

For each issue found, record it. For entries that cannot be verified after searching, record them separately.

Write `./logs/reference_report.md` in this format:

```md
## Reference Issues Found

### [Author, Year] - [Issue Type]
* Problem: [describe the error precisely]
* Correct information: [provide the verified correct details]
* Action required: [correction to make in the bib file]

## Unverifiable References
[List any references that could not be verified after searching, with reason]

## Summary
* Total references checked: N
* Issues found: N
* Unverifiable: N
* Status: [Pass | Fail]
```

If status is **Fail**, append to the summary:

```md
The main session must correct errors by either:
- Removing the `.bib` file from ./literature if unverifiable.
- Running the bibtex-expand agent for entries with correctable errors.
```

If status is **Pass**, append as the final line:

```md
All references verified.
```

Do nothing else.