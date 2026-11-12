# ADR-013: Consolidate GitHub Actions Dependabot Version Updates

Date: 2026-11-12

## Status

Accepted

## Decision

Keep the repository's weekly GitHub Actions Dependabot version-update
schedule, seven-day cooldown, and existing commit-message convention.
Replace `minor-and-patch` with a single `actions-version-updates` group
using `applies-to: version-updates` and `patterns: ["*"]`, without
`update-types`. Eligible major, minor, and patch routine updates may be
grouped together. Security updates remain separate from scheduled version
updates and must not be delayed by the cooldown.

Retain the existing `dependabot/fetch-metadata` guard excluding
`version-update:semver-major` from automatic merging. A group
containing a major upgrade must receive targeted manual review of its
highest-risk dependency and all material compatibility changes.

## Context, Constraints, and Assumptions

Previously, the minor/patch-only group allowed major GitHub Actions
versions to create additional routine PRs. The adopted
`coding_standards@v3.2.0` release recommends a balanced weekly
per-ecosystem group with a seven-day cooldown to reduce review volume,
without asserting a fixed number of PRs.

The maintained Python documentation translator is an AWK filter with
precisely governed recognition and preservation of Python source,
structured fields, Doxygen integration, supported AWK portability,
and three validated release artifact flavors. Accepted ADRs 001-012
remain authoritative. GitHub Actions dependency changes can affect
those testing and release-trust boundaries without changing source.

The only configured Dependabot ecosystem is GitHub Actions. The
auto-merge condition, required-check identities, token permissions,
and release-authority boundaries must remain unchanged. Effective
GitHub CODEOWNERS enforcement, branch rules, and Dependabot security
update settings require separate verification: repository YAML
does not establish those controls.

## Alternatives Considered

1. Keep minor/patch-only grouping. Rejected as the default because
   major versions would continue generating separate routine PRs
   without inherently stronger review evidence.
2. Group major/minor/patch versions per ecosystem. Chosen to reduce
   routine review fragmentation, with major-containing groups
   excluded from the non-major-only auto-merge path.
3. Move to monthly updates or extend the cooldown. Rejected because
   delaying routine visibility has not been justified by maintenance
   evidence or compatibility needs.
4. Auto-merge groups containing major updates. Rejected because
   breaking changes and altered Action privileges may affect tests,
   documentation, release validation, and published artifacts.
5. Close existing Dependabot PRs immediately. Rejected because a
   changed configuration does not prove their dependencies have
   been replaced or validated.

## Consequences, Risks, and Verification

Routine version-update PR count may decline, but resolver conflicts,
incompatible versions, or multiple update classes can still produce
separate PRs. Grouped failures may be harder to isolate. A risky or
incompatible dependency may justify a narrowly governed grouping
exception, without ignoring its updates entirely.

Each grouped PR requires review of each dependency's release notes,
permissions, migration impact, and test/release-path evidence.
Major-containing groups must not enter the existing automatic-merge
route. Existing Dependabot PR #18 stays open unless later updates
demonstrably supersede it with sufficient checks.

Observe actual post-merge Dependabot runs and compare PR counts and
review effort. Verify security-alert and security-update settings
and effective review protections independently. No change to
Python translation, AWK source, test fixtures, compatibility floor,
Doxygen representation, or release artifact contract is authorized.

## Related Decisions

ADR-012 governs the frozen released standards snapshot and its
provenance; ADR-011 governs three generated artifact flavors;
ADRs 001-010 govern parsing, representation, integration, and
testing. This ADR supplements, but does not supersede, them.
