# Agent instructions for playgrounder

Read CONTRIBUTING.md first — it is the authoritative process document. The
rules below are the hard gates an agent must not cross on its own judgment.

## Hard gates

- **Never run `dart pub publish` (or any publish/upload) without an explicit,
  separate approval of that exact step.** "Cut the release" authorizes the
  runbook's preparatory steps (bump, changelog, PR, tag) — it does NOT
  authorize the upload. Run the dry-run, present its output, then stop and
  ask. Publishing is immutable; a wrong upload cannot be replaced.
- **Do not push branches or open PRs before the user validates the change**
  and approves, unless they explicitly ask for the push/PR. Commit locally
  and report "committed, not pushed".

## Release checklist pointers

- The version lives in **three** places (see CONTRIBUTING's table, including
  the README install snippet); `test/version_drift_test.dart` is the drift
  guard — run it after any bump.
- Bump first, changelog second; tag the merge commit; nothing lands on main
  between bump and tag.

## API invariants

- `PlaygroundStyle` is the single seam through which a consuming design system
  dresses the playground. New chrome that a consumer might want to substitute
  belongs on `PlaygroundStyle`, not hardcoded into the private inspector.
- The package depends on no design system and imports no Material component
  beyond raw primitives (`Slider`, `Switch`, `TabBar`, `Divider`,
  `FilledButton`) used as neutral scaffolding. A knob is scaffolding for
  driving a demo, not a thing being demonstrated.
