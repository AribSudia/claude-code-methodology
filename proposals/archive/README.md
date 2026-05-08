# proposals/archive/

Historical planning documents. **Not shipped methodology.** These files
are preserved for context — they show how decisions were proposed,
debated, deferred, overridden, and finally landed in v3.3.0.

## Files

### `CCM-v3.2-Enforced-Proposal.md`

Original 11-item architectural proposal that became v3.3.0 "Operating".

**Attribution note:** the document is signed "Dr. Sami Alzahrani — CTO"
(2026-05-03). This is **not** the maintainer of CCM (Abdullah Alzahrani,
arib.sa). The proposal was offered as external input; the maintainer
reviewed, drafted a counter-proposal, then shipped a hybrid scope.
Ownership of the resulting work — the v3.3 release — is the
maintainer's; the proposal's ideas were contributory but did not
confer authorship over the final implementation.

### `CCM-v3.2-Minimal-Counter-Proposal.md`

Maintainer's counter-proposal that initially deferred 8 of 11 items.
v3.2 "Honest" shipped only items #1, #2, #11 from this counter-proposal.
v3.3 "Operating" subsequently shipped the deferred items with the
counter-proposal's safeguards preserved (opt-in MCPs, honest framework
framing, no certification claims).

See `architecture/DECISIONS.md` ADR-011 for the formal record of the
override.

## Why these stay in the repo

They document the design discussion. Anyone reading just `CHANGELOG.md`
sees what shipped; reading these files shows *why*, including the
original concerns about scope creep and vendor pull-in that shaped the
final implementation.

## What these are NOT

- **Not specifications.** The shipped implementation diverges from both
  documents in places — see ADR-004 through ADR-011 for the resolved
  decisions.
- **Not active proposals.** No further changes will land based on
  these. New proposals go through ADRs in `architecture/DECISIONS.md`.
- **Not endorsed standards documentation.** Where the proposal mentions
  ISO 27001, SOC 2, GDPR, OWASP, or PDPL, see `compliance/README.md`
  for the honesty principle on what CCM does and does not claim.
