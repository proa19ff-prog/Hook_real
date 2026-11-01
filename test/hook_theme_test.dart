import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';

void main() {
  test('HookColors keeps text readable when theme colors are invalid', () {
    final colors = HookColors.fromJson({
      'background': '#000000',
      'textPrimary': '#000000',
      'textSecondary': 'not-a-color',
    });

    expect(colors.textPrimary, const Color(0xFFFFFFFF));
    expect(colors.textSecondary, const Color(0xFF8E92A4));
  });
}
