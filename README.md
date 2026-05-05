# Claude Code Workshop: AI-Powered Literature Review Pipeline

An agentic literature review system built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) and the [Semantic Scholar MCP server](https://github.com/akapet00/semantic-scholar-mcp). Given a seed research idea, this pipeline autonomously searches academic literature, snowballs the bibliography through citation graphs, filters for relevance, synthesises a structured review, and iteratively suggests new search directions, all from a single command inside VS Code.

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
Or alternatively, copy and paste the bits of code you want to use. The entire repository can also be downloaded as a `.zip` archive.

### 2. Open in VS Code

```bash
code .
```
Or alternatively, navigate to the project folder from the VS Code menu: `File -> Open Folder...`.

### 3. Reopen in Dev Container

VS Code will detect the `.devcontainer` configuration and display a prompt in the bottom-right corner:

> **Reopen in Container**

Click it. Docker Desktop will build the container image, install all dependencies (including Claude Code and the Semantic Scholar MCP server), and drop you into a fully configured terminal environment. This happens automatically with no manual setup required.

> **Note:** The first build may take a few minutes while Docker pulls the base image and installs dependencies. Subsequent opens are instant.

### 5. Launch Claude Code

```bash
claude
```
Note that for new projects, you will be prompted to authenticate your Claude account in the browser.

After authentication, you're ready to run the pipeline.

---

## Reusing the Dev Container in a New Project

The entire containerisation and environment setup lives in the `.devcontainer/` directory. To bring this same environment, including Claude Code, the Semantic Scholar MCP server, and all agent definitions, to any new project, simply copy that directory into your new project root:

```bash
cp -r /path/to/claude_code_workshop/.devcontainer /path/to/your-new-project/
```

Open the new project in VS Code and reopen in the container. The environment will be automatically initialised.

---

## Repository Structure

```
claude_code_workshop/
├── .claude/
│   ├── agents/                   # Sub-agent definitions (Markdown + YAML frontmatter)
│   │   ├── literature-search.md  # Searches Semantic Scholar, saves top 10 BibTeX files
│   │   ├── lit_expansion.md      # Snowballs bibliography via references & citations
│   │   ├── lit_filter.md         # Scores and filters papers by relevance
│   │   ├── lit_summary.md        # Writes structured literature review (APA 7)
│   │   └── query_suggest.md      # Recommends 3 new queries from completed review
│   └── commands/
│       └── literature_review.md  # Orchestrator slash command which runs the full pipeline
├── .devcontainer/                # VS Code Dev Container configuration
├── research_notes.md             # Your project's seed idea and accumulated research record
└── README.md                     # This document
```

---

## The Pipeline

The pipeline is built from five specialised sub-agents that Claude Code can invoke independently or chain together through the orchestrator command. Each agent has its own isolated context window, defined tool permissions, and a connection to the Semantic Scholar MCP server at the project level.

```
/literature_review
       │
       ▼
┌─────────────────────┐
│  literature-search  │  Queries Semantic Scholar, enriches metadata,
│                     │  saves top 10 papers by citation count as .bib files
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│   lit-expansion     │  For each seed paper, fetches all references (backwards)
│                     │  and all citing papers (forwards), saves each as a .bib file
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│    lit-filter       │  Reads abstracts, scores every paper 0–10 for relevance
│                     │  to the seed idea, retains papers above threshold
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│    lit-summary      │  Clusters retained papers into themes, synthesises a
│                     │  structured review with APA 7 citations, appends to
│                     │  research_notes.md                                  
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│   query-suggest     │  Analyses the review for gaps, recommends 3 new queries
│                     │  categorised by type, logs everything in research_notes.md
└────────┬────────────┘
         │
         ▼
  [User chooses to loop with a new query, or stops]
```

### Sub-agents

#### `literature-search`
Searches Semantic Scholar for papers matching a query. Runs multiple search phrasings to widen coverage, fetches full metadata (including abstracts) for all candidates, ranks by citation count, and saves the top 10 as individual `.bib` files in `bibtex_output/`. Also logs the query in `research_notes.md`.

**Output:** `bibtex_output/*.bib` (10 files), updated `## Query Log` in `research_notes.md`

#### `lit-expansion`
Reads each seed `.bib` file, extracts the Semantic Scholar paper ID, and performs two API calls per paper: one for its reference list (backwards search ot the papers it cites) and one for its citation list (forward search or the papers that cite it). Every discovered paper is saved as its own `.bib` file. Existing files are never overwritten, making the step safely re-runnable.

**Output:** `bibtex_output/references/*.bib`, `bibtex_output/citations/*.bib`

#### `lit-filter`
Reads the seed idea from `research_notes.md`, then scores every `.bib` file across all three directories (seed, references, citations) against that idea using the paper's abstract. Scores run from 0 (irrelevant) to 10 (central match). Applies an adaptive threshold (default ≥ 7, auto-adjusting if the filtered set would be too large or too small) and writes retained papers to `bibtex_output/filtered/`, adding `relevance_score` and `relevance_reason` fields to each entry. Produces a `FILTER_REPORT.md` with the full score distribution.

**Output:** `bibtex_output/filtered/*.bib`, `bibtex_output/filtered/FILTER_REPORT.md`

#### `lit-summary`
Reads all retained `.bib` files, clusters them into 3–7 thematic groups that emerge from the corpus, and writes a full academic literature review. The review includes an abstract, a thematic introduction, one section per cluster, and a Synthesis and Research Gaps section. All claims are supported by parenthetical APA 7 in-text citations; a complete reference list is appended. The review is appended directly to `research_notes.md` rather than creating a separate file.

**Output:** New `## Literature Review` section appended to `research_notes.md`

#### `query-suggest`
Reads the completed literature review, focusing on the Synthesis and Research Gaps section, and the existing query log, then proposes exactly three new search queries. Each query is categorised (Gap-filling, Temporal, Adjacent domain, Methodological, or Contrastive) and comes with a rationale grounded in the review text, a description of expected yield, and a ready-to-paste pipeline invocation. All recommendations are appended to `research_notes.md` and the query log is updated.

**Output:** New `## Query Recommendations` section and updated `## Query Log` in `research_notes.md`

---

## The Orchestrator Command

### `/literature_review`

The slash command at `.claude/commands/literature_review.md` chains all five sub-agents into a single interactive pipeline. It handles iteration automatically, prompting you between rounds to choose whether to continue.

**Usage inside Claude Code:**

```
/literature_review query="your search query here"
```

If your `research_notes.md` already contains a `## Seed Idea` section, the query argument is optional, the orchestrator will read it from there.

**What it does, step by step:**

1. Derives the project name from the working directory
2. Runs `literature-search` with your query
3. Runs `lit-expansion` to snowball the bibliography
4. Runs `lit-filter` to score and prune
5. Runs `lit-summary` to write the review into `research_notes.md`
6. Runs `query-suggest` to propose three next queries
7. **Pauses and presents the three suggested queries**, asking whether you want to:
   - Select one of the suggested queries and loop (re-running steps 2–7 with the new query)
   - Type a custom query and loop
   - Type `stop` to finish

Each iteration clears the `bibtex_output/` working directories and runs fresh, while `research_notes.md` accumulates every review, query log entry, and recommendation across all rounds, building a full record automatically.

**Example session:**

```
> /literature_review query="diffusion models for protein structure prediction"

[literature-search]  ✅ Saved 10 BibTeX files to ./bibtex_output/
[lit-expansion]      ✅ 143 references, 87 citations saved
[lit-filter]         ✅ 54 papers retained (threshold ≥ 7)
[lit-summary]        ✅ Review appended to research_notes.md
[query-suggest]      ✅ 3 queries recommended

════════════════════════════════════════════════════
  Literature review complete for iteration 1.

  Suggested queries for the next iteration:

    [1] "score-based generative models protein design"  (Methodological)
        Score-based diffusion is mentioned in the gaps section but
        not yet searched directly.

    [2] "protein structure prediction benchmarks 2023 2024"  (Temporal)
        Coverage is sparse for work published after AlphaFold2.

    [3] "molecular dynamics force fields machine learning"  (Adjacent domain)
        Several retained papers cite MD simulation as a validation
        approach not yet represented in the corpus.

  Would you like to continue with a new query?

    • Type 1, 2, or 3 to run the pipeline with that query
    • Type a custom query to use your own
    • Type "stop" (or press Enter) to finish
════════════════════════════════════════════════════
```

---

## `research_notes.md`

This file is the persistent research record for your project. It is read by multiple agents (to retrieve the seed idea and query log) and written to by multiple agents (to append reviews, recommendations, and log entries). It is never overwritten, only appended to.

A typical `research_notes.md` starts with:

```markdown
# Research Notes: my_project

## Seed Idea
A brief description of the research question or topic you want to explore.
```

After running the pipeline, it will contain a full `## Literature Review`, `## Query Recommendations`, and `## Query Log` for every iteration you've run.

---

## Output Directory Layout

```
bibtex_output/
├── 01_attention_is_all_you_need.bib      # Seed papers (top 10 by citation count)
├── 02_bert_pre_training_of_deep_bidi.bib
├── ...
├── references/                           # Backwards search (papers cited by seeds)
│   ├── some_paper.bib
│   └── ...
├── citations/                            # Forward search (papers citing seeds)
│   ├── another_paper.bib
│   └── ...
└── filtered/                             # Relevance-filtered papers
    ├── FILTER_REPORT.md                  # Score distribution and exclusion log
    ├── high_relevance_paper.bib          # Each file includes relevance_score + reason
    └── ...
```

---

## Notes and Tips

- **The Semantic Scholar MCP server is registered at the project level** (`.mcp.json` in the repo root). Sub-agents inherit it through the `mcpServers: semantic-scholar` frontmatter field with no system-level registration needed.
- **All agents use `model: opus`** for the intellectually demanding tasks (filtering and summarisation) and **`model: sonnet`** for search and expansion, balancing quality and cost.
- **Running the pipeline on a niche topic** may yield fewer than 20 candidate papers in the search step. The agent will automatically retry with alternative phrasings before giving up.
- **The filter threshold is adaptive**: it targets a filtered set of 10–100 papers. Very broad topics may raise the threshold to ≥ 8; very niche topics may lower it to ≥ 5.
- **`bibtex_output/` is cleared between pipeline iterations** but `research_notes.md` is never cleared. All reviews and logs accumulate there across sessions.

---

## Acknowledgements

- [Semantic Scholar MCP server](https://github.com/akapet00/semantic-scholar-mcp) by @akapet00
- [Semantic Scholar API](https://www.semanticscholar.org/product/api) by the Allen Institute for AI
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) by Anthropic
