// This file is the deprecated compatibility layer for the 0.2.0 seam. Every
// element in it is deprecated on purpose and cross-references its neighbours,
// so the same three diagnostics fire throughout; they are silenced once here
// rather than at each of a dozen sites.
//
// ignore_for_file: remove_deprecations_in_breaking_versions
// ignore_for_file: deprecated_consistency
import 'package:flutter/material.dart';
import 'package:playgrounder/src/theme/playground_chrome_builder.dart';
import 'package:playgrounder/src/theme/playground_theme.dart';

/// How a design system dresses the playground.
///
/// Superseded by [PlaygroundChromeBuilder] carried inside a
/// [PlaygroundThemeData]: behavior belongs *inside* a theme rather than being
/// injected in place of one, which is the shape Flutter itself uses
/// (`PageTransitionsBuilder` lives in `PageTransitionsTheme`). The rename also
/// drops the `Scope` suffix, which named an implementation detail — Material
/// has no `*Scope` widgets.
///
/// Still fully supported: a subclass is adapted onto the new seam by
/// [PlaygroundStyleScope], so existing code keeps working unchanged.
@Deprecated(
  'Implement PlaygroundChromeBuilder and provide it through '
  'PlaygroundTheme(data: PlaygroundThemeData(chromeBuilder: ...)) instead. '
  'Will be removed in 0.4.0.',
)
class PlaygroundStyle {
  /// Creates a style. The base builds stock Material chrome.
  const PlaygroundStyle();

  /// Builds the inspector's Presets/Custom tab row.
  Widget buildTabs(
    BuildContext context, {
    required TabController controller,
    required List<String> labels,
  }) {
    return const MaterialPlaygroundChromeBuilder().buildTabs(
      context,
      controller: controller,
      labels: labels,
    );
  }

  /// Builds one row in the inspector's preset list.
  Widget buildPresetRow(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return const MaterialPlaygroundChromeBuilder().buildPresetRow(
      context,
      label: label,
      selected: selected,
      onPressed: onPressed,
    );
  }

  /// Builds one of the inspector's pinned action buttons.
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return const MaterialPlaygroundChromeBuilder().buildActionButton(
      context,
      label: label,
      onPressed: onPressed,
      icon: icon,
    );
  }

  /// The background of the preview stage the subject renders on.
  Color stageBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }
}

/// Adapts a [PlaygroundStyle] onto the [PlaygroundChromeBuilder] seam.
///
/// Every call forwards to the wrapped style, so an override on the old class
/// still reaches the playground. Equality is by wrapped style, which is what
/// keeps `updateShouldNotify` honest for consumers that have not migrated.
@Deprecated(
  'Internal shim for the deprecated PlaygroundStyle. Removed in 0.4.0.',
)
class _StyleChromeBuilder extends PlaygroundChromeBuilder {
  const _StyleChromeBuilder(this.style);

  final PlaygroundStyle style;

  @override
  Widget buildTabs(
    BuildContext context, {
    required TabController controller,
    required List<String> labels,
  }) => style.buildTabs(context, controller: controller, labels: labels);

  @override
  Widget buildPresetRow(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) => style.buildPresetRow(
    context,
    label: label,
    selected: selected,
    onPressed: onPressed,
  );

  @override
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) => style.buildActionButton(
    context,
    label: label,
    onPressed: onPressed,
    icon: icon,
  );

  @override
  bool operator ==(Object other) =>
      other is _StyleChromeBuilder && other.style == style;

  @override
  int get hashCode => style.hashCode;
}

/// Provides a [PlaygroundStyle] to the playgrounds below it.
///
/// Superseded by [PlaygroundTheme]. This now wraps one: the style is adapted
/// onto the new seam and scoped as theme data, so a tree mixing the two reads
/// one consistent chrome.
///
/// The stage background is the one member that cannot be forwarded as a value
/// — the old API resolves it from a context — so it is left to the theme's own
/// resolution unless the style overrides it, in which case the override wins
/// at paint time through the adapter's own scope.
@Deprecated(
  'Use PlaygroundTheme(data: PlaygroundThemeData(chromeBuilder: ...)) instead. '
  'Will be removed in 0.4.0.',
)
class PlaygroundStyleScope extends StatelessWidget {
  /// Scopes [style] over [child].
  const PlaygroundStyleScope({
    required this.style,
    required this.child,
    super.key,
  });

  /// The style provided to the subtree.
  final PlaygroundStyle style;

  /// The subtree the style applies to.
  final Widget child;

  /// The ambient style, or a default [PlaygroundStyle] when none is in scope.
  ///
  /// Reads through the new seam so a subtree scoped with either API resolves.
  static PlaygroundStyle of(BuildContext context) {
    final builder = PlaygroundTheme.of(context).chromeBuilder;
    if (builder is _StyleChromeBuilder) return builder.style;
    return const PlaygroundStyle();
  }

  @override
  Widget build(BuildContext context) {
    // Resolved eagerly so the stage tint an overriding style returns is
    // carried as a value, the shape the new theme data expects.
    return PlaygroundTheme(
      data: PlaygroundThemeData(
        chromeBuilder: _StyleChromeBuilder(style),
        stageBackground: style.stageBackground(context),
      ),
      child: child,
    );
  }
}
