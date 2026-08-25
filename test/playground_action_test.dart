import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

void main() {
  group('PlaygroundAction', () {
    test('carries its label, callback, and optional icon', () {
      var pressed = false;
      const icon = Icon(IconData(0x1));
      final action = PlaygroundAction(
        label: 'Copy',
        onPressed: () => pressed = true,
        icon: icon,
      );

      expect(action.label, 'Copy');
      expect(action.icon, icon);

      action.onPressed();
      expect(pressed, isTrue);
    });

    test('icon is optional', () {
      final action = PlaygroundAction(label: 'Reset', onPressed: () {});

      expect(action.icon, isNull);
    });
  });
}
