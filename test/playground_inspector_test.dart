import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';
import 'package:playgrounder/src/playground/inspector/playground_inspector.dart';

const List<PlaygroundPreset<int>> _presets = [
  PlaygroundPreset(label: 'Default', config: 0),
  PlaygroundPreset(label: 'Compact', config: 1),
];

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('PlaygroundInspector', () {
    testWidgets('with presets, shows the Presets/Custom tabs and the list', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: const [],
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Presets'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      // Presets tab is selected first, so the preset rows show.
      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('switching to the Custom tab shows the knobs', (tester) async {
      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: const [],
        ),
      );

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(find.text('the knobs'), findsOneWidget);
    });

    testWidgets('with no presets, shows only the knobs and no tabs', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: const [],
          active: null,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: const [],
        ),
      );

      expect(find.byType(TabBar), findsNothing);
      expect(find.text('the knobs'), findsOneWidget);
    });

    testWidgets(
      'a presetless inspector disposes without a ticker crash',
      (tester) async {
        // The TabController is built in initState, not a lazy `late final`.
        // With empty presets the tabs never render; a lazy initializer would
        // first run in dispose() and throw looking up TickerMode on a
        // deactivated element. Pumping this inspector and then replacing it
        // exercises that dispose path — it must not throw.
        await _pump(
          tester,
          PlaygroundInspector<int>(
            presets: const [],
            active: null,
            onSelected: (_) {},
            knobs: const Text('the knobs'),
            actions: const [],
          ),
        );

        await _pump(tester, const SizedBox());

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('bordered draws a leading border; unbordered does not', (
      tester,
    ) async {
      Border? borderOf(WidgetTester t) {
        final box = t.widget<DecoratedBox>(
          find
              .descendant(
                of: find.byType(PlaygroundInspector<int>),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        return (box.decoration as BoxDecoration).border as Border?;
      }

      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: const [],
        ),
      );
      expect(borderOf(tester), isNotNull);

      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: const [],
          bordered: false,
        ),
      );
      expect(borderOf(tester), isNull);
    });

    testWidgets('renders pinned actions when given', (tester) async {
      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: [PlaygroundAction(label: 'Copy', onPressed: () {})],
        ),
      );

      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('renders pinned actions in the unbordered layout', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaygroundInspector<int>(
          presets: _presets,
          active: _presets.first,
          onSelected: (_) {},
          knobs: const Text('the knobs'),
          actions: [PlaygroundAction(label: 'Reset', onPressed: () {})],
          bordered: false,
        ),
      );

      expect(find.text('Reset'), findsOneWidget);
    });
  });
}
