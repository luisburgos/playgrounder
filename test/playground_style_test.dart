// Exercises the deprecated 0.2.0 seam on purpose: it must keep working until
// it is removed in 0.4.0, which is exactly what these tests assert.
// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';
import 'package:playgrounder/src/playground/preview/playground_preview.dart';

/// A style that overrides only the action button, to prove the other three
/// points keep their Material defaults.
class _PartialStyle extends PlaygroundStyle {
  const _PartialStyle();

  @override
  Widget buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return TextButton(onPressed: onPressed, child: Text('custom $label'));
  }
}

void main() {
  group('PlaygroundStyleScope.of', () {
    testWidgets('returns a default style when no scope is in the tree', (
      tester,
    ) async {
      PlaygroundStyle? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = PlaygroundStyleScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved, isNotNull);
      expect(resolved.runtimeType, PlaygroundStyle);
    });

    testWidgets('returns the injected style when scoped', (tester) async {
      const injected = _PartialStyle();
      PlaygroundStyle? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: PlaygroundStyleScope(
            style: injected,
            child: Builder(
              builder: (context) {
                resolved = PlaygroundStyleScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved, same(injected));
    });
  });

  group('default Material chrome', () {
    testWidgets('buildTabs renders a TabBar over the labels', (tester) async {
      await _pumpStyled(tester, (context, style) {
        return DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) => style.buildTabs(
              context,
              controller: DefaultTabController.of(context),
              labels: const ['Presets', 'Custom'],
            ),
          ),
        );
      });

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Presets'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('buildPresetRow shows a tonal button with a check when '
        'selected', (tester) async {
      await _pumpStyled(tester, (context, style) {
        return style.buildPresetRow(
          context,
          label: 'Default',
          selected: true,
          onPressed: () {},
        );
      });

      expect(find.text('Default'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('buildPresetRow is an outlined button with no icon when '
        'unselected', (tester) async {
      await _pumpStyled(tester, (context, style) {
        return style.buildPresetRow(
          context,
          label: 'Compact',
          selected: false,
          onPressed: () {},
        );
      });

      expect(find.text('Compact'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('buildActionButton fires its callback', (tester) async {
      var pressed = false;
      await _pumpStyled(tester, (context, style) {
        return style.buildActionButton(
          context,
          label: 'Copy',
          icon: const Icon(Icons.copy),
          onPressed: () => pressed = true,
        );
      });

      await tester.tap(find.text('Copy'));
      expect(pressed, isTrue);
    });

    testWidgets('buildActionButton renders without an icon', (tester) async {
      await _pumpStyled(tester, (context, style) {
        return style.buildActionButton(
          context,
          label: 'Reset',
          onPressed: () {},
        );
      });

      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('stageBackground resolves surfaceContainerHighest', (
      tester,
    ) async {
      late Color background;
      late ColorScheme scheme;
      await _pumpStyled(tester, (context, style) {
        background = style.stageBackground(context);
        scheme = Theme.of(context).colorScheme;
        return const SizedBox();
      });

      expect(background, scheme.surfaceContainerHighest);
    });
  });

  group('partial override', () {
    testWidgets('keeps the base defaults for un-overridden points', (
      tester,
    ) async {
      const style = _PartialStyle();
      await _pumpStyled(
        tester,
        (context, s) => Column(
          children: [
            s.buildActionButton(context, label: 'A', onPressed: () {}),
            s.buildPresetRow(
              context,
              label: 'P',
              selected: false,
              onPressed: () {},
            ),
          ],
        ),
        style: style,
      );

      // The overridden action button is the custom TextButton...
      expect(find.text('custom A'), findsOneWidget);
      // ...while the un-overridden preset row is still the default outlined
      // one (unselected).
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('PlaygroundStyleScope rebuilds', () {
    testWidgets('notifies dependents only when the style changes', (
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
      Widget build(PlaygroundStyle style) => MaterialApp(
        home: PlaygroundStyleScope(style: style, child: dependent),
      );

      await tester.pumpWidget(build(const PlaygroundStyle()));
      expect(builds, 1);

      // An equal style is the same value, so nothing rebuilds.
      await tester.pumpWidget(build(const PlaygroundStyle()));
      expect(builds, 1);

      await tester.pumpWidget(build(const _PartialStyle()));
      expect(builds, 2);
    });
  });
  group('the deprecated seam still reaches the playground', () {
    // The shim's whole purpose: an override on the old class must still be
    // what the playground renders. Without these, the adapter's forwarding
    // could silently stop working and only a consumer would notice.
    testWidgets('a style override drives tabs, presets and actions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaygroundStyleScope(
              style: const _AllPointsStyle(),
              child: Playground<int>(
                config: 0,
                onChanged: (_) {},
                presets: const [PlaygroundPreset(label: 'One', config: 0)],
                footer: PlaygroundActions(
                  actions: [
                    PlaygroundAction(label: 'Copy', onPressed: () {}),
                  ],
                ),
                previewBuilder: (context, c) => const Text('subject'),
                knobsBuilder: (context, c, onChanged) => const Text('knobs'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('tabs:Presets'), findsOneWidget);
      expect(find.text('preset:One'), findsOneWidget);
      expect(find.text('action:Copy'), findsOneWidget);
    });

    testWidgets('a style stage background reaches the preview', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlaygroundStyleScope(
            style: _AllPointsStyle(),
            child: PlaygroundPreview(child: Text('subject')),
          ),
        ),
      );

      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(PlaygroundPreview),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (box.decoration as BoxDecoration).color,
        const Color(0xFF00FF00),
      );
    });

    testWidgets('the adapter delegates equality to the wrapped style', (
      tester,
    ) async {
      // Equality is what keeps updateShouldNotify honest for a consumer that
      // has not migrated, and it is delegated to the wrapped style.
      late PlaygroundChromeBuilder builder;
      await tester.pumpWidget(
        MaterialApp(
          home: PlaygroundStyleScope(
            style: const _AllPointsStyle(),
            child: Builder(
              builder: (context) {
                builder = PlaygroundTheme.of(context).chromeBuilder;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Hashed explicitly: updateShouldNotify compares with == only, so
      // nothing else in the tree exercises the delegated hashCode.
      expect(builder.hashCode, const _AllPointsStyle().hashCode);
      expect(builder, isNot(const MaterialPlaygroundChromeBuilder()));
    });
  });
}

/// A style overriding every point, including the stage.
@immutable
class _AllPointsStyle extends PlaygroundStyle {
  const _AllPointsStyle();

  @override
  Widget buildTabs(
    BuildContext context, {
    required TabController controller,
    required List<String> labels,
  }) => Wrap(children: [for (final l in labels) Text('tabs:$l')]);

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

  @override
  Color stageBackground(BuildContext context) => const Color(0xFF00FF00);

  @override
  bool operator ==(Object other) => other is _AllPointsStyle;

  @override
  int get hashCode => (_AllPointsStyle).hashCode;
}

/// Pumps [builder] with a resolved [PlaygroundStyle] in a Material context.
Future<void> _pumpStyled(
  WidgetTester tester,
  Widget Function(BuildContext context, PlaygroundStyle style) builder, {
  PlaygroundStyle style = const PlaygroundStyle(),
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) => builder(context, style)),
      ),
    ),
  );
}
