import 'package:flutter/material.dart';
import 'package:playgrounder/src/knobs/knob_relevance.dart';

/// A knob that steps along an ordered scale.
///
/// A slider rather than a dropdown, because a scale's *ordering* is part of
/// what it teaches: a reader wants to sweep it and watch where a layout starts
/// to break, which picking one item at a time discourages. A dropdown presents
/// its choices as an unordered set, which is right for a variant and wrong for
/// a size.
///
/// Snapped to the scale's own steps rather than free values. A playground that
/// let a caller dial 17px would be demonstrating a number the design system
/// does not have.
///
/// [T] is the caller's step type, usually an enum whose declaration order is
/// the scale's order — [values] is indexed, so a list that is not sorted would
/// put the slider's positions out of sequence.
///
/// ```dart
/// StepKnob<IconSize>(
///   label: 'Size',
///   value: config.size,
///   values: IconSize.values,
///   labelOf: (v) => '${v.name} — ${v.px}px',
///   onChanged: (v) => onChanged(config.copyWith(size: v)),
/// )
/// ```
class StepKnob<T> extends StatelessWidget {
  /// Creates a step knob over [values].
  const StepKnob({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.relevantWhen = const KnobRelevance.always(),
    super.key,
  });

  /// The knob's label.
  final String label;

  /// The selected step.
  final T value;

  /// Every step, in scale order.
  final List<T> values;

  /// Renders the selected step's readout.
  ///
  /// Show the token name *and* its value where there is one: the name alone
  /// does not say how big `md` is, and the number alone does not say which
  /// step a caller would write.
  final String Function(T) labelOf;

  /// Called with the picked step.
  final ValueChanged<T> onChanged;

  /// When this knob applies at all.
  final KnobRelevance relevantWhen;

  @override
  Widget build(BuildContext context) {
    if (!relevantWhen.isRelevant) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final index = values.indexOf(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            Text(
              labelOf(value),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        // Raw Material, deliberately, like the other knobs: the package has no
        // slider, and a knob is scaffolding for driving a demo rather than
        // anything being demonstrated.
        //
        // Divisions are one fewer than the steps: they count the intervals
        // between positions, not the positions themselves, so passing the step
        // count would put a detent between every pair of real values.
        Slider(
          value: index.toDouble(),
          max: (values.length - 1).toDouble(),
          divisions: values.length - 1,
          onChanged: (v) => onChanged(values[v.round()]),
        ),
      ],
    );
  }
}
