import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/playground/playground_preset.dart';
import 'package:playgrounder/src/style/playground_style.dart';

/// The inspector's preset list.
///
/// Picking a preset pours its configuration into the knobs, so the settings
/// that produce a shape stay visible and editable. Once the knobs no longer
/// match any preset the list reports that the configuration is custom, which
/// is why [active] is nullable rather than an index.
///
/// Each row is built by the ambient [PlaygroundStyle], so a design system's
/// own button appears here rather than stock Material.
class PlaygroundPresets<T> extends StatelessWidget {
  /// Creates a preset list.
  const PlaygroundPresets({
    required this.presets,
    required this.active,
    required this.onSelected,
    super.key,
  });

  /// The available configurations.
  final List<PlaygroundPreset<T>> presets;

  /// The preset matching the current configuration, or null once the knobs
  /// have been moved away from all of them.
  final PlaygroundPreset<T>? active;

  /// Called with the picked preset's configuration.
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final style = PlaygroundStyleScope.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: gap,
      children: [
        for (final preset in presets)
          style.buildPresetRow(
            context,
            label: preset.label,
            selected: preset == active,
            onPressed: () => onSelected(preset.config),
          ),
        Text(
          active?.summary ?? 'Custom — the knobs no longer match a preset.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
