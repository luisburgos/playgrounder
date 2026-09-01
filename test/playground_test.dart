import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

const List<PlaygroundPreset<int>> _presets = [
  PlaygroundPreset(label: 'Default', config: 0),
  PlaygroundPreset(label: 'Compact', config: 1),
];

/// Pumps a playground at a fixed pane width, with an optional theme.
Future<void> _pumpAt(
  WidgetTester tester,
  double width, {
  int config = 0,
  ValueChanged<int>? onChanged,
  Widget? footer,
  PlaygroundChromeBuilder? chrome,
}) {
  Widget playground = Playground<int>(
    config: config,
    onChanged: onChanged ?? (_) {},
    presets: _presets,
    footer: footer,
    previewBuilder: (context, c) => Text('preview $c'),
    knobsBuilder: (context, c, onChanged) => TextButton(
      onPressed: () => onChanged(c + 1),
      child: const Text('bump'),
    ),
  );
  if (chrome != null) {
    playground = PlaygroundTheme(
      data: PlaygroundThemeData(chromeBuilder: chrome),
      child: playground,
    );
  }

  // The default test viewport is 800px wide, which would clamp a 1000px pane
  // and silently fall into the stacked branch. Size the surface to the pane so
  // the width under test is the width the LayoutBuilder actually measures.
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SizedBox.expand(child: playground)),
    ),
  );
}

class _RedActionChrome extends MaterialPlaygroundChromeBuilder {
  const _RedActionChrome();

  @override
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text('styled $label'),
    );
  }
}

void main() {
  group('Playground layout', () {
    testWidgets('docks the inspector beside the preview above 900px', (
      tester,
    ) async {
      await _pumpAt(tester, 1000);

      // Docked layout puts the inspector in a fixed 300px-wide SizedBox
      // beside the preview; the stacked layout has no such fixed width.
      expect(find.text('preview 0'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 300,
        ),
        findsOneWidget,
      );
    });

    testWidgets('stacks below 900px', (tester) async {
      await _pumpAt(tester, 600);

      expect(find.text('preview 0'), findsOneWidget);
      // The stacked layout has no fixed 300px inspector column.
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 300,
        ),
        findsNothing,
      );
    });
  });

  group('Playground custom layout', () {
    Future<void> pumpSized(
      WidgetTester tester,
      double width, {
      double inspectorWidth = 300,
      double splitBreakpoint = 900,
    }) {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: Playground<int>(
                config: 0,
                onChanged: (_) {},
                presets: _presets,
                inspectorWidth: inspectorWidth,
                splitBreakpoint: splitBreakpoint,
                previewBuilder: (context, c) => Text('preview $c'),
                knobsBuilder: (context, c, onChanged) => const Text('knobs'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('docks the inspector at the given inspectorWidth', (
      tester,
    ) async {
      await pumpSized(tester, 1000, inspectorWidth: 420);

      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 420),
        findsOneWidget,
      );
      // The default width is not used.
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 300),
        findsNothing,
      );
    });

    testWidgets('a lower splitBreakpoint docks at a width that would '
        'otherwise stack', (tester) async {
      // 700 is below the default 900 (would stack), but above a 600 override.
      await pumpSized(tester, 700, splitBreakpoint: 600);

      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 300),
        findsOneWidget,
      );
    });

    testWidgets('a higher splitBreakpoint stacks at a width that would '
        'otherwise dock', (tester) async {
      // 1000 is above the default 900 (would dock), but below a 1200 override.
      await pumpSized(tester, 1000, splitBreakpoint: 1200);

      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 300),
        findsNothing,
      );
    });
  });

  group('Playground preset tracking', () {
    testWidgets('marks the matching preset active', (tester) async {
      await _pumpAt(tester, 1000, config: 1);

      // 'Compact' (config 1) is active, so its row shows the selected icon.
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('reports Custom when the config matches no preset', (
      tester,
    ) async {
      await _pumpAt(tester, 1000, config: 99);

      expect(
        find.text('Custom — the knobs no longer match a preset.'),
        findsOneWidget,
      );
    });
  });

  group('Playground config round-trip', () {
    testWidgets('a knob change flows through onChanged', (tester) async {
      int? next;
      await _pumpAt(tester, 1000, onChanged: (c) => next = c);

      // Move to the Custom tab so the knobs (the bump button) are visible.
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('bump'));

      expect(next, 1);
    });
  });

  group('Playground styling', () {
    testWidgets('uses stock Material chrome with no theme', (tester) async {
      await _pumpAt(
        tester,
        1000,
        footer: PlaygroundActions(
          actions: [PlaygroundAction(label: 'Copy', onPressed: () {})],
        ),
      );

      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('styled Copy'), findsNothing);
    });

    testWidgets('uses the injected chrome when themed', (tester) async {
      await _pumpAt(
        tester,
        1000,
        footer: PlaygroundActions(
          actions: [PlaygroundAction(label: 'Copy', onPressed: () {})],
        ),
        chrome: const _RedActionChrome(),
      );

      expect(find.text('styled Copy'), findsOneWidget);
    });
  });

  group('Playground footer', () {
    testWidgets('renders the footer widget pinned in the inspector', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: Playground<int>(
                config: 0,
                onChanged: (_) {},
                presets: _presets,
                footer: const Text('footer content'),
                previewBuilder: (context, c) => Text('preview $c'),
                knobsBuilder: (context, c, onChanged) => const Text('knobs'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('footer content'), findsOneWidget);
    });
  });
}
