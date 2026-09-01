import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

/// Slot builders overriding every point, to prove injection reaches them.
Widget _altTabs(BuildContext context, PlaygroundTabsDetails d) =>
    Wrap(children: [for (final l in d.labels) Text('tab:$l')]);

Widget _altPresetRow(BuildContext context, PlaygroundPresetRowDetails d) =>
    TextButton(onPressed: d.onPressed, child: Text('preset:${d.label}'));

Widget _altAction(BuildContext context, PlaygroundActionDetails d) =>
    TextButton(onPressed: d.onPressed, child: Text('action:${d.label}'));

void main() {
  group('PlaygroundThemeData', () {
    test('every slot builder defaults to null', () {
      const data = PlaygroundThemeData();
      expect(data.tabsBuilder, isNull);
      expect(data.presetRowBuilder, isNull);
      expect(data.actionButtonBuilder, isNull);
    });

    test('a null slot resolves to the Material default', () {
      const data = PlaygroundThemeData();
      expect(data.resolvedTabsBuilder, buildMaterialTabs);
      expect(data.resolvedPresetRowBuilder, buildMaterialPresetRow);
      expect(data.resolvedActionButtonBuilder, buildMaterialActionButton);
    });

    test('a set slot resolves to the override', () {
      const data = PlaygroundThemeData(presetRowBuilder: _altPresetRow);
      expect(data.resolvedPresetRowBuilder, _altPresetRow);
      // The others stay on their defaults: overriding one slot leaves the
      // rest alone, which is the point of per-slot builders.
      expect(data.resolvedTabsBuilder, buildMaterialTabs);
      expect(data.resolvedActionButtonBuilder, buildMaterialActionButton);
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
        isNot(const PlaygroundThemeData(tabsBuilder: _altTabs)),
      );
      expect(
        const PlaygroundThemeData(),
        isNot(const PlaygroundThemeData(presetRowBuilder: _altPresetRow)),
      );
      expect(
        const PlaygroundThemeData(),
        isNot(const PlaygroundThemeData(actionButtonBuilder: _altAction)),
      );
      // Hoisted functions compare by identity, so an equal-looking theme is
      // genuinely equal — which is why the docs say to hoist them.
      expect(
        const PlaygroundThemeData(tabsBuilder: _altTabs),
        const PlaygroundThemeData(tabsBuilder: _altTabs),
      );
    });

    test('copyWith replaces only what it is given', () {
      const base = PlaygroundThemeData();
      final copy = base.copyWith(inspectorWidth: 420);

      expect(copy.inspectorWidth, 420);
      expect(copy.splitBreakpoint, base.splitBreakpoint);
      expect(copy.tabsBuilder, base.tabsBuilder);
      expect(copy.presetRowBuilder, base.presetRowBuilder);
      expect(copy.actionButtonBuilder, base.actionButtonBuilder);
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

  group('the Material slot builders', () {
    testWidgets('render the stock chrome', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Builder(
                  builder: (c) => buildMaterialPresetRow(
                    c,
                    PlaygroundPresetRowDetails(
                      label: 'Sel',
                      selected: true,
                      onPressed: () {},
                    ),
                  ),
                ),
                Builder(
                  builder: (c) => buildMaterialPresetRow(
                    c,
                    PlaygroundPresetRowDetails(
                      label: 'Unsel',
                      selected: false,
                      onPressed: () {},
                    ),
                  ),
                ),
                Builder(
                  builder: (c) => buildMaterialActionButton(
                    c,
                    PlaygroundActionDetails(label: 'Act', onPressed: () {}),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sel'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Act'), findsOneWidget);
    });
  });
}
