import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

void main() {
  group('KnobRelevance', () {
    test('.always is relevant with an empty reason', () {
      const relevance = KnobRelevance.always();

      expect(relevance.isRelevant, isTrue);
      expect(relevance.reason, isEmpty);
    });

    test('.when carries the relevance and reason it is given', () {
      const relevance = KnobRelevance.when(
        isRelevant: false,
        reason: 'the picker field exposes no swatch size',
      );

      expect(relevance.isRelevant, isFalse);
      expect(relevance.reason, 'the picker field exposes no swatch size');
    });
  });
}
