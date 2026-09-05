---
name: Planning Doc
description: Generate a structured planning document — problem framing, scope, requirements, design, tradeoffs, decisions, risks, and test plan
---

# Planning Doc

## Overview

Generate a comprehensive planning document for a coding project. Think of this
as a pre-design doc — it captures everything needed before significant
implementation starts. The output should be a single markdown document that a
team can review, discuss, and sign off on.

If the user hasn't provided a concrete project yet, ask: *"What project or
feature do you want to plan? Give me a one-sentence summary of the goal."*

## Sections to produce

Work through each section below in order. Every section must be present; if a
section genuinely has nothing to say (e.g. no data modeling for a pure
infrastructure change), write "N/A — <reason>" rather than omitting it.

**Important for LLM-executed plans:** Sections 1–6 are the *analysis* phase.
Sections 7–8 are the *executable* phase — they must be precise enough that
an LLM agent (or a junior engineer) could implement from them without asking
frequent clarifying questions. Skimping on section 7 is the most common
failure mode.

### 1. Problem & Outcome

State the concrete problem and the desired outcome as user or system behavior
changes. Be specific enough that someone could later verify "did we achieve
this?"

**Format:**
- **Current state:** What happens today (including pain points or gaps).
- **Desired outcome:** What happens after this work — name the actors and the
  behavior change.
- **Success signals:** Observable, ideally measurable indicators (e.g. "P50
  latency drops below 200ms", "support ticket volume for X decreases by 50%",
  "users can complete flow Y in one session").

### 2. Scope

**In scope:** Bulleted list of what this project will deliver. Be precise about
boundaries — e.g. "only the read path; writes are in a follow-up", "only the
web UI; mobile is out".

**Out of scope (explicit):** Bulleted list of things a reader might reasonably
expect but that are intentionally deferred or cut. This is where you pre-empt
the "why didn't you also…" questions.

### 3. Requirements

Split into two sub-sections.

**Product expectations:** Functional requirements visible to the user or caller.
- What must the feature do? What are the happy-path and edge-case behaviors?
- What are the user-facing acceptance criteria?

**Engineering constraints:** Non-negotiable constraints on the implementation.
- APIs — what interfaces must be satisfied (internal RPC, REST, GraphQL,
  webhook contract, etc.).
- Performance — any latency or throughput floors/ceilings.
- Security — authn/authz model, data sensitivity classification, audit
  requirements.
- Rollout — gradual rollout strategy (feature flag, percentage ramp, canary),
  rollback plan.

### 4. Scale & Constraints

Quantify the expected load so the design is not accidentally under-scaled.

| Dimension | Expected | Peak | Source/Assumption |
|---|---|---|---|
| QPS / throughput | | | |
| Data volume (rows, objects, storage) | | | |
| Concurrent users / connections | | | |
| Growth rate (6mo, 12mo) | | | |
| Latency target (P50 / P99) | | | |

If a dimension is unknown, flag it as a risk rather than guessing
optimistically. If the system is very small (e.g. a CLI tool), state "N/A —
single-user, no server component" and move on.

### 5. Data Modeling

Describe the core concepts the system manipulates and how they are represented.

- **Key types / schemas:** For each important concept, show a condensed schema
  (or a type definition) rather than full prose. Use code blocks.
- **Validation boundaries:** What invariants are enforced at write time vs read
  time? What happens when data violates them?
- **Deferred modeling:** If something is intentionally stored as a loose blob /
  JSON column / untyped field now because the shape isn't settled, say so and
  note when it should be locked down.
- **Identifiers and references:** How are entities identified and linked?
- **Storage:** Where does this data live (DB, cache, filesystem, external
  service)?

### 6. Approach

High-level design. This is where you describe *how* the system works.

- **Architecture overview:** 2–5 sentence summary of the design. Name the key
  components and how they interact.
- **Flow description:** Step through the happy path and 1–2 key edge cases as a
  numbered sequence of operations. Include which component does what.
- **Diagram:** If useful, include a text/ASCII diagram or reference an external
  diagram link. For mermaid-style diagrams, produce the mermaid block inline.

### 7. Implementation Details

Translate the approach into a concrete, executable code plan. This section is
what bridges "how it works" to "what to type." Be specific enough that an LLM
agent or a new engineer could implement without asking frequent clarifying
questions.

**File / module plan:** List every file that needs to be created or modified.
For each, state its responsibility and what key symbols (functions, classes,
types) it exports or contains. Order by dependency — what must exist first.

```markdown
| File | Action | Responsibility | Key exports |
|---|---|---|---|
| `src/planner/types.ts` | Create | Shared types and interfaces | `PlanDoc`, `Section`, `Scope` |
| `src/planner/sections.ts` | Create | Section generators | `buildScope()`, `buildRequirements()` |
| `src/cli.ts` | Modify | Add `--plan` flag | — |
```

