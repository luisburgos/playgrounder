import 'package:flutter/material.dart';

/// The arguments a tab row is built from.
///
/// A details object rather than a parameter list, following Flutter's own
/// `ControlsDetails` for `Stepper.controlsBuilder`: it keeps the builder
/// signature stable when a slot later needs one more value.
@immutable
class PlaygroundTabsDetails {
  /// Creates the details for a tab row.
  const PlaygroundTabsDetails({
    required this.controller,
    required this.labels,
  });

  /// Drives which tab is showing; pass it to whatever tab widget you build.
  final TabController controller;

  /// The tab labels, in order.
  final List<String> labels;
}

/// The arguments one preset row is built from.
@immutable
class PlaygroundPresetRowDetails {
  /// Creates the details for a preset row.
  const PlaygroundPresetRowDetails({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  /// The preset's name.
  final String label;

  /// Whether this preset matches the current configuration.
  ///
  /// The two states should read differently so the active preset is obvious
  /// at a glance.
  final bool selected;

  /// Applies this preset.
  final VoidCallback onPressed;
}

/// The arguments one pinned action button is built from.
@immutable
class PlaygroundActionDetails {
  /// Creates the details for an action button.
  const PlaygroundActionDetails({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// The action's name.
  final String label;

  /// Runs the action.
  final VoidCallback onPressed;

  /// An optional leading glyph.
  final Widget? icon;
}

/// Builds the inspector's Presets/Custom tab row.
typedef PlaygroundTabsBuilder =
    Widget Function(BuildContext context, PlaygroundTabsDetails details);

/// Builds one row in the inspector's preset list.
typedef PlaygroundPresetRowBuilder =
    Widget Function(BuildContext context, PlaygroundPresetRowDetails details);

/// Builds one of the inspector's pinned action buttons.
typedef PlaygroundActionButtonBuilder =
    Widget Function(BuildContext context, PlaygroundActionDetails details);

/// The stock Material tab row: a [TabBar] over the labels.
Widget buildMaterialTabs(
  BuildContext context,
  PlaygroundTabsDetails details,
) {
  return TabBar(
    controller: details.controller,
    tabs: [for (final label in details.labels) Tab(text: label)],
  );
}

/// The stock Material preset row.
///
/// The selected row is a full-width tonal button with a leading check, and an
/// unselected row is a quieter full-width outlined button with no icon.
Widget buildMaterialPresetRow(
  BuildContext context,
  PlaygroundPresetRowDetails details,
) {
  if (details.selected) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: details.onPressed,
        icon: const Icon(Icons.check),
        label: Text(details.label),
      ),
    );
  }
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: details.onPressed,
      child: Text(details.label),
    ),
  );
}

/// The stock Material action button: full-width and tonal.
Widget buildMaterialActionButton(
  BuildContext context,
  PlaygroundActionDetails details,
) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton.tonalIcon(
      onPressed: details.onPressed,
      icon: details.icon ?? const SizedBox.shrink(),
      label: Text(details.label),
    ),
  );
}
