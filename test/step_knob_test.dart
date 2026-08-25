import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

enum _Size { sm, md, lg }

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('StepKnob', () {
    testWidgets('renders the label and the current step readout', (
      tester,
    ) async {
      await _pump(
        tester,
        StepKnob<_Size>(
          label: 'Size',
          value: _Size.md,
          values: _Size.values,
          labelOf: (s) => s.name,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Size'), findsOneWidget);
      expect(find.text('md'), findsOneWidget);
    });

    testWidgets('the slider snaps to one division per interval', (
      tester,
    ) async {
      await _pump(
        tester,
        StepKnob<_Size>(
          label: 'Size',
          value: _Size.sm,
          values: _Size.values,
          labelOf: (s) => s.name,
          onChanged: (_) {},
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0);
      expect(slider.max, 2);
      expect(slider.divisions, 2);
    });

    testWidgets('dragging the slider reports the mapped step', (tester) async {
      _Size? picked;
      await _pump(
        tester,
        StepKnob<_Size>(
          label: 'Size',
          value: _Size.sm,
          values: _Size.values,
          labelOf: (s) => s.name,
          onChanged: (s) => picked = s,
        ),
      );

      // Drag from the far left toward the right; the exact landing step
      // depends on width, so assert only that a later step was reported.
      await tester.drag(find.byType(Slider), const Offset(500, 0));
      expect(picked, isNotNull);
      expect(picked, isNot(_Size.sm));
    });

    testWidgets('hides to a shrink box when irrelevant', (tester) async {
      await _pump(
        tester,
        StepKnob<_Size>(
          label: 'Size',
          value: _Size.md,
          values: _Size.values,
          labelOf: (s) => s.name,
          relevantWhen: const KnobRelevance.when(
            isRelevant: false,
            reason: 'no size to pick',
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.byType(Slider), findsNothing);
      expect(find.text('Size'), findsNothing);
    });
  });
}
