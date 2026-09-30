import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:oleena/features/ai_chat/providers/chat_provider.dart';
import 'package:oleena/features/ai_chat/widgets/chat_greeting.dart';
import 'package:oleena/features/ai_chat/widgets/typing_indicator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds just the AuthProvider tree (used by greeting tests).
Widget _buildHarness(Widget child) {
  SharedPreferences.setMockInitialValues({});
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

/// Builds the AiChatScreen with a zero-delay [ChatProvider] injected.
/// This ensures widget tests are deterministic without real-time waits.
Widget _buildScreenHarness({Duration aiDelay = Duration.zero}) {
  SharedPreferences.setMockInitialValues({});
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
      ),
    ],
    child: MaterialApp(
      home: AiChatScreen(
        chatProvider: ChatProvider(aiReplyDelay: aiDelay),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -----------------------------------------------------------------------
  // (e) greetingPeriod() — pure function, no widget needed
  // -----------------------------------------------------------------------

  group('greetingPeriod() logic', () {
    test('09:00 → morning', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 9, 0)), equals('morning'));
    });
    test('14:00 → afternoon', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 14, 0)), equals('afternoon'));
    });
    test('20:00 → evening', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 20, 0)), equals('evening'));
    });
    test('00:00 → morning', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 0, 0)), equals('morning'));
    });
    test('11:59 → morning', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 11, 59)), equals('morning'));
    });
    test('12:00 → afternoon', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 12, 0)), equals('afternoon'));
    });
    test('16:59 → afternoon', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 16, 59)), equals('afternoon'));
    });
    test('17:00 → evening', () {
      expect(greetingPeriod(DateTime(2024, 1, 1, 17, 0)), equals('evening'));
    });
  });

  // -----------------------------------------------------------------------
  // (a) Empty state shows greeting + hint text
  // -----------------------------------------------------------------------

  group('AiChatScreen — empty state', () {
    testWidgets('shows one of the possible greetings and hint text',
        (tester) async {
      await tester.pumpWidget(_buildScreenHarness());
      await tester.pumpAndSettle();

      final possiblePrompts = [
        'How can I help plan your wedding today?',
        "Let's plan it together.",
        'What about your wedding?',
        'Ready to design your dream day?',
        "Let's organise your special day.",
      ];

      // It must either start with "Good" (the dynamic time greeting)
      // OR exactly match one of the predefined alternate prompts.
      final headlineFinder = find.byWidgetPredicate((widget) {
        if (widget is Text && widget.data != null) {
          final data = widget.data!;
          return data.startsWith('Good') || possiblePrompts.contains(data);
        }
        return false;
      });

      expect(headlineFinder, findsAtLeastNWidgets(1));

      // Hint text is shown in the input field.
      expect(find.text('Ask anything from our AI'), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  // (b) Send button disabled when field is empty / whitespace
  // -----------------------------------------------------------------------

  group('AiChatScreen — send button state', () {
    testWidgets('send button is disabled when field is empty', (tester) async {
      await tester.pumpWidget(_buildScreenHarness());
      await tester.pumpAndSettle();

      final inkWell =
          tester.widget<InkWell>(find.byKey(const Key('send_button')));
      expect(inkWell.onTap, isNull,
          reason: 'onTap should be null (disabled) when input is empty');
    });

    testWidgets('send button disabled for whitespace-only input',
        (tester) async {
      await tester.pumpWidget(_buildScreenHarness());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('chat_input_field')), '   ');
      await tester.pump();

      final inkWell =
          tester.widget<InkWell>(find.byKey(const Key('send_button')));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('send button enabled when field has text', (tester) async {
      await tester.pumpWidget(_buildScreenHarness());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('chat_input_field')), 'Hello');
      await tester.pump();

      final inkWell =
          tester.widget<InkWell>(find.byKey(const Key('send_button')));
      expect(inkWell.onTap, isNotNull);
    });
  });

  // -----------------------------------------------------------------------
  // (c) Sending a message → user bubble → typing indicator → AI reply
  // -----------------------------------------------------------------------

  group('AiChatScreen — conversation flow', () {
    testWidgets(
        'typing and tapping send adds user bubble and AI reply',
        (tester) async {
      // Zero-delay provider: AI reply comes instantly.
      await tester.pumpWidget(_buildScreenHarness());
      await tester.pumpAndSettle();

      // Enter text.
      await tester.enterText(
          find.byKey(const Key('chat_input_field')), 'Hello AI');
      await tester.pump();

      // Tap send.
      await tester.tap(find.byKey(const Key('send_button')));
      
      // Since delay is 0, pumpAndSettle will advance until the AI reply is added 
      // and the TypingIndicator is removed from the tree.
      await tester.pumpAndSettle();

      // User message bubble visible.
      expect(find.textContaining('Hello AI'), findsOneWidget);

      // Input field cleared.
      final tf = tester.widget<TextField>(
          find.byKey(const Key('chat_input_field')));
      expect(tf.controller!.text, isEmpty);

      // AI placeholder reply visible.
      expect(
        find.textContaining("The AI planner isn't connected yet"),
        findsOneWidget,
      );

      // Typing indicator gone.
      expect(find.byType(TypingIndicator), findsNothing);
    });
  });



  // -----------------------------------------------------------------------
  // ChatProvider unit tests
  // -----------------------------------------------------------------------

  group('ChatProvider', () {
    test('initial state: isEmpty, no messages, not typing', () {
      final p = ChatProvider();
      expect(p.isEmpty, isTrue);
      expect(p.messages, isEmpty);
      expect(p.isAiTyping, isFalse);
    });

    test('ignores blank messages', () async {
      final p = ChatProvider();
      await p.sendMessage('');
      await p.sendMessage('   ');
      expect(p.messages, isEmpty);
    });

    test('sendMessage adds user message immediately and AI reply after delay',
        () async {
      final p = ChatProvider();
      final future = p.sendMessage('Hi');

      expect(p.messages.length, 1);
      expect(p.messages.first.isUser, isTrue);
      expect(p.isAiTyping, isTrue);

      await future;

      expect(p.messages.length, 2);
      expect(p.messages.last.isUser, isFalse);
      expect(p.isAiTyping, isFalse);
    });

    test('clearChat resets to empty state', () async {
      final p = ChatProvider();
      await p.sendMessage('Hello');
      p.clearChat();
      expect(p.isEmpty, isTrue);
      expect(p.messages, isEmpty);
      expect(p.isAiTyping, isFalse);
    });
  });
}
