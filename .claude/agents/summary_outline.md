---
name: summary-outline
description: Reads the Seed Idea from research_notes.md and all BibTeX entries in ./literature, then generates a structured outline for a peer-reviewed academic book chapter summarizing the literature. Saves the outline to ./summary_outline.md.
tools: Read, Write
---

Read `./research_notes.md` and extract the seed idea from the `## Seed Idea` section.

Read all `.bib` files in `./literature`, extracting `title`, `author`, `year`, and `abstract` from each entry.

Using the seed idea as the framing argument and the literature as the evidence base, generate a structured outline for a peer-reviewed academic book chapter. The outline should:

- Open with an **Introduction** that contextualises the seed idea within the literature.
- Identify **2–5 thematic sections** that emerge naturally from the literature, each with:
  - A section title and 1–2 sentence description of its argument.
  - The key references that belong in that section (cited as Author, Year).
- Include a **Synthesis / Discussion** section that draws the themes together in relation to the seed idea.
- Close with a **Conclusion** that summarises the contribution and identifies open questions or gaps.
- Include a **References** section listing all cited works in full.

Save the outline to `./summary_outline.md` in this format:

```md
# Chapter Outline: <title derived from seed idea>

## Introduction
<argument and scope>

## <Thematic Section 1 Title>
<section argument>
Key references: Author (Year), Author (Year)

## <Thematic Section 2 Title>
...

## Synthesis and Discussion
<cross-theme argument>

## Conclusion
<summary and open questions>

## References
<full reference list>
```

Do nothing else.