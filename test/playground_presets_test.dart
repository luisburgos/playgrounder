import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';
import 'package:playgrounder/src/playground/inspector/playground_presets.dart';

const List<PlaygroundPreset<int>> _presets = [
  PlaygroundPreset(label: 'Default', config: 0, summary: 'the everyday shape'),
  PlaygroundPreset(label: 'Compact', config: 1),
];

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('PlaygroundPresets', () {
    testWidgets('renders one row per preset', (tester) async {
      await _pump(
        tester,
        PlaygroundPresets<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
        ),
      );

      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Compact'), findsOneWidget);
    });

    testWidgets('shows the active preset summary', (tester) async {
      await _pump(
        tester,
        PlaygroundPresets<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
        ),
      );

      expect(find.text('the everyday shape'), findsOneWidget);
    });

    testWidgets('shows the Custom caption when nothing is active', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaygroundPresets<int>(
          presets: _presets,
          active: null,
          onSelected: (_) {},
        ),
      );

      expect(
        find.text('Custom — the knobs no longer match a preset.'),
        findsOneWidget,
      );
    });

    testWidgets('an active preset without a summary falls back to Custom', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaygroundPresets<int>(
          presets: _presets,
          active: _presets[1], // 'Compact' has no summary
          onSelected: (_) {},
        ),
      );

      expect(
        find.text('Custom — the knobs no longer match a preset.'),
        findsOneWidget,
      );
    });

    testWidgets('reports the picked config', (tester) async {
      int? picked;
      await _pump(
        tester,
        PlaygroundPresets<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (c) => picked = c,
        ),
      );

      await tester.tap(find.text('Compact'));
      expect(picked, 1);
    });
  });
}
