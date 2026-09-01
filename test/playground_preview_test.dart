import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';
import 'package:playgrounder/src/playground/preview/playground_preview.dart';

/// A theme with a distinctive stage color, to prove the preview reads it.
const _redStage = PlaygroundThemeData(stageBackground: Color(0xFFFF0000));

Color _stageColorOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(PlaygroundPreview),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  group('PlaygroundPreview', () {
    testWidgets('uses the ambient stage background by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlaygroundTheme(
            data: _redStage,
            child: PlaygroundPreview(child: Text('subject')),
          ),
        ),
      );

      expect(_stageColorOf(tester), const Color(0xFFFF0000));
      expect(find.text('subject'), findsOneWidget);
    });

    testWidgets('a per-call background wins over the theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlaygroundTheme(
            data: _redStage,
            child: PlaygroundPreview(
              background: Color(0xFF00FF00),
              child: Text('subject'),
            ),
          ),
        ),
      );

      expect(_stageColorOf(tester), const Color(0xFF00FF00));
    });

    testWidgets('clamps the subject to maxWidth when given', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlaygroundPreview(
            maxWidth: 120,
            child: SizedBox(width: 1000, height: 10),
          ),
        ),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(PlaygroundPreview),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrained.constraints.maxWidth, 120);
    });
  });
}
