import 'package:equatable/equatable.dart';

/// A named starting configuration for a playground.
///
/// Presets exist so a shape can be demonstrated *and* mutated from. A fixed
/// example shows the result; a preset shows the settings that produce it and
/// leaves them editable.
///
/// [T] is the caller's configuration type. Give it value equality — the
/// preset-versus-Custom check is `==` against each preset's [config], so a
/// type without it reports Custom immediately and always.
class PlaygroundPreset<T> extends Equatable {
  /// Creates a named starting configuration.
  const PlaygroundPreset({
    required this.label,
    required this.config,
    this.summary,
  });

  /// The preset's name, shown in the inspector's preset list.
  final String label;

  /// The configuration this preset applies.
  final T config;

  /// One line on what the shape is for, shown when the preset is active.
  final String? summary;

  @override
  List<Object?> get props => [label, config, summary];
}
