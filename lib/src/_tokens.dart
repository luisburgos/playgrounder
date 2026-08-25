/// Layout constants used across the playground's private widgets.
///
/// Named for their role rather than a design scale: playgrounder has no design
/// system of its own, and these are the few fixed measures the scaffolding
/// needs. A consumer restyles the chrome through `PlaygroundStyle`; it does not
/// reach in to retune these.
library;

/// The gap between stacked controls in a row or column.
const double gap = 8;

/// The padding inset around a padded region (the inspector's control block,
/// the preview stage).
const double inset = 24;

/// A hairline divider's thickness.
const double hairline = 1;
