# Changelog

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
