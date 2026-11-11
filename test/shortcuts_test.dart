import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/ui/hook_shortcuts.dart';

void main() {
  late int fired;
  late TextEditingController controller;

  setUp(() {
    fired = 0;
    controller = TextEditingController();
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.space):
                HookShortcuts.whenNotTyping(() => fired++),
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                HookShortcuts.whenNotTyping(() => fired++),
            const SingleActivator(LogicalKeyboardKey.keyM):
                HookShortcuts.whenNotTyping(() => fired++),
          },
          child: Focus(autofocus: true, child: child!),
        ),
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                key: const ValueKey('field'),
                controller: controller,
              ),
              TextButton(
                key: const ValueKey('button'),
                onPressed: () {},
                child: const Text('ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('shortcuts stand down while a text field has focus', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('field')));
    await tester.pump();
    expect(HookShortcuts.isTyping(), isTrue);

    for (final key in [
      LogicalKeyboardKey.keyM,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.arrowLeft,
    ]) {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }
    expect(fired, 0);
    // The letters must reach the field instead of being swallowed.
    await tester.enterText(find.byKey(const ValueKey('field')), 'm ');
    await tester.pump();
    expect(controller.text, 'm ');
  });

  testWidgets('shortcuts resume once the keyboard leaves the field', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('field')));
    await tester.pump();
    // Tab is how a keyboard user leaves a field; focus lands on the button.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(HookShortcuts.isTyping(), isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(fired, 2);
  });

  testWidgets('shortcuts work on a plain screen with no field at all', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyM):
                HookShortcuts.whenNotTyping(() => fired++),
          },
          child: Focus(autofocus: true, child: child!),
        ),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    expect(fired, 1);
  });
}
