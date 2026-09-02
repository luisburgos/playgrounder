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
- **Never put a version bump in a PR that changes anything else.** The bump is
  always its own `chore(release): bump to X.Y.Z` PR, opened only after the
  feature work has already landed on `main`. Squash-merge destroys the branch's
  commits, so a piggy-backed bump erases the release from history entirely.
  If you notice mid-branch that a release is due, finish and land the branch
  first, then start a fresh one for the bump. The pre-push hook and CI both
  run `tool/check_version_bump_is_alone.sh`, so a piggy-backed bump is
  refused before it reaches the remote. Do not rely on either to catch it: a
  branch that should never have existed still costs the time to make it.

## Release checklist pointers

- The version lives in **three** places (see CONTRIBUTING's table, including
  the README install snippet); `test/version_drift_test.dart` is the drift
  guard — run it after any bump.
- Bump first, changelog second; tag the merge commit; nothing lands on main
  between bump and tag.

## API invariants

- Chrome a consuming design system substitutes is exposed as **one nullable
  builder per slot** on `PlaygroundThemeData` (`tabsBuilder`,
  `presetRowBuilder`, `actionButtonBuilder`), each taking a `*Details` object.
  Null means the Material default. New chrome becomes another nullable field,
  never a method on a shared interface: a field is additive for every existing
  consumer, a method is a breaking change to all of them. This is the shape
  Flutter uses for independent slots (`Stepper.controlsBuilder` /
  `stepIconBuilder`).
- **No field on `PlaygroundThemeData` may duplicate what `ThemeData` already
  themes.** The default chrome is stock Material, so a consumer's `ColorScheme`
  and component themes reach it for free. A color or text style here would be a
  second source of truth: meaningless to a builder returning a non-Material
  widget, ambiguous against `Theme.of(context)` for one that returns a Material
  widget. Only what Material cannot express — the stage tint, the split
  proportions — belongs here.
- `PlaygroundThemeData` must keep exact `==`/`hashCode` over every field,
  including `chromeBuilder`. `PlaygroundTheme.updateShouldNotify` compares two
  of them, so a field left out of equality silently stops propagating.
- Naming follows Material, not implementation: the widget is `PlaygroundTheme`
  (never `*Scope`), its field is `data`, and `of(context)` returns the data.
- `PlaygroundStyle` / `PlaygroundStyleScope` are the deprecated 0.2.x seam,
  kept working by an adapter and **removed in 0.4.0**. Do not add anything to
  them; the tests that exercise them are deliberate and must keep passing until
  the removal.
- The package depends on no design system and imports no Material component
  beyond raw primitives (`Slider`, `Switch`, `TabBar`, `Divider`,
  `FilledButton`) used as neutral scaffolding. A knob is scaffolding for
  driving a demo, not a thing being demonstrated.
