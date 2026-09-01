// This file is the deprecated compatibility layer for the 0.2.0 seam. Every
// element in it is deprecated on purpose and cross-references its neighbours,
// so the same three diagnostics fire throughout; they are silenced once here
// rather than at each of a dozen sites.
//
// ignore_for_file: remove_deprecations_in_breaking_versions
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: deprecated_consistency
import 'package:flutter/material.dart';
import 'package:playgrounder/src/theme/playground_slots.dart';
import 'package:playgrounder/src/theme/playground_theme.dart';

/// How a design system dresses the playground.
///
/// Superseded by the per-slot builders on [PlaygroundThemeData]. One class
/// with three `buildX` methods forced a subclass for any override; one nullable
/// builder per slot lets a closure replace exactly the slot you care about and
/// leave the rest on their Material defaults. It is also the shape Flutter
/// itself uses for independent slots — `Stepper.controlsBuilder` and
/// `stepIconBuilder`, `SearchAnchor.viewBuilder` and `suggestionsBuilder`.
///
/// The rename also drops the `Scope` suffix, which named an implementation
/// detail — Material has no `*Scope` widgets.
///
/// Still fully supported: a subclass is adapted onto the new seam by
/// [PlaygroundStyleScope], so existing code keeps working unchanged.
@Deprecated(
  'Set the slot builders on PlaygroundThemeData instead — tabsBuilder, '
  'presetRowBuilder, actionButtonBuilder — and provide it through '
  'PlaygroundTheme. Will be removed in 0.4.0.',
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
    return buildMaterialTabs(
      context,
      PlaygroundTabsDetails(controller: controller, labels: labels),
    );
  }

  /// Builds one row in the inspector's preset list.
  Widget buildPresetRow(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return buildMaterialPresetRow(
      context,
      PlaygroundPresetRowDetails(
        label: label,
        selected: selected,
        onPressed: onPressed,
      ),
    );
  }

  /// Builds one of the inspector's pinned action buttons.
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return buildMaterialActionButton(
      context,
      PlaygroundActionDetails(label: label, onPressed: onPressed, icon: icon),
    );
  }

  /// The background of the preview stage the subject renders on.
  Color stageBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }
}

/// Provides a [PlaygroundStyle] to the playgrounds below it.
///
/// Superseded by [PlaygroundTheme]. This now wraps one: the style is adapted
/// onto the new seam and scoped as theme data, so a tree mixing the two reads
/// one consistent chrome.
///
/// Each of the style's build methods becomes one slot builder on the theme, so
/// an override on the old class still reaches the playground. The stage
/// background is resolved eagerly to a value, which is the shape the new theme
/// data expects.
@Deprecated(
  'Use PlaygroundTheme(data: PlaygroundThemeData(presetRowBuilder: ...)) and '
  'its sibling slot builders instead. Will be removed in 0.4.0.',
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

  /// The style scoped by the nearest [PlaygroundStyleScope], or a default.
  ///
  /// Only finds a style provided through this deprecated widget; a subtree
  /// scoped with [PlaygroundTheme] resolves to the default, since a slot
  /// builder cannot be turned back into a style.
  static PlaygroundStyle of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_StyleScopeMarker>();
    return scope?.style ?? const PlaygroundStyle();
  }

  @override
  Widget build(BuildContext context) {
    final s = style;
    return _StyleScopeMarker(
      style: s,
      child: PlaygroundTheme(
        data: PlaygroundThemeData(
          tabsBuilder: (context, d) => s.buildTabs(
            context,
            controller: d.controller,
            labels: d.labels,
          ),
          presetRowBuilder: (context, d) => s.buildPresetRow(
            context,
            label: d.label,
            selected: d.selected,
            onPressed: d.onPressed,
          ),
          actionButtonBuilder: (context, d) => s.buildActionButton(
            context,
            label: d.label,
            onPressed: d.onPressed,
            icon: d.icon,
          ),
          // Resolved eagerly so the tint an overriding style returns is
          // carried as a value, the shape the new theme data expects.
          stageBackground: s.stageBackground(context),
        ),
        child: child,
      ),
    );
  }
}

/// Carries the wrapped style so [PlaygroundStyleScope.of] can return it.
///
/// The theme itself holds closures, which cannot be turned back into the style
/// they close over, so the style is kept alongside them.
class _StyleScopeMarker extends InheritedWidget {
  const _StyleScopeMarker({required this.style, required super.child});

  final PlaygroundStyle style;

  @override
  bool updateShouldNotify(_StyleScopeMarker oldWidget) =>
      style != oldWidget.style;
}
