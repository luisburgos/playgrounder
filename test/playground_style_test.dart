import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playgrounder/playgrounder.dart';

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

  group('PlaygroundStyleScope.updateShouldNotify', () {
    testWidgets('notifies only when the style changes', (tester) async {
      const a = PlaygroundStyle();
      const b = _PartialStyle();

      const scopeA = PlaygroundStyleScope(style: a, child: SizedBox());
      const scopeSameStyle = PlaygroundStyleScope(style: a, child: SizedBox());
      const scopeB = PlaygroundStyleScope(style: b, child: SizedBox());

      expect(scopeA.updateShouldNotify(scopeSameStyle), isFalse);
      expect(scopeA.updateShouldNotify(scopeB), isTrue);
    });
  });
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
