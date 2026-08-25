import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

void main() {
  group('ScaleStep', () {
    test('carries its name and value', () {
      const step = ScaleStep('md', 16);

      expect(step.name, 'md');
      expect(step.value, 16);
    });

    test('two steps with the same name and value are equal', () {
      const a = ScaleStep('lg', 24);
      const b = ScaleStep('lg', 24);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a differing value makes steps unequal', () {
      const a = ScaleStep('lg', 24);
      const b = ScaleStep('lg', 32);

      expect(a, isNot(b));
    });
  });
}
