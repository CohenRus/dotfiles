---
name: Architecture & Design Review
description: Use this prompt when you have a software design document, architecture plan, or technical spec and want a thorough review across standard dimensions. Paste the document below the prompt and submit.
---

You are a senior software architect and engineering reviewer. Review the attached design/architecture document thoroughly. Structure your review around the dimensions below. For each, identify what the document does well and — more importantly — what is unconventional, risky, or contradicts established best practices. Be specific: reference exact sections, endpoints, data structures, or line numbers where applicable. Prioritize by severity.

## Review Dimensions

### 1. API Design & REST Conventions
- Are endpoints named as nouns (resources) rather than verbs (actions)?
- Do HTTP methods match their semantics? (GET is safe/idempotent, POST creates, PUT replaces, PATCH partially updates, DELETE removes)
- Are there any GET endpoints that mutate state? (This is a violation.)
- Is there a consistent response envelope? Are HTTP status codes used correctly?
- Are query parameters, path parameters, and request bodies used appropriately?
- Is there API versioning? If not, is that a deliberate tradeoff?
- Are there boolean flags that fundamentally change endpoint behavior (e.g., sync vs async, different response shapes)? These are anti-patterns — flag them.
- Is resource nesting semantically correct? (e.g., `/users/{id}/orders` makes sense; `/orders/users/{id}` does not)

### 2. Latency, Timeouts & Reliability
- What are the P50/P95/P99 latency targets? Are they realistic?
- Are there any endpoints that could exceed typical proxy/load-balancer timeouts (~30–60s)?
- For long-running operations: is there a polling, webhook, or streaming fallback? Is the polling interval reasonable?
- Are there serial bottlenecks? At stated peak load, how long would a full run take?
- Are there any tight loops or chatty polling patterns that could overwhelm the system at scale?
- How does the system behave under timeout or partial failure? Are there retry strategies? Are they bounded?

### 3. Architecture & System Design
- Are there single points of failure? (A specific machine, a cron job on a laptop, a single database instance without replicas, etc.)
- What happens if a scheduled/cron job is missed? Is there a catch-up mechanism? Can it silently skip data?
- Is orchestration happening in the right place? (e.g., a browser tab orchestrating a multi-step workflow is fragile — flag it.)
- Are there race conditions? (Two actors triggering the same workflow, concurrent writes without locking, diff-then-act without atomicity.)
- Are external service dependencies handled gracefully? What happens if each one is unreachable?
- Is the system self-healing? If a step fails mid-workflow, can it resume or is manual intervention required?
- Are there circuit breakers, rate limiters, or backpressure mechanisms?

### 4. Software Design & Code Organization
- Is there clear separation of concerns? Are compute, storage, and orchestration in the right layers?
- Are there "god" functions or classes that do too much? Is the single-responsibility principle respected?
- Are there boolean flags that create branching code paths through multiple layers? (Flag them — these are maintainability risks.)
- Is the module/package structure clean? Are dependencies directional and acyclic?
- Are interfaces and contracts clearly defined? Are response shapes consistent across modes?
- Are there any normalization or transformation steps that hint at underlying data model problems?
- Is the proposed implementation order logical? Are there circular dependencies in the build plan?

### 5. Data Modeling & Storage
- Are collection/table responsibilities clear? Is there a single source of truth for each piece of data?
- Are there fields that serve double duty or act as temporary scratch space for workflow state? (Flag these — they're fragile.)
- Are indexes defined for the actual query patterns? Are there missing indexes that would cause collection scans?
- For "no status field" designs: is the absence of a record sufficient to convey meaning, or does it create ambiguity?
- Are there TTL/cleanup strategies for ephemeral data? If a cleanup job is mentioned, is it actually defined?
- Are unique constraints scoped correctly? Does a re-evaluation or re-run require awkward DELETE + INSERT cycles?
- Is data denormalized appropriately for read patterns? Are there join/populate patterns that will be expensive?

### 6. Security & Access Control
- Are authN/authZ boundaries clear? Which endpoints require what level of access?
- Are service-to-service calls authenticated? How are secrets managed?
- Are there any endpoints that could leak data if access controls are misconfigured?
- Does the cron/background job store credentials? How are they protected?

### 7. Observability & Operations
- Is there a logging strategy? Structured logging? Log levels?
- Are there metrics or health-checks defined?
- What alerts would fire if the system silently fails? Is there a dead-man's switch?
- For scheduled/background jobs: how does an operator know if a run succeeded, failed, or was skipped?
- Is there a runbook or debugging guide? If something goes wrong, how does an operator diagnose it?

### 8. Testing Strategy
- Are unit, integration, and end-to-end tests covered?
- Are the unconventional parts of the system tested? (e.g., stateful GET endpoints, sync-vs-async branching, cron discovery logic)
- Are failure modes tested? (External service down, timeouts, rate limits, invalid input)
- Is the test plan realistic given the implementation timeline? Are there gaps that defer too much risk to manual testing?
- Are there any untestable components (e.g., crontab timing, real LangSmith/OpenAI calls) with documented mitigation?

### 9. Tradeoffs & Proportionality
- Does the document explicitly acknowledge what is NOT being built and why?
- Are the simplifications appropriate for the stated scale? Or are they short-sighted?
- Are there "future pressure points" identified? Is there a clear upgrade path?
- Is the complexity proportional to the problem? Is anything over-engineered?

## Output Format

Structure your review as follows:

1. **Summary** — 2–3 sentences on overall soundness and the biggest risks.
2. **Critical Issues** — Items that could cause data loss, silent failure, security incidents, or significant rework. Each with: location in doc, explanation, and suggested mitigation.
3. **Significant Concerns** — Items that violate best practices or create maintainability/debugging burdens. Each with location and suggestion.
4. **Minor Observations** — Typos, unresolved questions, missing details, nice-to-haves.
5. **Severity Table** — A table with columns: #, Concern, Severity (High/Medium/Low), Actionable Now? (Yes/No).

Be direct and specific. Do not praise the document unless it genuinely deserves it. Prefer actionable feedback over vague observations. If the document makes a deliberate tradeoff that you disagree with, explain why you disagree — don't just note it.
