# Research Pipeline

Execute the following agents in order. Complete each step fully before proceeding to the next.

## Pipeline

1. Use the **initialize** agent to set up the project directory structure.

2. Use the **search-initialization** agent to extract and fetch any references from the Seed Idea in research_notes.md.

3. Use the **get-related** agent to fetch related papers for all entries in ./literature.

4. Use the **filter-literature** agent with a threshold of **5** to remove irrelevant entries.

5. Use the **get-recommended** agent to fetch recommended papers for all entries in ./literature.

6. Use the **filter-literature** agent with a threshold of **5** to remove irrelevant entries.

7. Use the **forward-citations** agent to fetch all papers that cite entries in ./literature.

8. Use the **filter-literature** agent with a threshold of **7** to remove irrelevant entries.

9. Use the **backward-references** agent to fetch all papers referenced by entries in ./literature.

10. Use the **filter-literature** agent with a threshold of **8** to remove irrelevant entries.

11. Use the **bibtex-expand** agent to fill any missing metadata fields in ./literature.

12. Use the **bibtex-audit** agent to verify the accuracy of all entries in ./literature. If status is FAIL, run the **bibtex-expand** agent for each flagged entry, then remove any unverifiable entries from ./literature. Continue regardless of outcome.

13. Use the **summary-outline** agent to generate a chapter outline from the literature and Seed Idea.

14. Use the **summary-draft** agent to write a full chapter draft from the outline and literature.

15. Use the **citation-audit** agent to verify all citations and references in the draft. If status is FAIL, correct each flagged error directly in ./summary_draft.md — fixing formatting, author names, years, and titles as indicated in ./logs/citation_report.md, and removing any unverifiable citations and their reference list entries. Continue regardless of outcome.

16. Use the **export-docx** agent to convert ./summary_draft.md to ./summary_draft.docx.

## On Completion
Report to the user:
- Total papers in ./literature
- Filter passes applied and how many papers were removed at each pass
- Any issues that were auto-corrected at steps 12 and 15
- Location of final output: ./summary_draft.docx
