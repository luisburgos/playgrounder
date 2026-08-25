import 'package:flutter/material.dart';

/// How a design system dresses the playground.
///
/// The playground's behavior — the split-pane layout, the preset-versus-Custom
/// tracking, the knob mechanics — is fixed. Its *chrome* is not: the tab row,
/// the preset rows, the action buttons, and the stage color are the points a
/// consuming design system will want in its own widgets rather than stock
/// Material. Those four points live here.
///
/// The base class supplies a Material default for every point, so a consumer
/// that injects nothing gets a usable playground with no wiring. Subclass it,
/// override only the points you care about, and provide it through a
/// [PlaygroundStyleScope]; the widget tree calls every method unconditionally,
/// so an un-overridden point keeps its Material default.
///
/// Three of the four members build widgets; [stageBackground] returns a color.
/// It lives here rather than as a per-playground argument because the right
/// stage tint is a fact about the design system's `ColorScheme`, not about any
/// one previewed subject — so it is stated once, alongside the chrome, rather
/// than repeated at every call site.
class PlaygroundStyle {
  /// Creates a style. The base builds stock Material chrome.
  const PlaygroundStyle();

  /// Builds the inspector's Presets/Custom tab row.
  ///
  /// The default is a Material [TabBar] over [labels], driven by [controller].
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

  /// Builds one row in the inspector's preset list.
  ///
  /// The two states read differently so the active preset is obvious at a
  /// glance: the [selected] row is a full-width tonal button with a leading
  /// check, and an unselected row is a quieter full-width outlined button with
  /// no icon.
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

  /// Builds one of the inspector's pinned action buttons.
  ///
  /// The default is a full-width tonal button.
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

  /// The background of the preview stage the subject renders on.
  ///
  /// The default is `surfaceContainerHighest`, a real tint under a stock
  /// Material scheme. A design system whose scheme leaves the container roles
  /// at plain `surface` overrides this so a neutral subject does not vanish.
  Color stageBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }
}

/// Provides a [PlaygroundStyle] to the playgrounds below it.
///
/// A playground reads the ambient style with [of]. With no scope in the tree
/// the style is a plain [PlaygroundStyle] — stock Material chrome — so bare
/// usage needs no wrapper.
class PlaygroundStyleScope extends InheritedWidget {
  /// Scopes [style] over [child].
  const PlaygroundStyleScope({
    required this.style,
    required super.child,
    super.key,
  });

  /// The style provided to the subtree.
  final PlaygroundStyle style;

  /// The ambient style, or a default [PlaygroundStyle] when none is in scope.
  static PlaygroundStyle of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PlaygroundStyleScope>();
    return scope?.style ?? const PlaygroundStyle();
  }

  @override
  bool updateShouldNotify(PlaygroundStyleScope oldWidget) =>
      style != oldWidget.style;
}
