import 'package:flutter/material.dart';
import 'package:playgrounder/src/theme/playground_slots.dart';

/// The default width at which a playground splits into preview and inspector.
///
/// Below this the two would each be too narrow to use, so they stack instead.
const double kPlaygroundSplitBreakpoint = 900;

/// The default width of the docked inspector, in logical pixels.
const double kPlaygroundInspectorWidth = 300;

/// How a design system dresses the playground.
///
/// Holds one optional builder per chrome slot — the tab row, a preset row, an
/// action button — plus the layout values the playground splits and docks at.
/// Stated once here rather than repeated at every playground: a design
/// system's chrome and proportions are facts about the system, not about any
/// one previewed subject.
///
/// A null builder means the stock Material default, so overriding one slot
/// leaves the rest alone and needs no subclassing.
///
/// **This type carries nothing that `ThemeData` already themes.** The default
/// chrome is built from stock Material widgets, so a consumer's `ColorScheme`,
/// `TabBarTheme` and button themes already reach it. A colour or text style
/// here would be a second source of truth: meaningless to a builder returning
/// a non-Material widget, and ambiguous against `Theme.of(context)` for one
/// that returns a Material widget. Only what Material cannot express belongs
/// here.
///
/// Value semantics are a requirement, not a convenience — [PlaygroundTheme]
/// decides whether to rebuild its dependents by comparing two of these.
/// Function fields compare by identity, so hoist builders to static or
/// top-level functions rather than writing closures inline; an inline closure
/// makes a new theme every build and needlessly rebuilds the chrome.
@immutable
class PlaygroundThemeData {
  /// Creates a theme. Every value defaults to the stock Material playground.
  const PlaygroundThemeData({
    this.tabsBuilder,
    this.presetRowBuilder,
    this.actionButtonBuilder,
    this.stageBackground,
    this.inspectorWidth = kPlaygroundInspectorWidth,
    this.splitBreakpoint = kPlaygroundSplitBreakpoint,
  });

  /// Builds the inspector's tab row, or null for the Material default.
  final PlaygroundTabsBuilder? tabsBuilder;

  /// Builds one preset row, or null for the Material default.
  final PlaygroundPresetRowBuilder? presetRowBuilder;

  /// Builds one pinned action button, or null for the Material default.
  final PlaygroundActionButtonBuilder? actionButtonBuilder;

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

  /// The tab-row builder to use, falling back to the Material default.
  PlaygroundTabsBuilder get resolvedTabsBuilder =>
      tabsBuilder ?? buildMaterialTabs;

  /// The preset-row builder to use, falling back to the Material default.
  PlaygroundPresetRowBuilder get resolvedPresetRowBuilder =>
      presetRowBuilder ?? buildMaterialPresetRow;

  /// The action-button builder to use, falling back to the Material default.
  PlaygroundActionButtonBuilder get resolvedActionButtonBuilder =>
      actionButtonBuilder ?? buildMaterialActionButton;

  /// A copy with the given values replaced.
  ///
  /// Passing null for [stageBackground] keeps the current value; use
  /// `PlaygroundThemeData(...)` directly to clear it back to the scheme
  /// default.
  PlaygroundThemeData copyWith({
    PlaygroundTabsBuilder? tabsBuilder,
    PlaygroundPresetRowBuilder? presetRowBuilder,
    PlaygroundActionButtonBuilder? actionButtonBuilder,
    Color? stageBackground,
    double? inspectorWidth,
    double? splitBreakpoint,
  }) {
    return PlaygroundThemeData(
      tabsBuilder: tabsBuilder ?? this.tabsBuilder,
      presetRowBuilder: presetRowBuilder ?? this.presetRowBuilder,
      actionButtonBuilder: actionButtonBuilder ?? this.actionButtonBuilder,
      stageBackground: stageBackground ?? this.stageBackground,
      inspectorWidth: inspectorWidth ?? this.inspectorWidth,
      splitBreakpoint: splitBreakpoint ?? this.splitBreakpoint,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlaygroundThemeData &&
      other.tabsBuilder == tabsBuilder &&
      other.presetRowBuilder == presetRowBuilder &&
      other.actionButtonBuilder == actionButtonBuilder &&
      other.stageBackground == stageBackground &&
      other.inspectorWidth == inspectorWidth &&
      other.splitBreakpoint == splitBreakpoint;

  @override
  int get hashCode => Object.hash(
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
