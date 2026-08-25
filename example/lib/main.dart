import 'package:flutter/material.dart';
import 'package:playgrounder/playgrounder.dart';

void main() => runApp(const PlaygrounderExampleApp());

/// A single playground with stock Material chrome — playgrounder's zero-config
/// path. The whole screen is the playground: a preview stage beside a docked
/// inspector of presets, knobs, and one action. No app shell competes with it.
class PlaygrounderExampleApp extends StatelessWidget {
  const PlaygrounderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'playgrounder',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const Scaffold(body: SafeArea(child: _CardPlayground())),
    );
  }
}

/// The demoed subject: a small card whose density, image, and corner radius
/// are driven by knobs, with two presets and a copy action. It exercises every
/// public playgrounder symbol.
class _CardPlayground extends StatefulWidget {
  const _CardPlayground();

  @override
  State<_CardPlayground> createState() => _CardPlaygroundState();
}

class _CardPlaygroundState extends State<_CardPlayground> {
  var _config = const _CardConfig();

  static const _radiusSteps = [
    ScaleStep('none', 0),
    ScaleStep('sm', 8),
    ScaleStep('md', 16),
    ScaleStep('lg', 24),
  ];

  @override
  Widget build(BuildContext context) {
    return Playground<_CardConfig>(
      config: _config,
      onChanged: (c) => setState(() => _config = c),
      presets: const [
        PlaygroundPreset(
          label: 'Comfortable',
          config: _CardConfig(),
          summary: 'The everyday card.',
        ),
        PlaygroundPreset(
          label: 'Dense',
          config: _CardConfig(
            dense: true,
            radius: ScaleStep('sm', 8),
            showImage: false,
          ),
          summary: 'Tight rows, no image.',
        ),
      ],
      actions: [
        PlaygroundAction(
          label: 'Copy config',
          icon: const Icon(Icons.copy),
          onPressed: () => _copyConfig(context),
        ),
      ],
      previewMaxWidth: 320,
      previewBuilder: (context, config) => _Card(config: config),
      knobsBuilder: (context, config, onChanged) => KnobGroup(
        title: 'Layout',
        children: [
          SwitchKnob(
            label: 'Dense',
            value: config.dense,
            onChanged: (v) => onChanged(config.copyWith(dense: v)),
          ),
          SwitchKnob(
            label: 'Show image',
            value: config.showImage,
            onChanged: (v) => onChanged(config.copyWith(showImage: v)),
          ),
          ScaleKnob(
            label: 'Corner radius',
            value: config.radius,
            values: _radiusSteps,
            onChanged: (v) => onChanged(config.copyWith(radius: v)),
          ),
        ],
      ),
    );
  }

  void _copyConfig(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Config: $_config')),
    );
  }
}

/// The card's configuration.
@immutable
class _CardConfig {
  const _CardConfig({
    this.dense = false,
    this.showImage = true,
    this.radius = const ScaleStep('md', 16),
  });

  final bool dense;
  final bool showImage;
  final ScaleStep radius;

  _CardConfig copyWith({bool? dense, bool? showImage, ScaleStep? radius}) {
    return _CardConfig(
      dense: dense ?? this.dense,
      showImage: showImage ?? this.showImage,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _CardConfig &&
      other.dense == dense &&
      other.showImage == showImage &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(dense, showImage, radius);

  @override
  String toString() =>
      'dense=$dense, showImage=$showImage, radius=${radius.name}';
}

/// The previewed subject.
class _Card extends StatelessWidget {
  const _Card({required this.config});

  final _CardConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = config.dense ? 12.0 : 20.0;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.radius.value),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config.showImage)
              Container(
                width: double.infinity,
                height: 96,
                margin: EdgeInsets.only(bottom: pad),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(config.radius.value),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            Text('Card title', style: theme.textTheme.titleMedium),
            SizedBox(height: config.dense ? 4 : 8),
            Text(
              'A short line of supporting text under the title.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
