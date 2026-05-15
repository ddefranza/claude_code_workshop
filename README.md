# Claude Code Workshop: AI-Powered Literature Review Pipeline

An agentic literature review system built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) and the [Semantic Scholar MCP server](https://github.com/akapet00/semantic-scholar-mcp). Given a seed research idea and optional seed references, this pipeline autonomously builds a bibliography through Semantic Scholar's API, expands it via related papers, recommendations, forward citations, and backward references, filters for relevance at each stage, verifies every entry for accuracy, synthesises a structured academic chapter, audits all citations, and exports a Word document — all from a single command inside VS Code.

---

## Requirements

Before cloning this repository, make sure you have the following installed and running:

- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** — must be installed *and actively running* in the background before opening the project
- **[Visual Studio Code](https://code.visualstudio.com/)** — with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/ddefranza/claude_code_workshop.git
cd claude_code_workshop
```

Or alternatively, copy and paste the parts you want to use. The entire repository can also be downloaded as a `.zip` archive.

### 2. Open in VS Code

```bash
code .
```

Or navigate to the project folder from the VS Code menu: `File -> Open Folder...`.

### 3. Reopen in Dev Container

VS Code will detect the `.devcontainer` configuration and display a prompt in the bottom-right corner:

> **Reopen in Container**

Click it. Docker Desktop will build the container image, install all dependencies (including Claude Code and the Semantic Scholar MCP server), and drop you into a fully configured terminal environment. This happens automatically with no manual setup required.

> **Note:** The first build may take a few minutes while Docker pulls the base image and installs dependencies. Subsequent opens are instant.

### 4. Launch Claude Code

```bash
claude
```

For new projects, you will be prompted to authenticate your Claude account in the browser. After authentication, you are ready to run the pipeline.

---

## Reusing the Dev Container in a New Project

The entire containerisation and environment setup lives in the `.devcontainer/` directory. To bring this same environment — including Claude Code, the Semantic Scholar MCP server, and all agent definitions — to any new project, copy that directory into your new project root:

```bash
cp -r /path/to/claude_code_workshop/.devcontainer /path/to/your-new-project/
```

Open the new project in VS Code and reopen in the container. The environment will be automatically initialised.

---

## Repository Structure

```
claude_code_workshop/
├── .claude/
│   ├── agents/                         # Sub-agent definitions (Markdown + YAML frontmatter)
│   │   ├── initialize.md               # Creates ./literature and ./logs directories
│   │   ├── search_initialization.md    # Fetches seed references from research_notes.md
│   │   ├── get_related.md              # Fetches up to 50 related papers per seed
│   │   ├── get_recommended.md          # Fetches Semantic Scholar recommendations per seed
│   │   ├── forward_citations.md        # Fetches all papers that cite each entry
│   │   ├── backward_references.md      # Fetches all papers referenced by each entry
│   │   ├── filter_literature.md        # Scores and filters papers by relevance threshold
│   │   ├── bibtex_expand.md            # Fills missing metadata fields via web search
│   │   ├── bibtex_audit.md             # Verifies accuracy of all BibTeX entries
│   │   ├── summary_outline.md          # Generates a structured chapter outline
│   │   ├── summary_draft.md            # Writes a full academic chapter draft
│   │   ├── citation_audit.md           # Audits all in-text citations and references
│   │   └── export_docx.md              # Converts summary_draft.md to .docx via pandoc
│   └── commands/
│       └── literature_review.md        # Orchestrator slash command — runs the full pipeline
├── .devcontainer/                      # VS Code Dev Container configuration
├── research_notes.md                   # Your seed idea and any seed references
└── README.md                           # This document
```

---

## Preparing `research_notes.md`

Before running the pipeline, edit `research_notes.md` to include your seed idea. The pipeline reads from this file at multiple stages.

A minimal starting point:

```md
# Research Notes

## Seed Idea
A brief description of the research question or topic you want to explore.
```

To seed the bibliography with specific papers you already know, include their DOI or ArXiv URLs in the `## Seed Idea` section:

```md
## Seed Idea
This review explores transformer-based models for consumer text classification.

Seed references:
- https://doi.org/10.18653/v1/N19-1423
- https://arxiv.org/abs/1907.11692
```

The `search-initialization` agent will detect these URLs, resolve them via Semantic Scholar, and save them as the starting `.bib` files before any expansion begins.

---

## The Pipeline

The pipeline chains thirteen specialised sub-agents through a single orchestrator command. Each agent has its own isolated context window, defined tool permissions, and a connection to the Semantic Scholar MCP server. The pipeline applies progressively stricter relevance filtering as the bibliography grows, then verifies and writes before exporting.

```
/literature_review
        │
        ▼
┌─────────────────────────┐
│       initialize        │  Creates ./literature and ./logs directories
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  search-initialization  │  Extracts seed references from research_notes.md,
│                         │  fetches BibTeX via Semantic Scholar
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│       get-related       │  Fetches up to 50 related papers per seed entry
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│   filter-literature     │  Relevance filter — threshold ≥ 5
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│     get-recommended     │  Fetches Semantic Scholar recommendations per entry
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│   filter-literature     │  Relevance filter — threshold ≥ 5
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│    forward-citations    │  Fetches all papers that cite each entry (forward search)
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│   filter-literature     │  Relevance filter — threshold ≥ 7
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│   backward-references   │  Fetches all papers referenced by each entry (backward search)
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│   filter-literature     │  Relevance filter — threshold ≥ 8
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│     bibtex-expand       │  Fills missing metadata fields via web search
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│      bibtex-audit       │  Verifies accuracy of all entries; flags PASS or FAIL
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│     summary-outline     │  Clusters literature into themes; writes chapter outline
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│      summary-draft      │  Writes full academic chapter draft with APA 7 citations
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│     citation-audit      │  Audits in-text citations and reference list; flags PASS or FAIL
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│      export-docx        │  Converts summary_draft.md → summary_draft.docx via pandoc
└─────────────────────────┘
```

---

## Sub-Agents

### `initialize`

Creates the `./literature` and `./logs` subdirectories in the project directory. This step runs first and is safe to re-run — it will not overwrite existing content.

**Output:** `./literature/`, `./logs/`

---

### `search-initialization`

Reads `./research_notes.md` and extracts any DOI or ArXiv URLs from the `## Seed Idea` section. Parses each URL into a Semantic Scholar paper ID, fetches full BibTeX with abstract, and saves each as `./literature/<paperId>.bib`. Skips any paper already present. If no URLs are found, the agent stops without error and the pipeline continues from the next step.

**Output:** `./literature/<paperId>.bib` (one per seed reference), `./logs/01_search_initialization_log.md`

---

### `get-related`

Reads all `.bib` filenames in `./literature`, extracts the Semantic Scholar paper ID from each filename stem, and calls `get_related_papers` for each with a limit of 50. Saves each new paper as a `.bib` file. Skips papers already present.

**Output:** `./literature/<paperId>.bib` (new files only), `./logs/02_get_related_log.md`

---

### `get-recommended`

Reads all paper IDs from `./literature` filenames and calls `get_recommendations` for each. Exports and saves BibTeX for each new recommended paper. Skips papers already present.

**Output:** `./literature/<paperId>.bib` (new files only), `./logs/03_recommended_log.md`

---

### `forward-citations`

Reads all paper IDs from `./literature` filenames and calls `get_paper_citations` for each, fetching all papers that cite each entry in the corpus. Exports and saves BibTeX for each new paper. Skips papers already present.

**Output:** `./literature/<paperId>.bib` (new files only), `./logs/04_forward_citations_log.md`

---

### `backward-references`

Reads all paper IDs from `./literature` filenames and calls `get_paper_references` for each, fetching all papers that each entry itself cites. Exports and saves BibTeX for each new paper. Skips papers already present.

**Output:** `./literature/<paperId>.bib` (new files only), `./logs/05_backward_references_log.md`

---

### `filter-literature`

Reads the seed idea from `./research_notes.md` and scores every `.bib` file in `./literature` on a 1–10 relevance scale using title and abstract. Before filtering, asks the user for a relevance threshold. Papers scoring below the threshold are deleted from `./literature`. Papers explicitly referenced by URL in `./research_notes.md` are protected and never removed regardless of score. Determines the current filter pass number automatically from existing log files.

The pipeline runs this agent four times with increasing thresholds (5, 5, 7, 8) as the bibliography grows through successive expansion stages.

**Scoring rubric:**
- 8–10: Directly relevant — addresses the core idea, methods, or subject matter
- 5–7: Partially relevant — related domain or overlapping concepts
- 1–4: Not relevant — tangential or unrelated

**Output:** `./logs/filter_{n}_log.md` (score table and removal record), deleted `.bib` files

---

### `bibtex-expand`

Reads every `.bib` file in `./literature` and checks for missing required fields appropriate to each entry type — title, author, year, journal, volume, number, pages, DOI, publisher, and arXiv fields where applicable. Performs web searches to locate missing values and updates files in place. Does not modify fields that are already present.

**Output:** Updated `.bib` files in `./literature`, `./logs/06_bibtex_expand_log.md`

---

### `bibtex-audit`

Reads every `.bib` file in `./literature` and verifies each entry for existence, author name spelling and order, exact title match, publication year, and journal/volume/page accuracy via web search. Records all issues to `./logs/reference_report.md` with a PASS or FAIL status. On FAIL, the pipeline re-runs `bibtex-expand` for flagged entries and removes any unverifiable entries before continuing.

**Output:** `./logs/reference_report.md`

---

### `summary-outline`

Reads the seed idea from `./research_notes.md` and all `.bib` files in `./literature`. Generates a structured outline for a peer-reviewed academic chapter, identifying 2–5 thematic groupings that emerge from the corpus. Saves the outline to `./summary_outline.md`.

**Output:** `./summary_outline.md`

---

### `summary-draft`

Reads the seed idea, the outline in `./summary_outline.md`, and all `.bib` entries in `./literature`. Writes a full draft of a peer-reviewed academic chapter following the outline structure. Enforces strict academic writing principles throughout: every claim is supported by at least one citation, the literature is synthesised rather than summarised sequentially, all citations use APA 7 parenthetical style, and the prose follows the style recommendations of Strunk and White. Saves the draft to `./summary_draft.md`.

**Citation style enforced:**
- Parenthetical APA 7: `(Author et al., Year)`
- No author-led constructions: the idea or finding is always foregrounded, with the citation following

**Output:** `./summary_draft.md`

---

### `citation-audit`

Reads `./summary_draft.md` and extracts all in-text citations and reference list entries. Cross-references `./literature` as the primary source of truth, performing web searches only where a BibTeX entry appears erroneous or is absent. Checks every reference for existence, author name accuracy, exact title match, year, journal details, and correct APA 7 formatting. Checks every in-text citation for a matching reference list entry and correct parenthetical format. Records all issues to `./logs/citation_report.md` with a PASS or FAIL status. On FAIL, the pipeline corrects each flagged error directly in `./summary_draft.md` before continuing.

**Output:** `./logs/citation_report.md`

---

### `export-docx`

Converts `./summary_draft.md` to `./summary_draft.docx` using pandoc.

**Output:** `./summary_draft.docx`

---

## The Orchestrator Command

### `/literature_review`

The slash command at `.claude/commands/literature_review.md` chains all thirteen sub-agents into a single automated pipeline.

**Usage inside Claude Code:**

```
/literature_review
```

The command reads your seed idea and any seed references directly from `./research_notes.md`. No query argument is required.

**What it does, step by step:**

1. Runs `initialize` to create project directories
2. Runs `search-initialization` to fetch any seed references from `research_notes.md`
3. Runs `get-related` to fetch up to 50 related papers per seed entry
4. Runs `filter-literature` at threshold ≥ 5
5. Runs `get-recommended` to fetch Semantic Scholar recommendations
6. Runs `filter-literature` at threshold ≥ 5
7. Runs `forward-citations` to fetch all citing papers
8. Runs `filter-literature` at threshold ≥ 7
9. Runs `backward-references` to fetch all referenced papers
10. Runs `filter-literature` at threshold ≥ 8
11. Runs `bibtex-expand` to fill missing metadata
12. Runs `bibtex-audit`; on FAIL, corrects and cleans before continuing
13. Runs `summary-outline` to generate the chapter structure
14. Runs `summary-draft` to write the full chapter
15. Runs `citation-audit`; on FAIL, corrects errors in `summary_draft.md` before continuing
16. Runs `export-docx` to produce the final Word document

On completion, the pipeline reports: total papers retained in `./literature`, filter passes applied and papers removed at each pass, any issues auto-corrected at steps 12 and 15, and the location of the final output.

**Example completion report:**

```
Pipeline complete.

Literature corpus: 43 papers in ./literature

Filter passes:
  Pass 1 (threshold 5, after get-related):       removed 31 papers
  Pass 2 (threshold 5, after get-recommended):   removed 18 papers
  Pass 3 (threshold 7, after forward-citations): removed 47 papers
  Pass 4 (threshold 8, after backward-refs):     removed 29 papers

BibTeX audit: 2 entries corrected (author name, DOI), 1 unverifiable entry removed.
Citation audit: 3 formatting issues corrected, 0 unverifiable citations.

Final output: ./summary_draft.docx
```

---

## Output Directory Layout

```
./
├── research_notes.md          # Your seed idea and accumulated research record
├── summary_outline.md         # Chapter outline generated by summary-outline
├── summary_draft.md           # Full chapter draft generated by summary-draft
├── summary_draft.docx         # Final Word document exported by export-docx
├── literature/
│   ├── <paperId>.bib          # One BibTeX file per retained paper (with abstract)
│   └── ...
└── logs/
    ├── 01_search_initialization_log.md
    ├── 02_get_related_log.md
    ├── 03_recommended_log.md
    ├── 04_forward_citations_log.md
    ├── 05_backward_references_log.md
    ├── 06_bibtex_expand_log.md
    ├── filter_1_log.md         # Score table and removals for each filter pass
    ├── filter_2_log.md
    ├── filter_3_log.md
    ├── filter_4_log.md
    ├── reference_report.md     # BibTeX audit results (PASS / FAIL)
    └── citation_report.md      # Citation audit results (PASS / FAIL)
```

---

## Notes and Tips

- **The Semantic Scholar MCP server is registered at the project level** (`.mcp.json` in the repo root). Sub-agents inherit it through their `mcp__semantic-scholar__*` tool declarations with no system-level registration needed.
- **Filenames in `./literature` are Semantic Scholar paper IDs.** Every expansion agent reads IDs from filenames rather than from BibTeX content, so the naming convention is load-bearing. Do not rename `.bib` files manually.
- **Filter thresholds are cumulative, not independent.** Each filter pass operates on the corpus as it stands after the previous expansion. The thresholds rise (5 → 5 → 7 → 8) because the corpus becomes progressively less focused as expansion moves further from the seed papers.
- **Protected papers are never removed.** Any paper referenced by URL in the `## Seed Idea` section of `research_notes.md` is preserved through all filter passes regardless of its relevance score.
- **`bibtex-expand` and `bibtex-audit` are complementary.** `bibtex-expand` fills missing fields; `bibtex-audit` verifies the accuracy of what is present. Running expand before audit means the audit has the most complete possible record to check.
- **The citation audit reads `./literature` first.** Web searches are only performed when a BibTeX entry appears erroneous or is absent, which keeps the audit fast and grounded in the verified corpus.
- **Running on a niche topic** may yield a small corpus after the first filter pass. This is expected. The `get-recommended` and `forward-citations` stages frequently recover additional relevant papers even when the initial related-papers search is thin.

---

## Acknowledgements

- [Semantic Scholar MCP server](https://github.com/akapet00/semantic-scholar-mcp) by @akapet00
- [Semantic Scholar API](https://www.semanticscholar.org/product/api) by the Allen Institute for AI
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) by Anthropic
