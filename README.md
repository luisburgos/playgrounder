# playgrounder

**An opinionated playground builder for Flutter components.**

Build a playground for any component: a live preview beside the knobs that
configure it, with presets to start from. It uses Material by default, or
a `PlaygroundTheme` to match your own design system.

### 🔎 [**Try the live demo →**](https://luisburgos.github.io/playgrounder/)

The example playground, running in your browser. No install required.

## Features ✨

- **Live preview beside live controls:** a component rendered live next to the
  knobs that configure it, generic on your own config type
- **Presets you can edit:** start from a named configuration, then turn any
  knob; the inspector shows when you've moved off a preset
- **Ready-made knobs:** step, switch, scale, and dropdown, so you wire behavior
  not widgets
- **Bring your own design system:** per-slot builders restyle the tabs,
  buttons, and stage; Material until you do

## Installation 💻

```sh
flutter pub add playgrounder
```

Or add it to your `pubspec.yaml`:

```yaml
dependencies:
  playgrounder: ^0.3.1
```

## Usage 🚀

Preview a component beside its knobs. `T` is your own configuration type. Give
it value equality so the preset-versus-Custom check works:

```dart
import 'package:playgrounder/playgrounder.dart';

Playground<CardConfig>(
  config: _config,
  onChanged: (c) => setState(() => _config = c),
  presets: const [
    PlaygroundPreset(label: 'Default', config: CardConfig()),
    PlaygroundPreset(label: 'Compact', config: CardConfig(dense: true)),
  ],
  previewBuilder: (context, config) => MyCard(config: config),
  knobsBuilder: (context, config, onChanged) => KnobGroup(
    title: 'Layout',
    children: [
      SwitchKnob(
        label: 'Dense',
        value: config.dense,
        onChanged: (v) => onChanged(config.copyWith(dense: v)),
      ),
    ],
  ),
)
```

With no `PlaygroundTheme` in scope the chrome is plain Material.

### Customization, in four steps

Take only the step you need. Most playgrounds stop at the second.

**1. Zero-config gets you a real playground.** Add the dependency, write a
config type and a `previewBuilder`, and you have a working preview and
inspector. No theme, no builders, no subclassing.

**2. Ambient theming carries you further than expected.** The defaults are
built from stock Material widgets, so your app's `ColorScheme`, `TabBarTheme`
and button themes already reach them. Most reskinning needs nothing from
playgrounder at all.

**3. Builders are the escape hatch, per slot.** When you need a *different
widget* rather than a differently-styled one — your design system's button, a
Cupertino control, anything foreign — replace exactly that slot and leave the
rest on their Material defaults:

```dart
Widget myActionButton(BuildContext context, PlaygroundActionDetails details) =>
    MyButton(
      label: details.label,
      icon: details.icon,
      onPressed: details.onPressed,
    );

PlaygroundTheme(
  data: const PlaygroundThemeData(actionButtonBuilder: myActionButton),
  child: Playground<CardConfig>(/* ... */),
)
```

The three slots are `tabsBuilder`, `presetRowBuilder` and
`actionButtonBuilder`. Null means the Material default, so overriding one
leaves the others alone.

> Hoist *these* builders to top-level or static functions. Unlike a builder
> passed straight to a widget — where an inline closure is normal and costs
> nothing — a builder stored on a theme is compared by identity, because
> `PlaygroundTheme` decides whether to rebuild by comparing two
> `PlaygroundThemeData`. An inline closure makes the theme unequal on every
> build, so the chrome rebuilds for nothing. Flutter's own
> `ActionIconThemeData` carries slot builders the same way.

**4. The package theme carries only what Material cannot express.**
`stageBackground`, `inspectorWidth`, `splitBreakpoint` — the tint behind a
previewed component and the proportions of the split. Nothing that `ThemeData`
already themes lives here, so there is never a second source of truth for a
color.

> **Migrating from 0.2.x** — `PlaygroundStyle` and `PlaygroundStyleScope` still
> work and are adapted onto the new seam, so existing code keeps running. They
> are deprecated and will be removed in 0.4.0. Replace a subclass with one
> builder per slot you actually overrode.

### Responsive layout

At or above a breakpoint the preview and inspector dock side by side, with the
inspector at a fixed width; below it they stack, the preview over the inspector.
Both measures are tunable per playground, so a component with wide knobs or a
large preview can claim the room it needs:

```dart
Playground<CardConfig>(
  // A roomier inspector for wide knobs (default 300).
  inspectorWidth: 380,
  // Dock sooner, or later, than the default 900.
  splitBreakpoint: 720,
  // ...
)
```

The measurement is of the space the playground is actually given, not the
window, so it docks and stacks correctly inside a padded or split parent too.

See the example playground running at
**<https://luisburgos.github.io/playgrounder/>**, or run [`example/`](example)
locally:

```sh
cd example && fvm flutter run
```
