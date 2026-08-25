import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('KnobGroup', () {
    testWidgets('renders its title in caps above its children', (
      tester,
    ) async {
      await _pump(
        tester,
        const KnobGroup(
          title: 'Layout',
          children: [Text('a child')],
        ),
      );

      expect(find.text('LAYOUT'), findsOneWidget);
      expect(find.text('a child'), findsOneWidget);
    });

    testWidgets('hides the whole group when irrelevant', (tester) async {
      await _pump(
        tester,
        const KnobGroup(
          title: 'Layout',
          relevantWhen: KnobRelevance.when(
            isRelevant: false,
            reason: 'nothing here applies',
          ),
          children: [Text('a child')],
        ),
      );

      expect(find.text('LAYOUT'), findsNothing);
      expect(find.text('a child'), findsNothing);
    });
  });
}
