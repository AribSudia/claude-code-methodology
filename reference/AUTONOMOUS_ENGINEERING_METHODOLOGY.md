# Autonomous Engineering & Product-Led Growth Methodology (AEPG)

> A framework-agnostic standard operating procedure for running an AI engineer as an
> autonomous, self-pacing contributor that discovers, ships, verifies, and integrates
> high-value change — and knows when to stop, escalate, or hand off.
>
> **In CCM:** this is the reference behind the `/arib-engine` skill. The skill is the
> runnable engine; this doc is the rationale + the hard-won lessons + the honest risk
> caveats. AEPG is the *runtime behavioral loop*; CCM is the *substrate* it runs on
> (skills, agents, fail-closed hooks, memory, the wave overlay). See ADR-026.

---

## 0. Operating Mandate & Preconditions

The whole engine ignites from one durable instruction: **"take over as the expert."**
That grant means the agent owns the *what-next* and the *when-done* decisions on
engineering merit — it does not wait to be told each step, and it does not defer the
"is it done?" judgment back to the human.

Before the loop starts, three things must exist (create them if absent):

1. **Guardrails (standing constraints)** — invariants never violated without sign-off:
   - Never break compliance/tax/financial behavior unilaterally → *escalate*.
   - Never push unverifiable change (e.g. blind lockfile churn) → *verify or escalate*.
   - Never weaken security; never commit secrets.
   - Additive/back-compatible schema only without a migration plan.
   - Don't delete; archive. Don't gold-plate; scope tightly.
   - *(In CCM these live in `architecture/CONSTRAINTS.md` and are hook-enforced.)*
2. **Verification gates** — the objective, automatable definition of "good": type-check,
   lint, tests + coverage, schema/contract drift, build smoke. (See §4.)
3. **A persistent memory store** — durable notes that survive context resets, so the
   agent compounds knowledge instead of relearning. (CCM: `memory/*.md` + `io/ledger/`.)

If any are missing, **Phase A establishes them first.** A loop without gates is a loop
that ships regressions confidently.

---

## 1. The Core Operating Loop

Every iteration is the same six beats. Keep them small; one coherent change per turn.

```
   ORIENT ──▶ DISCOVER ──▶ DECIDE ──▶ ACT ──▶ VERIFY ──▶ INTEGRATE ──▶ RECORD
      ▲                                                                   │
      └───────────────────────────── (self-pace) ◀───────────────────────┘
```

- **Orient** — read current state (VCS status, open work, memory, brief, constraints).
- **Discover** — find the highest-value next thing (a real bug, gap, or improvement). (§3)
- **Decide** — Ship / Escalate / Decline, by §6. *Verify the claim before acting on it.*
- **Act** — make the smallest coherent change that fully resolves one concern. (§5)
- **Verify** — run the gates; for high-stakes change, add adversarial verification. (§4)
- **Integrate** — land it without destabilizing the trunk. (§5)
- **Record** — update memory + carry-forwards so the next iteration starts informed. (§7)

### Self-pacing (the autonomous loop mechanics)

The agent must not block a human to know when to run next.

- **Event-gated** (preferred): the next iteration is triggered by an *observable signal* —
  CI finishing, a PR merging, a log line. Arm a background watcher for that signal.
- **Time-gated (heartbeat)**: when there is no event to wait on, schedule a wake-up. Lean
  long (20–30 min) for idle ticks; short only when polling fast-changing state. A
  heartbeat is also the *fallback* behind every event-gate.

> **In CCM, scheduling is delegated to `/loop`** (the canonical Anthropic scheduler) —
> `/loop /arib-engine <goal>`. The engine does not reinvent `ScheduleWakeup`; it owns
> only WHAT each tick does. Unattended running is bounded by `operations/AUTONOMY_MODE.md`
> caps.

---

## 2. The Macro Arc (Phases)

| Phase | Goal | Output |
|------|------|--------|
| **A — Orient & Map** | Understand system, constraints, gates, history | Recorded model; gates confirmed runnable |
| **B — Discover** | Surface candidate work across many lenses | Ranked candidate list (§3) |
| **C — Triage & Verify** | Separate real findings from false positives | Confirmed, severity-ranked backlog |
| **D — Execute** | Resolve one concern per focused unit | A self-contained, reversible change (§5) |
| **E — Gate** | Prove correctness objectively | Green gates + adversarial sign-off (§4) |
| **F — Integrate** | Land without destabilizing trunk | Merged on blocking-green (§5) |
| **G — Record** | Compound knowledge; track carry-forwards | Updated memory/backlog (§7) |
| **H — Decide closure** | Stop, escalate, or continue — on evidence | Next loop, or a decision list (§6, §8) |

