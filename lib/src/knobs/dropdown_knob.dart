import 'package:flutter/material.dart';
import 'package:playgrounder/src/knobs/knob_relevance.dart';

/// A knob that picks one of a fixed, unordered set of choices.
///
/// A dropdown rather than a slider, because a variant's choices are a *set*,
/// not a scale: nothing sits "between" two variants and there is no direction
/// to sweep, so the ordered `StepKnob` would misrepresent them. Reach for this
/// when the choices are named alternatives — a button variant, an alignment, a
/// body style — and for `StepKnob` when they are steps along a size.
///
/// [T] is the caller's choice type, usually an enum.
///
/// ```dart
/// DropdownKnob<Variant>(
///   label: 'Variant',
///   value: config.variant,
///   values: Variant.values,
///   labelOf: (v) => v.name,
///   onChanged: (v) => onChanged(config.copyWith(variant: v)),
/// )
/// ```
class DropdownKnob<T> extends StatelessWidget {
  /// Creates a dropdown knob over [values].
  const DropdownKnob({
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

  /// The selected choice.
  final T value;

  /// Every choice, in the order they should appear.
  final List<T> values;

  /// Renders a choice's display text.
  final String Function(T) labelOf;

  /// Called with the picked choice.
  ///
  /// Never called with null: the button's own nullable callback is guarded
  /// here so callers do not each repeat the check.
  final ValueChanged<T> onChanged;

  /// When this knob applies at all.
  final KnobRelevance relevantWhen;

  @override
  Widget build(BuildContext context) {
    if (!relevantWhen.isRelevant) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        // Raw Material, deliberately, like the other knobs: a knob is
        // scaffolding for driving a demo rather than anything being
        // demonstrated.
        DropdownButton<T>(
          value: value,
          // Takes the width it is given rather than sizing to its widest item,
          // which is what pushes it past a narrow inspector.
          isExpanded: true,
          items: [
            for (final v in values)
              DropdownMenuItem<T>(value: v, child: Text(labelOf(v))),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
