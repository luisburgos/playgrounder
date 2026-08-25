import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:playgrounder/src/knobs/knob_relevance.dart';
import 'package:playgrounder/src/knobs/step_knob.dart';

/// One step of a scale a knob can pick, as a name paired with its value.
///
/// A dumb value object: the consumer resolves its own scale — a spacing scale,
/// a radius scale, an icon-size scale — into a list of these, so playgrounder
/// carries no scale semantics of its own. Resolving against the theme where it
/// has one keeps a demo from quoting a pixel that goes stale when the scale
/// moves; that resolution is the consumer's to do, at the point it builds the
/// list.
class ScaleStep extends Equatable {
  /// Creates a named step at [value].
  const ScaleStep(this.name, this.value);

  /// The step's name, e.g. `md`.
  final String name;

  /// The step's value, e.g. `16`.
  final double value;

  @override
  List<Object?> get props => [name, value];
}

/// A knob that steps along a named scale of values.
///
/// A thin convenience over [StepKnob]: the slider mechanics are the same for
/// any ordered scale, and only the readout is scale-specific — it shows each
/// step's name and value as `name — Npx`. The consumer supplies the resolved
/// [values]; playgrounder does not know where a scale's numbers come from.
class ScaleKnob extends StatelessWidget {
  /// Creates a scale knob over [values].
  const ScaleKnob({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    this.relevantWhen = const KnobRelevance.always(),
    super.key,
  });

  /// The knob's label.
  final String label;

  /// The selected step.
  final ScaleStep value;

  /// Every step, in scale order.
  final List<ScaleStep> values;

  /// Called with the picked step.
  final ValueChanged<ScaleStep> onChanged;

  /// When this knob applies at all.
  final KnobRelevance relevantWhen;

  @override
  Widget build(BuildContext context) {
    return StepKnob<ScaleStep>(
      label: label,
      value: value,
      values: values,
      labelOf: (step) => '${step.name} — ${step.value.toInt()}px',
      relevantWhen: relevantWhen,
      onChanged: onChanged,
    );
  }
}