**Key interfaces & signatures:** Show the actual function signatures, class
constructors, and type definitions that form the backbone of the implementation.
Use code blocks. Don't show every helper — show the contracts that multiple
files depend on.

```typescript
// Example — adapt to your language
interface PlannerConfig {
  model: string;
  outputDir: string;
  sections: SectionId[];
}

async function generatePlan(context: ProjectContext, config: PlannerConfig): Promise<PlanDoc>
```

**Data flow at call-site level:** Trace how a request / command / event moves
through the code. Specifically: which function calls which, what is returned,
and where branching happens.

```
CLI entry (cli.ts:main)
  → Planner.run(context)
    → gatherContext(context)          // collects repo info
    → SectionBuilder.buildAll(...)     // iterates sections
      → buildScope(...) → returns Scope
      → buildRequirements(...) → returns Requirements
    → Formatter.format(plan)          // writes markdown
```

**Implementation order:** Numbered steps that respect dependency order. Each
step should be independently buildable and testable.

1. Define shared types in `types.ts` — no dependencies.
2. Build `gatherContext()` — reads from filesystem, no other code needed.
3. Build section generators one at a time (start with Problem & Outcome since
   it has no cross-dependencies).
4. Build `Formatter` — consumes types, no section generator imports needed.
5. Wire CLI flag and main entry point.
6. Write integration test that calls end-to-end.

**Configuration & environment:** Every env var, config file entry, or feature
flag the implementation needs.

| Key | Type | Default | Purpose |
|---|---|---|---|
| `PLANNER_MODEL` | string | `gpt-4` | Model to use for section generation |
| `PLANNER_OUTPUT` | string | `./PLAN.md` | Output path for the plan doc |

**New dependencies:** Any libraries or tools that need to be added.

| Package | Why |
|---|---|
| `yaml` | Parse `.planrc` config files |
| `marked` | Render markdown AST for validation |

**Migration / data changes:** Schema migrations, data backfills, or
seed-data changes required. If none, say "None."

### 8. Proportionality

State the simplest viable approach and the explicit tradeoffs being made.

- **Simplest approach:** What's the minimal implementation that satisfies the
  requirements and scale constraints? If the answer is "the approach in section
  6 already is the simplest," restate it in one sentence.
- **What we are NOT building (and why):** Tradeoffs are commitments. Name the
  complexity you're explicitly passing on — e.g. "no caching layer — current
  scale doesn't warrant it; we revisit at 10x QPS", "no eventual-consistency
  reconciliation because writes are single-actor", "no admin UI — we use raw DB
  access for now".
- **Future pressure points:** What is the first thing that breaks as load grows?
  This is the inverse of "what we are not building" — it tells the next engineer
  when to re-architect.

### 9. Decisions (pre-implementation)

Choices that are hard to reverse and should be locked before large
implementation spend. Each decision should have a one-sentence rationale.

- **API boundaries & contracts:** e.g. "The service exposes a single
  `POST /v1/plan` endpoint; internal module boundaries are not exposed."
- **Persistence choices:** e.g. "Using Postgres with a single `plans` table;
  no materialized views yet."
- **Cross-service contracts:** e.g. "The billing service sends a
  `subscription.cancelled` webhook; we consume it idempotently."
- **Unresolved blockers:** Things that must be decided before implementation can
  start. Listed explicitly with who needs to decide.

### 10. Risks & Open Questions

Bulleted list. Each entry is either:
- A **risk** — something that could go wrong, with rough likelihood and
  impact, and any mitigation.
- An **open question** — a decision that is explicitly not yet made and blocks
  or shapes the design.

Format: `[Risk|Question] <one-sentence description> [mitigation or owner]`

### 11. Test Plan

What will be tested and how.

| Layer | Coverage | Method |
|---|---|---|
| Unit tests | Core logic, validation, edge cases | Automated (jest / vitest / pytest) |
| Integration | Cross-component flows, DB queries | Automated with test containers or similar |
| E2E / smoke | Full user-facing flow | Automated (Playwright / Cypress) or manual checklist |
| Manual | Exploratory, visual regression, unusual hardware | Human QA |

Call out what won't be tested and why (e.g., "The error-recovery path is
difficult to simulate; we rely on manual staging drills until Q3").

## Output

Write the planning document in markdown with the sections above as top-level
headings. Use tables for structured data (scale, test plan, decisions). Use
code blocks for schemas and flow steps. The document should be reviewable by
another engineer or a PM without needing additional context.

After writing the document, ask: *"I have a complete planning doc. Do you want
to save it to a file, share it, or refine any section?"*
