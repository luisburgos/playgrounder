import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';
import 'package:playgrounder/src/playground/inspector/playground_actions.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('PlaygroundActions', () {
    testWidgets('renders one button per action behind a divider', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaygroundActions(
          actions: [
            PlaygroundAction(label: 'Copy', onPressed: () {}),
            PlaygroundAction(label: 'Reset', onPressed: () {}),
          ],
        ),
      );

      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('fires an action callback', (tester) async {
      var pressed = false;
      await _pump(
        tester,
        PlaygroundActions(
          actions: [
            PlaygroundAction(label: 'Copy', onPressed: () => pressed = true),
          ],
        ),
      );

      await tester.tap(find.text('Copy'));
      expect(pressed, isTrue);
    });
  });
}
