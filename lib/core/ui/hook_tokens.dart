import 'package:flutter/material.dart';

/// One 4pt spacing grid for the whole app.
///
/// Before this existed the UI mixed 2, 6, 10, 14, 18, 22, 26 and 30 with no
/// logic. Everything now lands on a 4pt step, so vertical rhythm is consistent
/// between screens instead of per-author.
abstract final class HookSpace {
  static const double hair = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 56;

  /// Page gutters: 20 on a phone, 32 once the window is wide enough that the
  /// content would otherwise hug the edge.
  static double gutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= HookBreakpoints.medium ? xxxl : xl;

  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets screen = EdgeInsets.fromLTRB(xl, sm, xl, xxl);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets panel = EdgeInsets.all(xl);
}

/// Corner radii by role, not by taste. `card` matches the theme's own
/// `styling.borderRadius` so custom themes still shape the app.
abstract final class HookRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius all(double r) => BorderRadius.circular(r);
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// The active theme's card radius, clamped into the scale so a wild custom
  /// theme cannot produce a 2px or 80px card.
  static double cardRadius(double base) => base.clamp(sm, lg);

  static BorderRadius card(double base) =>
      BorderRadius.circular(cardRadius(base));

  /// Top-only radius, used by bottom sheets and popovers.
  static BorderRadius sheet(double base) =>
      BorderRadius.vertical(top: Radius.circular(cardRadius(base) + 4));
}

/// The type scale. Seven roles replace twenty-one hand-tuned font sizes.
///
/// Sizes are intentionally close to the previous median (14) so the app keeps
/// its density, but every role is now distinguishable and every role is used
/// consistently: a screen title is always [title], a track title is always
/// [body] with a heavier weight, and metadata is always [label].
class HookType {
  const HookType(this.fontFamily);

  final String fontFamily;

  static const double display = 30;
  static const double title = 22;
  static const double heading = 17;
  static const double body = 15;
  static const double bodySmall = 13;
  static const double label = 12;
  static const double caption = 11;

  TextStyle _s({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.25,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Screen titles and hero numbers.
  TextStyle displayStyle(Color c) => _s(
    size: display,
    weight: FontWeight.w700,
    color: c,
    height: 1.1,
    letterSpacing: -0.8,
  );

  /// Page headers inside a scroll view.
  TextStyle titleStyle(Color c) => _s(
    size: title,
    weight: FontWeight.w700,
    color: c,
    height: 1.15,
    letterSpacing: -0.4,
  );

  /// Section headers ("On your air").
  TextStyle headingStyle(Color c) => _s(
    size: heading,
    weight: FontWeight.w600,
    color: c,
    height: 1.2,
    letterSpacing: -0.15,
  );

  /// Now-playing track title, list-primary text.
  TextStyle strongStyle(Color c) =>
      _s(size: body, weight: FontWeight.w600, color: c, height: 1.25);

  TextStyle bodyStyle(Color c) =>
      _s(size: body, weight: FontWeight.w400, color: c, height: 1.35);

  TextStyle bodySmallStyle(Color c) =>
      _s(size: bodySmall, weight: FontWeight.w400, color: c, height: 1.35);

  /// Metadata, chips, tab labels, button text.
  TextStyle labelStyle(Color c) => _s(
    size: label,
    weight: FontWeight.w500,
    color: c,
    height: 1.2,
    letterSpacing: 0.1,
  );

  /// Timecodes, counters, overlines.
  TextStyle captionStyle(Color c) => _s(
    size: caption,
    weight: FontWeight.w600,
    color: c,
    height: 1.2,
    letterSpacing: 0.3,
  );

  /// Tabular figures for timecodes so the seek bar does not jitter.
  TextStyle numericStyle(Color c) =>
      captionStyle(c)
          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Motion: three durations and two curves. Nothing else.
///
/// `fast` is for state that must feel instant (hover, press, toggle),
/// `base` for content entering or leaving, `slow` for a deliberate, large
/// surface change (screen transition, sheet).
abstract final class HookMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration slower = Duration(milliseconds: 480);

  /// Decelerating curve for anything that enters.
  static const Curve enter = Cubic(0.2, 0.0, 0.0, 1.0);

  /// For symmetric state changes (colour, opacity, size).
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1.0);

  /// For anything that exits — quicker, no bounce.
  static const Curve exit = Cubic(0.4, 0.0, 1.0, 1.0);
}

/// Layout breakpoints. The app was phone-only in practice: a 1180px window got
/// a 760px column and a full-width bottom bar.
abstract final class HookBreakpoints {
  /// Two-pane layouts, rail navigation, inline volume.
  static const double medium = 900;

  /// Room for a persistent now-playing side panel.
  static const double expanded = 1240;

  /// Comfortable reading width for a single column of content.
  static const double readingMax = 780;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;
}
