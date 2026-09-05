---
name: dependency-bump-validation
description: Validates whether a dependency version bump is safe to adopt by reading changelogs, mapping changes to repo usage, and running build and tests read-only. Use when a dependency was updated, when reviewing lockfile or package manifest diffs, or when the user asks to validate, assess, or sign off on a dependency upgrade.
---

# Dependency bump validation

Perform a **read-only** validation: infer versions, gather release notes, assess relevance to this codebase, run build and tests, then deliver a structured recommendation. **Do not edit source files** during this workflow.

## Constraints

- **No source changes** — read, search, and run commands only.
- If the correct build or test command is **ambiguous** (multiple scripts, monorepo packages), **ask** before running destructive or long-running commands.
- If release notes are missing or relevance is unclear, **state that explicitly** — do not invent changelog items or API facts.
- When uncertain about an API or behavior, **say so** and suggest how to verify (docs link, minimal repro, grep patterns).

## Phase 1 — Understand the bump

1. From the diff, lockfile, or manifest: identify **package name**, **old version**, **new version**.
2. Infer **package manager** and **ecosystem** from repo root (e.g. `package.json` + `package-lock.json` → npm; `pnpm-lock.yaml` → pnpm; `Cargo.toml` → Rust; `pyproject.toml` → Python; etc.).

## Phase 2 — Fetch and read release notes

Cover **all versions after old through new inclusive** (i.e. exclusive of old, inclusive of new).

**Sources (try in order):**

1. Vendored in repo: `CHANGELOG.md`, `CHANGELOG`, `RELEASES.md`, `HISTORY.md`, or under `node_modules/<pkg>/` when present and trustworthy for a quick scan.
2. Upstream: GitHub/GitLab **Releases** or tagged changelog in the repo.
3. Registry: npm, PyPI, crates.io, RubyGems, etc. (changelog or “Release notes” links).

If nothing is accessible, **say so** and continue with version diffs, typecheck, or runtime signals from build/tests.

## Phase 3 — Assess relevance to this repo

1. Search for **imports**, **requires**, **config** references, and **CLI** usage of the dependency (and subpaths if relevant).
2. Cross-check changelog items against **what this repo actually uses**:
   - **Breaking** removals or signature changes on **called** APIs → `[BREAKING]`
   - **Deprecated** APIs still used → `[DEPRECATED]` (note replacement if documented)
   - **New required** config, env vars, or peer deps → tag appropriately
   - **Security** fixes (CVEs, advisories) → **`[SECURITY]`** (always high-priority)
   - **Behavior** changes on exercised code paths → `[BEHAVIOR]`
   - No overlap → `[NONE]` for that item

If mapping changelog → usage is **not confident**, say so and list what you could not verify.

## Phase 4 — Run the build

Infer from `package.json` scripts, `Makefile`, `Cargo.toml`, `pyproject.toml`, etc. Run the **primary production build** (or the project’s documented CI equivalent).

Report **PASS | FAIL** and summarize **new** errors/warnings vs. a pre-bump baseline **only if** a baseline is known; otherwise report what appeared.

## Phase 5 — Run the tests

Run the **full** test suite the project uses (e.g. `npm test`, `pnpm test`, `cargo test`, `pytest`). If multiple suites exist and scope is unclear, **ask**.

Report: **PASS | FAIL**, **total tests** if printed, **failed count**, and **error messages** for new failures. Baseline delta only when determinable.

## Phase 6 — Final recommendation

Use this structure (fill every section):

```markdown
DEPENDENCY: <name> <old_version> → <new_version>

CHANGELOG HIGHLIGHTS:
- <notable change>
- ...

RELEVANCE TO THIS REPO:
- <finding> [BREAKING|DEPRECATED|SECURITY|BEHAVIOR|NONE]
- ...

BUILD: PASS | FAIL
TEST SUITE: PASS | FAIL (<X failed, Y total> or unknown if not reported)

RECOMMENDATION: SAFE TO MERGE | NEEDS ATTENTION | BLOCK
REASON: <1–3 sentences on deciding factors>

ACTION ITEMS (if any):
- <specific follow-up: code change, config, env, or verification step>
```

### Recommendation rubric

| Verdict | When |
|--------|------|
| **SAFE TO MERGE** | Build and tests pass; no applicable breaking/security issues for this repo’s usage; or only benign changes. |
| **NEEDS ATTENTION** | Deprecations, behavior shifts worth confirming, test flakiness, or warnings that should be tracked before/after merge. |
| **BLOCK** | Build or tests fail; confirmed breaking API in use; missing required config; critical unresolved security impact for this usage. |

## Quick checklist

- [ ] Versions and ecosystem identified
- [ ] Release notes scanned for the full semver range (or gap documented)
- [ ] Usage in repo mapped to changelog
- [ ] Build run and outcome recorded
- [ ] Full test suite run and outcome recorded
- [ ] Final block filled with honest uncertainty where needed

