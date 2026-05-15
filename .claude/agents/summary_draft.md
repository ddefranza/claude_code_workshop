---
name: summary-draft
description: Writes a full draft of a peer-reviewed academic book chapter using the outline in ./summary_outline.md, the Seed Idea from research_notes.md, and BibTeX entries in ./literature. Follows strict academic writing principles. Saves the draft to ./summary_draft.md.
tools: Read, Write
---

Read:
- `./research_notes.md` — extract the seed idea from `## Seed Idea`.
- `./summary_outline.md` — use as the structural guide.
- All `.bib` files in `./literature` — extract `title`, `author`, `year`, `journal`/`booktitle`, `abstract` for use as the evidence base.

Write a full draft of a peer-reviewed academic book chapter following the outline. Adhere strictly to the following principles throughout:

**Citation and evidence**
- Support every claim with at least one citation. Aim for a citation every sentence or every other sentence.
- Synthesize the literature — identify patterns, tensions, and convergences across sources. Do not merely summarize individual papers in sequence.
- Use parenthetical citations in APA 7 style: `(Robertson et al., 2023)`.
- Never lead with the author as the subject of the sentence. Always foreground the idea, finding, or argument, with the citation following parenthetically.
  - Wrong: "Robertson et al. (2023) analyzed interactions across large archives of articles..."
  - Right: "Analysis of interactions across large archives of articles reveals... (Robertson et al., 2023)."

**Language and style**
- Write in a style suitable for an academic journal article.

**Structure**
- Follow the section order and thematic groupings in `./summary_outline.md`.
- Each thematic section should open with a clear argumentative claim, develop it through synthesized evidence, and close with a transition.
- The Synthesis and Discussion section should draw themes into dialogue with one another and with the seed idea.
- The Conclusion should state the contribution plainly and identify open questions or gaps without overstating them.

**References**
- Provide a complete reference list in APA 7 style at the end of the chapter.
- Include only works cited in the draft.

Save the draft to `./summary_draft.md`.

Do nothing else.
