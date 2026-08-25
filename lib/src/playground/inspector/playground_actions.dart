import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/playground/playground_action.dart';
import 'package:playgrounder/src/style/playground_style.dart';

/// A column of styled action buttons, ready to pin in a playground's footer.
///
/// The prefab content for the common footer: each [PlaygroundAction] renders
/// through the ambient [PlaygroundStyle]'s `buildActionButton`, so a design
/// system's own button appears here rather than stock Material.
///
/// This is content, not the region: the footer slot it goes into supplies the
/// divider and inset. Compose it with other widgets when the footer holds more
/// than actions:
///
/// ```dart
/// Playground<MyConfig>(
///   footer: PlaygroundActions(actions: [
///     PlaygroundAction(label: 'Copy config', onPressed: _copy),
///   ]),
/// )
/// ```
class PlaygroundActions extends StatelessWidget {
  /// Creates a column of styled action buttons.
  const PlaygroundActions({required this.actions, super.key});

  /// The actions, in order.
  final List<PlaygroundAction> actions;

  @override
  Widget build(BuildContext context) {
    final style = PlaygroundStyleScope.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: [
        for (final action in actions)
          style.buildActionButton(
            context,
            label: action.label,
            onPressed: action.onPressed,
            icon: action.icon,
          ),
      ],
    );
  }
}
