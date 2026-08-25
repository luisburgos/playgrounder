import 'package:flutter/foundation.dart';

/// Why a knob or group is not shown for the current configuration.
///
/// A knob is scoped out when the configuration has made it drive nothing: a
/// swatch size on a subject that exposes none, a foreground preference on a
/// fill that is never resolved against. Such a knob is **hidden rather than
/// disabled**, because a control that is present but inert reads as a bug in
/// the component being demonstrated rather than as a fact about it.
///
/// The reason is carried in code rather than left to a comment beside an `if`,
/// so a reader can tell a deliberate scoping from an accidental one, and so
/// the rule is stated once instead of restated at each site.
@immutable
class KnobRelevance {
  /// Scopes a knob to configurations where it drives something.
  ///
  /// [reason] completes "hidden because…" and describes the *component's*
  /// constraint, not the widget tree — "the picker field exposes no swatch
  /// size", not "the size knob is hidden".
  const KnobRelevance.when({
    required this.isRelevant,
    required this.reason,
  });

  /// A knob that always drives something.
  const KnobRelevance.always() : isRelevant = true, reason = '';

  /// Whether the knob drives anything in the current configuration.
  final bool isRelevant;

  /// Why it does not, when it does not.
  final String reason;
}
