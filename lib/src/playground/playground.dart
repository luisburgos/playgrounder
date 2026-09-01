import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/playground/inspector/playground_inspector.dart';
import 'package:playgrounder/src/playground/playground_preset.dart';
import 'package:playgrounder/src/playground/preview/playground_preview.dart';
import 'package:playgrounder/src/theme/playground_theme.dart';

/// A component rendered live beside the controls that configure it.
///
/// Two peers: a preview showing the subject, and an inspector holding presets,
/// knobs and a pinned footer. The playground owns the current configuration so
/// it can tell whether the knobs still match a preset, which is what a fixed
/// set of examples cannot show.
///
/// [T] is the caller's configuration type. Give it value equality — the
/// preset-versus-Custom check is `==` against each preset's config, so a type
/// without it reports Custom immediately and always.
///
/// The chrome — tabs, preset rows, action buttons, stage color — comes from
/// the ambient `PlaygroundStyle`, so a design system dresses the playground in
/// its own widgets by scoping a `PlaygroundTheme` above it. With no theme the
/// chrome is stock Material.
///
/// ```dart
/// Playground<MyConfig>(
///   config: _config,
///   onChanged: (c) => setState(() => _config = c),
///   presets: const [
///     PlaygroundPreset(label: 'Default', config: MyConfig()),
///   ],
///   previewBuilder: (context, config) => MyComponent(config: config),
///   knobsBuilder: (context, config, onChanged) => MyKnobs(...),
/// )
/// ```
class Playground<T> extends StatelessWidget {
  /// Creates a playground for a configuration of type [T].
  const Playground({
    required this.config,
    required this.onChanged,
    required this.previewBuilder,
    required this.knobsBuilder,
    this.presets = const [],
    this.footer,
    this.previewMaxWidth,
    this.previewBackground,
    this.inspectorWidth,
    this.splitBreakpoint,
    super.key,
  });

  /// The configuration being previewed.
  final T config;

  /// Called when a preset or a knob changes the configuration.
  final ValueChanged<T> onChanged;

  /// Builds the subject for the current configuration.
  final Widget Function(BuildContext context, T config) previewBuilder;

  /// Builds the controls for the current configuration.
  final Widget Function(
    BuildContext context,
    T config,
    ValueChanged<T> onChanged,
  )
  knobsBuilder;

  /// Named starting configurations. Empty hides the Presets tab.
  final List<PlaygroundPreset<T>> presets;

  /// Arbitrary content pinned to the bottom of the inspector, persisting
  /// across the Presets and Custom tabs.
  ///
  /// The region supplies the divider and inset; the content is yours — a row
  /// of swatches, a status line, or the prefab `PlaygroundActions` column of
  /// styled action buttons. Compose freely when the footer holds several.
  final Widget? footer;

  /// Clamps the previewed subject's width to what it really renders at.
  final double? previewMaxWidth;

  /// Overrides the preview stage's background.
  ///
  /// Pass a `surface`-like color when the subject is a neutral the default
  /// tint would swallow — a tonal or outlined control.
  final Color? previewBackground;

  /// Overrides the theme's docked-inspector width, in logical pixels.
  ///
  /// Widen it for a component with wide knobs; the preview takes the remaining
  /// width. Applies only in the docked layout (see [splitBreakpoint]).
  final double? inspectorWidth;

  /// Overrides the theme's split breakpoint.
  ///
  /// At or above this width the preview and inspector dock side by side; below
  /// it they stack, the preview over the inspector. Raise it if your preview
  /// needs more room before an inspector fits beside it; lower it to dock
  /// sooner.
  final double? splitBreakpoint;

  /// The preset matching [config], or null once the knobs have moved away.
  PlaygroundPreset<T>? get _activePreset {
    for (final preset in presets) {
      if (preset.config == config) return preset;
    }
    return null;
  }

  Widget _buildPreview(BuildContext context) => PlaygroundPreview(
    maxWidth: previewMaxWidth,
    background: previewBackground,
    child: previewBuilder(context, config),
  );

  Widget _buildInspector({required bool bordered}) => PlaygroundInspector<T>(
    presets: presets,
    active: _activePreset,
    onSelected: onChanged,
    knobs: Builder(
      builder: (context) => knobsBuilder(context, config, onChanged),
    ),
    footer: footer,
    bordered: bordered,
  );

  @override
  Widget build(BuildContext context) {
    // Measures the space the playground actually gets rather than the window,
    // so it still splits correctly inside a padded or inset parent.
    final theme = PlaygroundTheme.of(context);
    final effectiveSplit = splitBreakpoint ?? theme.splitBreakpoint;
    final effectiveInspectorWidth = inspectorWidth ?? theme.inspectorWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < effectiveSplit) {
          // Stacked, so the inspector's leading border would divide nothing —
          // a Divider does that job along the axis the two actually meet on.
          return ListView(
            children: [
              _buildPreview(context),
              const Divider(height: hairline),
              _buildInspector(bordered: false),
            ],
          );
        }

        // Preview first in the reading order, inspector docked to its right.
        // The preview takes the remaining width so it stays the focus, while
        // the inspector is fixed — controls that reflow as you use them are
        // harder to hit than ones that stay put.
        //
        // Stretched and gapless: the two meet at the inspector's border the
        // way a docked design tool does, rather than floating apart as cards.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, pane) => SingleChildScrollView(
                  // Floor the stage at the pane's height so its tint fills the
                  // pane; without it the stage hugs the subject and the
                  // surface stops partway down.
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: pane.maxHeight),
                    child: _buildPreview(context),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: effectiveInspectorWidth,
              child: _buildInspector(bordered: true),
            ),
          ],
        );
      },
    );
  }
}
