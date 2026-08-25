import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/playground/playground_action.dart';
import 'package:playgrounder/src/style/playground_style.dart';

/// The inspector's pinned action region.
///
/// Each button is built by the ambient [PlaygroundStyle]. The region sits
/// behind a divider because actions do something with the configuration rather
/// than change it, so they read as apart from the knobs above.
class PlaygroundActions extends StatelessWidget {
  /// Creates the pinned action region.
  const PlaygroundActions({required this.actions, super.key});

  /// The actions, in order.
  final List<PlaygroundAction> actions;

  @override
  Widget build(BuildContext context) {
    final style = PlaygroundStyleScope.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: hairline),
        Padding(
          padding: const EdgeInsets.all(inset),
          child: Column(
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
          ),
        ),
      ],
    );
  }
}
