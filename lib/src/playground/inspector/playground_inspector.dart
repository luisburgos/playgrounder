import 'package:flutter/material.dart';
import 'package:playgrounder/src/_tokens.dart';
import 'package:playgrounder/src/playground/inspector/playground_footer.dart';
import 'package:playgrounder/src/playground/inspector/playground_presets.dart';
import 'package:playgrounder/src/playground/playground_preset.dart';
import 'package:playgrounder/src/theme/playground_theme.dart';

/// The docked region where a playground's subject is examined and adjusted.
///
/// Named for the role a design tool's side region plays rather than for where
/// it sits: it moves below the preview on narrow viewports, so "sidebar" would
/// go stale exactly where the layout is most responsive.
///
/// Unlike a selection-driven inspector, this one always has exactly one
/// subject. Nothing here reflects a selection.
class PlaygroundInspector<T> extends StatefulWidget {
  /// Creates the inspector.
  const PlaygroundInspector({
    required this.presets,
    required this.active,
    required this.onSelected,
    required this.knobs,
    this.footer,
    this.bordered = true,
    super.key,
  });

  /// The available configurations. Empty hides the Presets tab.
  final List<PlaygroundPreset<T>> presets;

  /// The preset matching the current configuration, or null when custom.
  final PlaygroundPreset<T>? active;

  /// Called with a picked preset's configuration.
  final ValueChanged<T> onSelected;

  /// The caller's controls for the current configuration.
  final Widget knobs;

  /// Arbitrary content pinned to the bottom, or null for none.
  final Widget? footer;

  /// Whether to draw the hairline on the leading edge.
  ///
  /// True when docked beside the preview, false when stacked below it — there
  /// the two meet on the other axis and a horizontal divider does that job.
  ///
  /// This is container knowledge leaking into content: the inspector has to
  /// know which layout encloses it in order to draw its own edge. That is
  /// tolerable while there are two layouts, but a third — the planned mobile
  /// FAB opening the controls in a sheet — would make it a three-way flag on a
  /// widget that should not care. The edge belongs to whatever contains the
  /// inspector. See issue #8.
  final bool bordered;

  @override
  State<PlaygroundInspector<T>> createState() => _PlaygroundInspectorState<T>();
}

class _PlaygroundInspectorState<T> extends State<PlaygroundInspector<T>>
    with SingleTickerProviderStateMixin {
  // Created in initState rather than as a `late final` field initializer.
  // With empty presets the tabs never render, so a lazy initializer would
  // first run inside dispose() — and creating a ticker there looks up
  // TickerMode on a deactivated element, which throws. A presetless
  // playground is the case that hit it.
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// The tabbed controls: presets pour into the same state the knobs edit.
  ///
  /// The panels are swapped rather than put in a [TabBarView]. A TabBarView
  /// has no intrinsic height, so it needs a fixed one — which either clips the
  /// taller panel or strands the shorter under empty space. Swapping lets each
  /// panel size itself, at the cost of the horizontal swipe between tabs.
  Widget _buildControls(BuildContext context) {
    if (widget.presets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(inset),
        child: widget.knobs,
      );
    }

    final chrome = PlaygroundTheme.of(context).chromeBuilder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chrome.buildTabs(
          context,
          controller: _tabs,
          labels: const ['Presets', 'Custom'],
        ),
        Padding(
          padding: const EdgeInsets.all(inset),
          child: AnimatedBuilder(
            animation: _tabs.animation!,
            builder: (context, _) => _tabs.index == 0
                ? PlaygroundPresets<T>(
                    presets: widget.presets,
                    active: widget.active,
                    onSelected: widget.onSelected,
                  )
                : widget.knobs,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only the controls scroll; the footer is pinned to the bottom by the
    // Expanded above it, so it stays reachable however long the control
    // list grows. Unbounded height means there is no bottom to pin to, so the
    // stacked layout lets both size themselves instead.
    final content = widget.bordered
        ? Column(
            children: [
              Expanded(
                child: SingleChildScrollView(child: _buildControls(context)),
              ),
              if (widget.footer != null)
                PlaygroundFooter(child: widget.footer!),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControls(context),
              if (widget.footer != null)
                PlaygroundFooter(child: widget.footer!),
            ],
          );

    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: widget.bordered
            ? Border(left: BorderSide(color: scheme.outlineVariant))
            : null,
      ),
      child: content,
    );
  }
}
