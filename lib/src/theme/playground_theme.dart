import 'package:flutter/material.dart';
import 'package:playgrounder/src/theme/playground_chrome_builder.dart';

/// The default width at which a playground splits into preview and inspector.
///
/// Below this the two would each be too narrow to use, so they stack instead.
const double kPlaygroundSplitBreakpoint = 900;

/// The default width of the docked inspector, in logical pixels.
const double kPlaygroundInspectorWidth = 300;

/// How a design system dresses the playground.
///
/// Holds the [chromeBuilder] that draws the tabs, preset rows and action
/// buttons, plus the layout values the playground splits and docks at. Stated
/// once here rather than repeated at every playground: a design system's
/// chrome and proportions are facts about the system, not about any one
/// previewed subject.
///
/// Value semantics are a requirement, not a convenience — [PlaygroundTheme]
/// decides whether to rebuild its dependents by comparing two of these.
@immutable
class PlaygroundThemeData {
  /// Creates a theme. Every value defaults to the stock Material playground.
  const PlaygroundThemeData({
    this.chromeBuilder = const MaterialPlaygroundChromeBuilder(),
    this.stageBackground,
    this.inspectorWidth = kPlaygroundInspectorWidth,
    this.splitBreakpoint = kPlaygroundSplitBreakpoint,
  });

  /// Draws the inspector's tabs, preset rows and action buttons.
  final PlaygroundChromeBuilder chromeBuilder;

  /// The background of the preview stage the subject renders on.
  ///
  /// Null resolves to the ambient scheme's `surfaceContainerHighest`, a real
  /// tint under a stock Material scheme. A design system whose scheme leaves
  /// the container roles at plain `surface` sets this so a neutral subject
  /// does not vanish.
  ///
  /// A value rather than a method taking a context: the right stage tint is a
  /// fact about the design system's `ColorScheme`, so it is stated once
  /// alongside the chrome instead of resolved per build.
  final Color? stageBackground;

  /// The width of the docked inspector, in logical pixels.
  ///
  /// Widen it for a component with wide knobs; the preview takes the remaining
  /// width. Applies only in the docked layout (see [splitBreakpoint]).
  final double inspectorWidth;

  /// The width at or above which the preview and inspector dock side by side.
  ///
  /// Below it they stack, the preview over the inspector.
  final double splitBreakpoint;

  /// The stage background to paint in [context], falling back to the scheme.
  Color resolveStageBackground(BuildContext context) =>
      stageBackground ?? Theme.of(context).colorScheme.surfaceContainerHighest;

  /// A copy with the given values replaced.
  ///
  /// Passing null for [stageBackground] keeps the current value; use
  /// `PlaygroundThemeData(...)` directly to clear it back to the scheme
  /// default.
  PlaygroundThemeData copyWith({
    PlaygroundChromeBuilder? chromeBuilder,
    Color? stageBackground,
    double? inspectorWidth,
    double? splitBreakpoint,
  }) {
    return PlaygroundThemeData(
      chromeBuilder: chromeBuilder ?? this.chromeBuilder,
      stageBackground: stageBackground ?? this.stageBackground,
      inspectorWidth: inspectorWidth ?? this.inspectorWidth,
      splitBreakpoint: splitBreakpoint ?? this.splitBreakpoint,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlaygroundThemeData &&
      other.chromeBuilder == chromeBuilder &&
      other.stageBackground == stageBackground &&
      other.inspectorWidth == inspectorWidth &&
      other.splitBreakpoint == splitBreakpoint;

  @override
  int get hashCode => Object.hash(
    chromeBuilder,
    stageBackground,
    inspectorWidth,
    splitBreakpoint,
  );
}

/// Provides a [PlaygroundThemeData] to the playgrounds below it.
///
/// A playground reads the ambient theme with [of]. With no theme in the tree
/// the data is a default [PlaygroundThemeData] — stock Material chrome — so
/// bare usage needs no wrapper.
///
/// Named for what it is rather than how it works, following Material's own
/// `DividerTheme` / `ChipTheme`: [of] returns the *data*, not the widget.
class PlaygroundTheme extends InheritedWidget {
  /// Scopes [data] over [child].
  const PlaygroundTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The values provided to the subtree.
  final PlaygroundThemeData data;

  /// The ambient theme's data, or a default when none is in scope.
  static PlaygroundThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<PlaygroundTheme>();
    return theme?.data ?? const PlaygroundThemeData();
  }

  @override
  bool updateShouldNotify(PlaygroundTheme oldWidget) => data != oldWidget.data;
}
