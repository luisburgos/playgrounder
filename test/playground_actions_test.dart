import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('PlaygroundActions', () {
    testWidgets('renders one styled button per action', (tester) async {
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

    testWidgets('is content only: no divider of its own', (tester) async {
      // The footer region supplies the divider and inset; composing this
      // widget must not double the chrome.
      await _pump(
        tester,
        PlaygroundActions(
          actions: [PlaygroundAction(label: 'Copy', onPressed: () {})],
        ),
      );

      expect(find.byType(Divider), findsNothing);
    });
  });
}
