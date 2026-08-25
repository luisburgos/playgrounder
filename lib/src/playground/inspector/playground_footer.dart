import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';

/// The inspector's pinned footer region.
///
/// Holds arbitrary caller content pinned to the very bottom of the inspector,
/// below any actions. Unlike the actions region, it takes a widget rather than
/// a list of `PlaygroundAction`s, so a consumer can pin a control that is not a
/// button — a row of swatches, a segmented control, a status line — that should
/// persist across the Presets and Custom tabs.
///
/// Behind a divider and inset to match the actions region, so a footer and
/// actions read as one pinned block whichever the caller supplies.
class PlaygroundFooter extends StatelessWidget {
  /// Creates the pinned footer region around [child].
  const PlaygroundFooter({required this.child, super.key});

  /// The caller's pinned content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: hairline),
        Padding(
          padding: const EdgeInsets.all(inset),
          child: child,
        ),
      ],
    );
  }
}
