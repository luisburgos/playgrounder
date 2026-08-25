import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

void main() {
  group('PlaygroundPreset', () {
    test('carries its label, config, and summary', () {
      const preset = PlaygroundPreset(
        label: 'Default',
        config: 42,
        summary: 'the everyday shape',
      );

      expect(preset.label, 'Default');
      expect(preset.config, 42);
      expect(preset.summary, 'the everyday shape');
    });

    test('summary is optional', () {
      const preset = PlaygroundPreset(label: 'Bare', config: 1);

      expect(preset.summary, isNull);
    });

    test('two presets with the same fields are equal', () {
      const a = PlaygroundPreset(label: 'X', config: 1, summary: 's');
      const b = PlaygroundPreset(label: 'X', config: 1, summary: 's');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a differing config makes presets unequal', () {
      const a = PlaygroundPreset(label: 'X', config: 1);
      const b = PlaygroundPreset(label: 'X', config: 2);

      expect(a, isNot(b));
    });
  });
}
