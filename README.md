# playgrounder

**An opinionated playground builder for Flutter components.**

Build a playground for any component: a live preview beside the knobs that
configure it, with presets to start from. It uses Material by default, or
`PlaygroundStyle` to match your own design system.

### 🔎 [**Try the live demo →**](https://luisburgos.github.io/playgrounder/)

The example playground, running in your browser. No install required.

## Features ✨

- **Live preview beside live controls:** a component rendered live next to the
  knobs that configure it, generic on your own config type
- **Presets you can edit:** start from a named configuration, then turn any
  knob; the inspector shows when you've moved off a preset
- **Ready-made knobs:** step, switch, scale, and dropdown, so you wire behavior
  not widgets
- **Bring your own design system:** `PlaygroundStyle` restyles the tabs,
  buttons, and stage; Material until you do

## Installation 💻

```sh
flutter pub add playgrounder
```

Or add it to your `pubspec.yaml`:

```yaml
dependencies:
  playgrounder: ^0.1.0
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

With no `PlaygroundStyle` in scope the chrome is plain Material.

### Bringing your own chrome

Subclass `PlaygroundStyle`, override only the parts you want, and scope it over
the subtree. Everything you leave alone keeps the Material default:

```dart
class MyStyle extends PlaygroundStyle {
  const MyStyle();

  @override
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    Widget? icon,
    required VoidCallback onPressed,
  }) =>
      MyButton(label: label, icon: icon, onPressed: onPressed);
}

PlaygroundStyleScope(
  style: const MyStyle(),
  child: Playground<CardConfig>(/* ... */),
)
```

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
