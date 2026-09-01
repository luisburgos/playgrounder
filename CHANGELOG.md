# Changelog

## [0.3.0](https://github.com/luisburgos/playgrounder/compare/0.2.0...0.3.0) (2026-09-01)

**DEPRECATED**: `PlaygroundStyle` and `PlaygroundStyleScope` still work and are
adapted onto the new seam, so existing code runs unchanged. Both are removed in
0.4.0.

Migrate by implementing a `PlaygroundChromeBuilder` and providing it as theme
data:

```dart
// before
class MyStyle extends PlaygroundStyle { /* overrides */ }
PlaygroundStyleScope(style: const MyStyle(), child: child)

// after
class MyChrome extends MaterialPlaygroundChromeBuilder { /* overrides */ }
PlaygroundTheme(
  data: const PlaygroundThemeData(chromeBuilder: MyChrome()),
  child: child,
)
```

`stageBackground` was a method resolving a colour from a context; it is now a
nullable `Color` field on `PlaygroundThemeData`, since the right stage tint is
a fact about the design system's `ColorScheme` rather than a per-build
computation. Null still resolves to `surfaceContainerHighest`.

`Playground.inspectorWidth` and `Playground.splitBreakpoint` are now nullable
and fall back to the theme, so a design system states them once instead of at
every playground. Passing them per playground still works and still wins.

### Refactors

* carry the chrome seam inside a theme ([be8e0f2](https://github.com/luisburgos/playgrounder/commit/be8e0f241dc02a6961da3639eae3c337cf5f2e3d))

## 0.2.0

**BREAKING**: `Playground.actions` is replaced by a single `footer` slot that
accepts any widget. Actions are now prefab footer content: migrate
`Playground(actions: [...])` to
`Playground(footer: PlaygroundActions(actions: [...]))`. `PlaygroundActions`
is exported for this; it still styles each button through the ambient
`PlaygroundStyle`, and the footer region supplies the divider and inset once,
so composing actions with other pinned content does not double the chrome.

## 0.1.0

Initial release: `Playground`, `PlaygroundPreset`, `PlaygroundAction`,
`PlaygroundStyle` and `PlaygroundStyleScope`, and the `StepKnob`, `SwitchKnob`,
`ScaleKnob` (with `ScaleStep`), `DropdownKnob`, `KnobGroup`, and `KnobRelevance`
inspector controls. `Playground` exposes `inspectorWidth` and `splitBreakpoint`
for tuning the docked layout.