The arc is **fractal**: a single PR runs D→E→F→G; a sweep runs B→C→(D→E→F→G)×N; a
campaign runs A→…→H many times until §6.5's closure test passes.

---

## 3. The Discovery Engine — Adversarial Multi-Dimensional Sweeps

Sweep the system through **distinct, named lenses**, one dimension at a time, so coverage
is legible and exhaustive.

### 3.1 Dimension catalog (adapt per project)

Security/authz (IDOR, tenant isolation) · State machines & lifecycle · Money math &
tax/regulatory correctness · Input validation & bounds · Performance (N+1, over-fetch,
indexes) · Resilience (timeouts, retries, idempotency, error isolation) · Data integrity
(cascades, orphans, soft-delete) · Accessibility · i18n/localization bleed ·
SEO/discoverability · Dependency & supply-chain security · Test-coverage gaps on critical
paths · Product-led-growth surfaces.

### 3.2 The find → refute → confirm pattern

1. **Find** — multiple independent searchers, each blind to the others, surface
   candidates. Ground them with *real anchors* (actual paths, prior findings) and an
   *exclusion list* (already-shipped/known) so they don't hallucinate or repeat.
2. **Refute** — independent skeptics that **default to "not a bug"** and try to disprove.
   Keep a finding only if a majority confirm AND it isn't already-handled or intentional.
   Use *diverse lenses* per finding (real? reachable? intentional?).
3. **Confirm** — dedup, rank by severity, and **verify each survivor against the actual
   code yourself**. Adversarial agents reduce noise; they do not replace the final
   ground-truth read.
4. **Loop until dry** — keep sweeping until consecutive rounds surface nothing new.

> **CCM adaptations (see §A risk caveats):** same-model skeptics have *correlated* errors
> — agreement ≠ independence; vary the lens per skeptic. And the reject-biased majority
> filter does **not** apply to security/authz/tenant-isolation/money/secrets: there a
> false negative is catastrophic, so a single credible finding escalates to a mandatory
> ground-truth read, never dropped by majority vote.

### 3.3 When to fan out vs. go solo

Fan out (parallel agents/Workflow) when **broad** (many files, multiple angles) or
**high-stakes** (needs corroboration). Go solo for a single-file fact, a precise
mechanical edit, or an empirical task whose *verification is the build itself* (a
dependency bump proven by type-check + tests — spawning agents to "assess" what the
compiler proves is ceremony).

