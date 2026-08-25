import 'package:flutter/widgets.dart';

/// One action pinned to the bottom of a playground's inspector.
///
/// Actions do something with the current configuration rather than change it —
/// presenting it as a modal, copying it, resetting it — which is why they sit
/// apart from the knobs behind a divider.
@immutable
class PlaygroundAction {
  /// Creates a pinned inspector action.
  const PlaygroundAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// The action's label.
  final String label;

  /// Called when the action is pressed.
  final VoidCallback onPressed;

  /// An optional leading icon.
  final Widget? icon;
}
