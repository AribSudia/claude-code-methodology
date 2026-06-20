# RTK Profiles — output compression (opt-in)

> **Status:** opt-in / **not installed by default.** `rtk` is an external Rust CLI. CCM's
> `compress-output.sh` PostToolUse hook is a **graceful no-op without it** (ADR-033) — and
> this doc deliberately makes **no token-savings claim**, because there's nothing to claim
> until the tool is present and measured. Honesty principle: no numbers we haven't measured.

## What rtk is for

Build/test/install commands emit long, low-signal logs (progress bars, per-file lines,
dependency trees) that enter context uncompressed. `rtk` is a shell proxy that compresses
such output. The win is real **only when the tool is installed and the noisy command is run
through it** — see "How to actually use it" below.

## Eligible command patterns

`compress-output.sh` recognizes these as "rtk-eligible" (it records the opportunity when
rtk is present; it does nothing when rtk is absent):

| Pattern | Typical noise |
|---|---|
| `npm/pnpm/yarn install`, `npm ci` | dependency tree, per-package lines |
| `jest`, `vitest`, `nest build`, `turbo run` | per-file/per-test output |
| `playwright test` | per-test + trace lines |
| `docker compose up/build` | layer + pull progress |
| `gradle`, `mvn` | task-by-task build logs |

## How to actually use it (when you choose to install it)

1. Install `rtk` (verify the source/tap before trusting a number — the developer plan's
   `brew install rtk` is **unverified**; confirm the real install for your platform).
2. Run the noisy command **through** rtk so its output is compressed at the source, e.g.:
   ```bash
   rtk -- pnpm test          # rtk compresses the suite output
   rtk -- nest build
   ```
   This is where the reduction happens — not in a post-hoc hook.
3. The `compress-output.sh` PostToolUse hook stays advisory: it flags eligible commands
   (so you remember to route them through rtk) and is otherwise inert. It NEVER blocks and
   NEVER fabricates a compressed result.

## Why no profile numbers here

The original plan quoted "60–90% reduction." We don't ship that figure because `rtk` is
absent in this environment and we have not measured it on a representative log. When the
tool is installed, measure before/after on a real build log and record the *measured*
number here — per the CCM honesty principle and CONSTRAINTS #14 ("verify the claim").
