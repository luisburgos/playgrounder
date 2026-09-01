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

- `PlaygroundChromeBuilder` is the single seam through which a consuming design
  system dresses the playground, and it is carried in `PlaygroundThemeData`
  rather than injected in its own right — the shape Flutter uses for a
  behavioral seam (`PageTransitionsBuilder` inside `PageTransitionsTheme`). New
  chrome a consumer might substitute becomes another builder method, never a
  hardcoded widget in the private inspector.
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
