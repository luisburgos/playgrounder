import 'package:flutter/material.dart';
import 'package:playgrounder/src/knobs/knob_relevance.dart';

/// A titled group of knobs.
///
/// The heading separates one axis of configuration from another — the switches
/// that toggle a component's parts from the sliders that size them — so a long
/// inspector stays scannable.
///
/// Pass [relevantWhen] when the whole group stops applying to some
/// configurations; the group then renders nothing rather than a set of inert
/// controls. See [KnobRelevance] for why hidden and not disabled.
class KnobGroup extends StatelessWidget {
  /// Creates a titled group of knobs.
  const KnobGroup({
    required this.title,
    required this.children,
    this.relevantWhen = const KnobRelevance.always(),
    super.key,
  });

  /// The group's heading, rendered in caps.
  final String title;

  /// The knobs in this group.
  final List<Widget> children;

  /// When this group applies at all.
  final KnobRelevance relevantWhen;

  @override
  Widget build(BuildContext context) {
    if (!relevantWhen.isRelevant) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        ...children,
      ],
    );
  }
}
