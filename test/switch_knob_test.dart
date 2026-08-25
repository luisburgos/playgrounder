import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('SwitchKnob', () {
    testWidgets('renders its label and reflects its value', (tester) async {
      await _pump(
        tester,
        SwitchKnob(label: 'Dense', value: true, onChanged: (_) {}),
      );

      expect(find.text('Dense'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('reports the toggled value', (tester) async {
      bool? toggled;
      await _pump(
        tester,
        SwitchKnob(
          label: 'Dense',
          value: false,
          onChanged: (v) => toggled = v,
        ),
      );

      await tester.tap(find.byType(Switch));
      expect(toggled, isTrue);
    });

    testWidgets('hides to a shrink box when irrelevant', (tester) async {
      await _pump(
        tester,
        SwitchKnob(
          label: 'Dense',
          value: false,
          relevantWhen: const KnobRelevance.when(
            isRelevant: false,
            reason: 'no density to toggle',
          ),
          onChanged: (_) {},
        ),
      );

      expect(find.byType(Switch), findsNothing);
      expect(find.text('Dense'), findsNothing);
    });
  });
}
