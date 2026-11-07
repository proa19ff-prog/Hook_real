import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';

HookColors _colors(Map<String, dynamic> json) =>
    HookTheme.fromJson({'id': 't', 'colors': json}).colors;

void main() {
  test('light background with dark surface is rebuilt in the light family',
      () {
    final colors = _colors({
      'background': '#F2EDE4', // warm beige
      'surface': '#16181F', // inherited dark fallback
      'surfaceGlass': '#CC0D0E12', // almost-opaque dark glass
      'textPrimary': '#3A2F22',
      'textSecondary': '#6E6558',
    });

    expect(colors.background.computeLuminance() > 0.45, isTrue);
    // The search field / sheets no longer turn black on the beige theme.
    expect(colors.surface.computeLuminance() > 0.45, isTrue);
    final glassOverBg = Color.alphaBlend(colors.surfaceGlass, colors.background);
    expect(glassOverBg.computeLuminance() > 0.45, isTrue);
    // Text keeps its contrast guarantees against the background.
    expect(
      colors.textPrimary.computeLuminance() <
          colors.background.computeLuminance(),
      isTrue,
    );
  });

  test('dark background with light glass is rebuilt as a subtle tint', () {
    final colors = _colors({
      'background': '#0D0E12',
      'surface': '#FFFFFF',
      'surfaceGlass': '#EEEFE3',
    });

    expect(colors.surface.computeLuminance() < 0.45, isTrue);
    final glassOverBg = Color.alphaBlend(colors.surfaceGlass, colors.background);
    expect(glassOverBg.computeLuminance() < 0.45, isTrue);
  });

  test('well-formed themes pass through untouched', () {
    final colors = _colors({
      'background': '#0D0E12',
      'surface': '#16181F',
      'surfaceGlass': '#2416181F',
      'border': '#282B37',
      'primary': '#6C5CE7',
      'textPrimary': '#FFFFFF',
      'textSecondary': '#8E92A4',
    });

    expect(colors.surface, const Color(0xFF16181F));
    expect(colors.border, const Color(0xFF282B37));
  });

  test('onAccent picks dark ink for light accents, white for dark ones', () {
    final beige = _colors({'accent': '#E8DCC8'});
    expect(beige.onAccent, const Color(0xFF141419));

    final teal = _colors({'accent': '#00CEC9'});
    // 0x00CEC9 luminance is mid; the guarantee is contrast, not a fixed hue.
    final onTeal = teal.onAccent;
    expect(
      onTeal.computeLuminance() < 0.2 || onTeal.computeLuminance() > 0.8,
      isTrue,
    );
  });
}
