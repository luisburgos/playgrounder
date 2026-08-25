import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

const _steps = [
  ScaleStep('sm', 8),
  ScaleStep('md', 16),
  ScaleStep('lg', 24),
];

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('ScaleKnob', () {
    testWidgets('renders the "name — Npx" readout for the current step', (
      tester,
    ) async {
      await _pump(
        tester,
        ScaleKnob(
          label: 'Gap',
          value: _steps[1],
          values: _steps,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Gap'), findsOneWidget);
      expect(find.text('md — 16px'), findsOneWidget);
    });

    testWidgets('reports the picked step', (tester) async {
      ScaleStep? picked;
      await _pump(
        tester,
        ScaleKnob(
          label: 'Gap',
          value: _steps.first,
          values: _steps,
          onChanged: (s) => picked = s,
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(500, 0));
      expect(picked, isNotNull);
      expect(picked, isNot(_steps.first));
    });

    testWidgets('hides when irrelevant', (tester) async {
      await _pump(
        tester,
        ScaleKnob(
          label: 'Gap',
          value: _steps.first,
          values: _steps,
          relevantWhen: const KnobRelevance.when(
            isRelevant: false,
            reason: 'no gap to size',
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.byType(Slider), findsNothing);
      expect(find.text('Gap'), findsNothing);
    });
  });
}
