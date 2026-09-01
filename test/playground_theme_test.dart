import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

/// A chrome builder overriding every point, to prove injection reaches them.
class _AltChrome extends PlaygroundChromeBuilder {
  const _AltChrome();

  @override
  Widget buildTabs(
    BuildContext context, {
    required TabController controller,
    required List<String> labels,
  }) => Row(children: [for (final l in labels) Text('tab:$l')]);

  @override
  Widget buildPresetRow(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) => TextButton(onPressed: onPressed, child: Text('preset:$label'));

  @override
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) => TextButton(onPressed: onPressed, child: Text('action:$label'));
}

void main() {
  group('PlaygroundThemeData', () {
    test('defaults to the Material chrome builder', () {
      expect(
        const PlaygroundThemeData().chromeBuilder,
        isA<MaterialPlaygroundChromeBuilder>(),
      );
    });

    test('defaults the layout to the documented constants', () {
      const data = PlaygroundThemeData();
      expect(data.inspectorWidth, kPlaygroundInspectorWidth);
      expect(data.splitBreakpoint, kPlaygroundSplitBreakpoint);
      expect(data.stageBackground, isNull);
    });

    test('has value equality over every field', () {
      expect(const PlaygroundThemeData(), const PlaygroundThemeData());
      expect(
        const PlaygroundThemeData().hashCode,
        const PlaygroundThemeData().hashCode,
      );
      expect(
        const PlaygroundThemeData(),
        isNot(const PlaygroundThemeData(inspectorWidth: 400)),
      );
      expect(
        const PlaygroundThemeData(),
        isNot(const PlaygroundThemeData(splitBreakpoint: 600)),
      );
      expect(
        const PlaygroundThemeData(),
        isNot(const PlaygroundThemeData(stageBackground: Color(0xFF123456))),
      );
      expect(
        const PlaygroundThemeData(),
        isNot(const PlaygroundThemeData(chromeBuilder: _AltChrome())),
      );
    });

    test('copyWith replaces only what it is given', () {
      const base = PlaygroundThemeData();
      final copy = base.copyWith(inspectorWidth: 420);

      expect(copy.inspectorWidth, 420);
      expect(copy.splitBreakpoint, base.splitBreakpoint);
      expect(copy.chromeBuilder, base.chromeBuilder);
      expect(copy.stageBackground, base.stageBackground);
      expect(base.copyWith(), base);
    });

    testWidgets('resolveStageBackground falls back to the scheme', (
      tester,
    ) async {
      late Color resolved;
      late Color expected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = const PlaygroundThemeData().resolveStageBackground(
                context,
              );
              expected = Theme.of(context).colorScheme.surfaceContainerHighest;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, expected);
    });

    testWidgets('resolveStageBackground prefers an explicit color', (
      tester,
    ) async {
      late Color resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = const PlaygroundThemeData(
                stageBackground: Color(0xFF123456),
              ).resolveStageBackground(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, const Color(0xFF123456));
    });
  });

  group('PlaygroundTheme.of', () {
    testWidgets('returns the default data with no theme in the tree', (
      tester,
    ) async {
      late PlaygroundThemeData resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = PlaygroundTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, const PlaygroundThemeData());
    });

    testWidgets('returns the injected data when wrapped', (tester) async {
      late PlaygroundThemeData resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: PlaygroundTheme(
            data: const PlaygroundThemeData(inspectorWidth: 420),
            child: Builder(
              builder: (context) {
                resolved = PlaygroundTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved.inspectorWidth, 420);
    });

    testWidgets('notifies dependents only when the data changes', (
      tester,
    ) async {
      var builds = 0;
      final dependent = Builder(
        builder: (context) {
          PlaygroundTheme.of(context);
          builds++;
          return const SizedBox.shrink();
        },
      );
      Widget build(PlaygroundThemeData data) => Directionality(
        textDirection: TextDirection.ltr,
        child: PlaygroundTheme(data: data, child: dependent),
      );

      await tester.pumpWidget(build(const PlaygroundThemeData()));
      expect(builds, 1);

      await tester.pumpWidget(build(const PlaygroundThemeData()));
      expect(builds, 1);

      await tester.pumpWidget(
        build(const PlaygroundThemeData(inspectorWidth: 420)),
      );
      expect(builds, 2);
    });
  });

  group('MaterialPlaygroundChromeBuilder', () {
    test('compares equal to another instance', () {
      expect(
        const MaterialPlaygroundChromeBuilder(),
        const MaterialPlaygroundChromeBuilder(),
      );
      expect(
        const MaterialPlaygroundChromeBuilder().hashCode,
        const MaterialPlaygroundChromeBuilder().hashCode,
      );
      expect(
        const MaterialPlaygroundChromeBuilder(),
        isNot(const _AltChrome()),
      );
    });
  });
}
