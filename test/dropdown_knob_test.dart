import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

enum _Variant { tonal, filled, text }

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('DropdownKnob', () {
    testWidgets('renders its label and the current choice', (tester) async {
      await _pump(
        tester,
        DropdownKnob<_Variant>(
          label: 'Variant',
          value: _Variant.filled,
          values: _Variant.values,
          labelOf: (v) => v.name,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Variant'), findsOneWidget);
      // The selected value shows in the closed button.
      expect(find.text('filled'), findsOneWidget);
    });

    testWidgets('reports the picked choice', (tester) async {
      _Variant? picked;
      await _pump(
        tester,
        DropdownKnob<_Variant>(
          label: 'Variant',
          value: _Variant.tonal,
          values: _Variant.values,
          labelOf: (v) => v.name,
          onChanged: (v) => picked = v,
        ),
      );

      await tester.tap(find.text('tonal'));
      await tester.pumpAndSettle();
      // Two 'text' entries can exist (closed value + menu item); tap the last.
      await tester.tap(find.text('text').last);
      await tester.pumpAndSettle();

      expect(picked, _Variant.text);
    });

    testWidgets('hides to a shrink box when irrelevant', (tester) async {
      await _pump(
        tester,
        DropdownKnob<_Variant>(
          label: 'Variant',
          value: _Variant.tonal,
          values: _Variant.values,
          labelOf: (v) => v.name,
          relevantWhen: const KnobRelevance.when(
            isRelevant: false,
            reason: 'no variant to choose',
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.byType(DropdownButton<_Variant>), findsNothing);
      expect(find.text('Variant'), findsNothing);
    });
  });
}
