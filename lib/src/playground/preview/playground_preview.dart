import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/theme/playground_theme.dart';

/// The stage a playground's subject renders on.
///
/// The background comes from the ambient `PlaygroundThemeData` unless a
/// per-call
/// [background] overrides it. A design system whose scheme leaves the container
/// roles at plain `surface` sets its stage tint once on its style; a single
/// neutral subject that the default tint would swallow — a tonal or outlined
/// control — passes [background] to override it just for that preview.
class PlaygroundPreview extends StatelessWidget {
  /// Creates a preview stage around [child].
  const PlaygroundPreview({
    required this.child,
    this.maxWidth,
    this.background,
    super.key,
  });

  /// The subject being previewed.
  final Widget child;

  /// Clamps the subject's width.
  ///
  /// Pass the width the real component renders at — showing it wider than it
  /// can ever reach would misinform the eye this stage exists to inform.
  final double? maxWidth;

  /// Overrides the stage's background for this preview only.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final stage =
        background ??
        PlaygroundTheme.of(context).resolveStageBackground(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: stage),
      child: Padding(
        padding: const EdgeInsets.all(inset),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
            child: child,
          ),
        ),
      ),
    );
  }
}
