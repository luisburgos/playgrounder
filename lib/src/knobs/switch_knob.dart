import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/knobs/knob_relevance.dart';

/// A labelled switch for a boolean knob.
///
/// Raw Material, deliberately: a knob is scaffolding for driving a demo rather
/// than anything being demonstrated.
///
/// Pass [relevantWhen] when this one knob stops applying while the rest of its
/// group still does. See [KnobRelevance] for why hidden and not disabled.
class SwitchKnob extends StatelessWidget {
  /// Creates a boolean switch knob.
  const SwitchKnob({
    required this.label,
    required this.value,
    required this.onChanged,
    this.relevantWhen = const KnobRelevance.always(),
    super.key,
  });

  /// The knob's label.
  final String label;

  /// Whether the knob is on.
  final bool value;

  /// Called with the new state.
  final ValueChanged<bool> onChanged;

  /// When this knob applies at all.
  final KnobRelevance relevantWhen;

  @override
  Widget build(BuildContext context) {
    if (!relevantWhen.isRelevant) return const SizedBox.shrink();

    return Row(
      spacing: gap,
      children: [
        Switch(value: value, onChanged: onChanged),
        // Takes the width left rather than its natural size: the inspector is
        // narrow, and a label long enough to exceed it would otherwise
        // overflow the row instead of wrapping.
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