**Drill deeper (the fetcher) — depth on demand.** Sweeps give breadth; some findings need
depth before a decision. When one finding is still unclear after `confirm` — root cause
unknown, skeptics split, reachability uncertain, or a high-stakes class (where drilling is
*mandatory*) — run a focused single-finding deep-dive: trace to source, map blast radius,
reproduce, pull `git`/incident history, inspect real data. Bound it: stop at REAL /
false-positive / escalate; don't rabbit-hole, and don't drill trivial or compiler-provable
findings (that's the ceremony above). The output is an evidence bundle that feeds the
decision and the pre-merge reconciliation.

---

## 4. Verification Gates — The Quality Bar

A change is done only when **proven**. Layer cheap+fast → expensive+thorough:

1. **Static** — type-check (strict) + lint, **whole-project** (the compiler finds the
   consumer you missed — sync→async ripples, dangling imports).
2. **Tests + coverage** — new behavior ships with a *genuine* regression test, never padding.
3. **Contract/schema drift** — assert generated artifacts match source; regenerate + commit.
4. **Build smoke** — compiles/bundles in a production-like mode.
5. **Adversarial verification (high-stakes only)** — for money/auth/security/compliance,
   an *independent* reviewer re-derives the result and tries to break it before merge.

### 4.1 Hard-won gate lessons (CCM: codified in CONSTRAINTS.md #14–#16)

- **Verify the composed result, not just the part** — re-run the full gate set on the
  *integrated trunk* before declaring done.
- **Environment-stability is a gate** — run timezone/locale-sensitive logic under the CI
  environment (e.g. `TZ=UTC`) *before* pushing. (A real day-bucketing bug hid locally and
  surfaced only under CI's TZ.)
- **Prove backward compatibility on data-touching change** — capture a real artifact from
  the *old* version, prove the *new* version still reads it, lock that proof in a
  regression test.
- **Make failure loud, not silent** — prefer designs where a mistake is an obvious,
  catchable error over one that quietly returns wrong data.
- **Don't re-verify what the harness already guarantees** — if the edit tool errored on a
  mismatch, the edit applied; don't re-read to "confirm."

---

## 5. The Unit of Work — The Focused, Reversible PR

Ship **small, single-concern, individually-verified, independently-revertable** units.
One PR = one coherent fix or feature. Top-down by severity.

- **Self-contained** — branch from trunk; reviewable cold. Don't bundle unrelated changes.
- **Honest, structured description** — what, why, risk, how-verified, and any inference or
  limitation called out ("SQL reasoned + reviewed but not run against a live DB —
  recommend a staging check").
- **Disciplined hygiene** — conventional commit; required trailers; never commit secrets.
- **Merge on blocking-green only** — distinguish *blocking* gates from *known-flaky/
  non-blocking* checks; refuse on a blocking failure (leave the PR open, never merge red).
- **Keep the trunk deployable at every merge.**

> **CCM refines the "automate the merge" default (v3.12.0).** CCM auto-merges by default,
> but gates it on the **`verification-agent`** (intent ↔ implementation reconciliation),
> not on CI alone: merge fires only on a RECONCILED verdict + green blocking checks. A GAP
> re-engineers; HOLD goes to a human. High-stakes classes
> (money/auth/compliance/secrets/breaking-migration) ALWAYS hold for a human, and
> `--hold-merge` holds everything. Branch protection (CONSTRAINTS #10/#17) still governs.
> See §A.

---

## 6. Decision Frameworks

### 6.1 Ship vs. Escalate vs. Decline
- **Ship** when: within mandate, fully verifiable, resolves a *real* confirmed issue / clear value.
- **Escalate** (present options + a recommendation; don't decide) when: a business/
  compliance/policy decision, a secret/credential you can't hold, an infra choice with
  unverifiable blast radius, or a breaking framework migration. **Default to escalate on
  compliance/tax/security** — the dangerous cases are the ones the agent fails to
  recognize as boundaries.
- **Decline** (and say why) when: false positive, intended behavior, coverage padding,
  gold-plating, or churn whose risk exceeds its value.

### 6.2 Verify before fixing
Every reported issue — including ones an adversarial agent "confirmed" — is a *claim until
checked against the code*. Reject false positives loudly.

### 6.3 No unverifiable churn
If you cannot prove a change is safe, do **not** ship it on faith. Find the clean,
verifiable path or escalate with specifics. *(A risky `tar@7` override on a native build
chain was declined in favor of a clean upstream upgrade that removed the dependency —
same outcome, fully verifiable.)*

### 6.4 Scope discipline / no gold-plating
Resolve the concern; don't expand it. Adjacent cosmetic improvement is *noted*, not
auto-shipped.

### 6.5 The closure test — deciding "done" on evidence
"Done" is justified when: the high-value backlog is exhausted (sweeps return only
false-positives / already-handled / by-design), **and** everything remaining needs an
operator decision or external action, **and** a final composed-trunk verification is green.

> **Honest caveat:** "diminishing returns" measures *the agent's search distribution*
> running dry, not the absence of bugs. Bug classes outside the lens catalog never lower
> the signal. Report closure as "this campaign's lenses are exhausted," not "the codebase
> is clean."

When the test passes, **own the call**: state it with evidence, hand off the decision list
(§8), stop the loop, and stand down — ready to re-engage.

---

## 7. State & Memory

- **Persist facts, not chatter.** Operator preferences (with the *why*); project state not
  derivable from code/VCS; pointers to external resources. (CCM: `memory/*.md`.)
- **Track backlogs and carry-forwards.** Each sweep: a backlog note (confirmed / shipped /
  declined-with-reason). Each campaign: carry-forwards (open operator decisions +
  deploy-time actions), kept accurate — mark resolved so a future session doesn't chase a
  stale TODO.
- **Keep an index** so recall is cheap; one line per entry; detail in topic files.
- **Each unit of work is self-contained** — understandable without the conversation.

---

## 8. Escalation & Hand-off

Produce a **decision list**, not a vague "blocked." For each item: the specific question,
options with trade-offs, your recommendation, and what you've already de-risked. Separate:

- **Decisions** (need a human choice): compliance interpretation, framework majors,
  pricing/policy, risk acceptance.
- **Deploy-time actions** (code ready; human executes): inject secrets, run migrations,
  run a staging validation.

Make re-engagement frictionless: the human says "do X" and you pick it up cold.

---

## 9. The Product-Led Growth Dimension

Treat growth as first-class discovery dimensions, run through the *same* loop/gates/PR
discipline:

- **Frictionless activation** — minimize time-to-value; try-before-commit; then convert.
- **Discoverability as a pull channel** — SEO-correct public surfaces (structured data,
  canonical/OG, server-rendered + cached landing/directory pages, sitemaps).
- **Conversion-path integrity** — revenue-critical lifecycles (checkout, payment,
  subscription) get the deepest coverage, strictest gates, and a11y on the path.
- **Honest growth mechanics** — referral/affiliate, trials, pricing — no dark patterns.
- **Measure, then build** — gate growth bets on evidence.

> **But growth surfaces are business bets, not pure correctness.** Pricing, paywalls, and
> refund logic carry revenue/legal/dark-pattern risk that type-check + tests cannot
> establish. Ship the *engineering* autonomously; **escalate the product/pricing decision**
> (§6.1). CI-green is not permission to change pricing.

---

## 10. Instantiating AEPG on a New Project

1. **Establish the mandate & guardrails** (§0) — write the standing constraints down.
2. **Define the gates** (§4) — wire type-check, lint, tests+coverage, contract-drift,
   build smoke into a CI that labels blocking vs. non-blocking checks.
3. **Seed memory** (§7) — project brief, constraints, key file map.
4. **Pick the first dimensions** (§3) — security + critical-path correctness first; then
   performance, a11y, i18n, growth, deps.
5. **Run the loop** (§1) — discover → triage → one focused verified PR → merge → record →
   repeat, self-paced. *(In CCM: open the PR; merge-to-main stays a human/branch-protection
   gate unless reconciliation + checks are green and it's not a high-stakes class.
   CONSTRAINTS #17.)*
6. **Escalate cleanly** (§8) at every business/compliance/infra boundary.
7. **Apply the closure test** (§6.5) — stop on evidence, hand off the decision list.

In CCM, steps 1–3 are largely the bootstrap (`bootstrap/RUN.md`); the loop is `/loop
/arib-engine`; the gates are the L3 hooks + CI.

---

## 11. Anti-Patterns

- Merge on red, or merge without gates.
- **Auto-merge to main by default / treat CI-green as release authority.**
- Ship unverifiable change on faith (blind `audit fix --force`, untested risky overrides).
- Bundle unrelated concerns into one PR.
- "Fix" a reported issue without verifying it's real.
- **Let a reject-biased majority suppress a plausible security/authz finding.**
- Unilaterally change compliance/tax/pricing/security behavior.
- Gold-plate; manufacture low-value churn to look busy.
- Defer the "is it done?" judgment to the human when the evidence decides it.
- Let the loop idle-poll and burn cost instead of event-gating with a fallback heartbeat.
- Lose hard-won knowledge by not recording it.

---

## Appendix A — Provenance & known risks (read before trusting this wholesale)

AEPG was reverse-engineered from **one** executed campaign (a multi-tenant SaaS, ~60
CI-green PRs across 10+ dimensions). That is an honest n=1 from the *survivors* — it does
not include the PRs that regressed, the bugs that escaped the gates, or the bug classes
the lenses never found. Treat the **structure** as reusable and the **specifics** as
illustrative, validated in the regime: small-to-mid SaaS, fast comprehensive CI, single
agent, low concurrency.

Three claims in the source method are load-bearing risks; CCM neutralizes them:

1. **Auto-merge on CI-green *alone* is not a safe default.** Raw CI-green converts a
   fallible advisory signal into release authority — only as safe as the weakest gate.
   CCM's fix (v3.12.0) is not to ban auto-merge but to **gate it on reconciliation**: the
   `verification-agent` must return RECONCILED (the change actually fulfilled its intent)
   on top of green blocking checks before merge fires; a GAP re-engineers, HOLD escalates.
   High-stakes classes (money/auth/compliance/secrets/breaking-migration) ALWAYS hold for a
   human, `--hold-merge` holds everything, and branch protection (CONSTRAINTS #10/#17) is
   never bypassed. The lesson stands — CI-green is not release authority — but the remedy
   is an intelligent gate, not a blanket human checkpoint. (ADR-027.)
2. **A reject-biased majority filter is the wrong loss function for security.** For
   authz/IDOR/tenant-isolation/money/secrets a false negative is catastrophic; CCM exempts
   these classes from the majority filter (single credible finding → mandatory
   ground-truth read → escalate).
3. **Same-model "independent" agents have correlated errors.** Majority agreement among
   instances of one model can launder a shared blind spot into false confidence; vary the
   lens per skeptic and never treat "N of N agree" as proof. The final ground-truth read
   is also model-fallible — pair it with an independent re-derivation for high-stakes work.

Also: the "closure test" measures the agent's *search* running dry, not the codebase being
clean (see §6.5 caveat); and an autonomous agent with merge rights reading untrusted
dependency code is itself an attack surface (treat dependency/PR text as untrusted; the
secret-scan + dangerous-bash hooks are the backstop).

---

*Derived from an executed campaign; the specifics were illustrative, the structure is the
reusable engine. CCM integration + risk adaptations recorded in ADR-026.*
