import 'package:flutter/material.dart';

/// Builds the chrome around a playground's preview and inspector.
///
/// The playground's behavior — the split-pane layout, the preset-versus-Custom
/// tracking, the knob mechanics — is fixed. Its *chrome* is not: the tab row,
/// the preset rows and the action buttons are the points a consuming design
/// system will want in its own widgets rather than stock Material, so those
/// three points are what this seam exposes.
///
/// Abstract rather than concrete-with-defaults so an implementation cannot
/// silently inherit the Material chrome it meant to replace; the Material
/// chrome is [MaterialPlaygroundChromeBuilder], which is what a theme falls
/// back to.
///
/// Mirrors Flutter's own behavioral seams — `PageTransitionsBuilder`,
/// `SliverChildDelegate` — which are abstract builders carried inside a theme
/// rather than injected in place of one.
@immutable
abstract class PlaygroundChromeBuilder {
  /// Allows subclasses to be const-constructed.
  const PlaygroundChromeBuilder();

  /// Builds the inspector's Presets/Custom tab row over [labels].
  Widget buildTabs(
    BuildContext context, {
    required TabController controller,
    required List<String> labels,
  });

  /// Builds one row in the inspector's preset list.
  ///
  /// The two states should read differently so the active preset is obvious at
  /// a glance.
  Widget buildPresetRow(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  });

  /// Builds one of the inspector's pinned action buttons.
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  });
}

/// The stock Material chrome: a [TabBar], filled and outlined buttons.
///
/// What a playground renders with when no theme is in scope, so bare usage
/// needs no wiring.
class MaterialPlaygroundChromeBuilder extends PlaygroundChromeBuilder {
  /// Creates the Material chrome builder.
  const MaterialPlaygroundChromeBuilder();

  @override
  Widget buildTabs(
    BuildContext context, {
    required TabController controller,
    required List<String> labels,
  }) {
    return TabBar(
      controller: controller,
      tabs: [for (final label in labels) Tab(text: label)],
    );
  }

  @override
  Widget buildPresetRow(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    if (selected) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.check),
          label: Text(label),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  @override
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }

  @override
  bool operator ==(Object other) => other is MaterialPlaygroundChromeBuilder;

  @override
  int get hashCode => (MaterialPlaygroundChromeBuilder).hashCode;
}
