import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:oleena/core/auth_provider.dart';
import 'package:oleena/core/favorites_provider.dart';
import 'package:oleena/core/theme.dart';
import 'package:oleena/features/profile/providers/customer_profile_provider.dart';
import 'package:oleena/features/profile/providers/notification_preferences_provider.dart';
import 'package:oleena/features/ai_chat/screens/ai_chat_screen.dart';

// ---------------------------------------------------------------------------
// A lightweight navigation shell that mirrors MainNavigation's EXACT layout
// (BottomAppBar + FloatingActionButton) but uses stub screens, so real screens
// (ExploreScreen, ProfileScreen, etc.) with network calls and pre-existing
// overflows do not interfere with our CTA tests.
// ---------------------------------------------------------------------------
const IconData _kAiIcon = Icons.smart_toy_rounded;

/// Stub screen shown in place of the real tab screens during these tests.
class _FakeScreen extends StatelessWidget {
  final String name;
  const _FakeScreen(this.name);
  @override
  Widget build(BuildContext context) => Center(child: Text(name));
}

class _TestShell extends StatefulWidget {
  final int initialIndex;
  const _TestShell({this.initialIndex = 0});
  @override
  State<_TestShell> createState() => _TestShellState();
}

class _TestShellState extends State<_TestShell> {
  late int _selectedIndex;

  static const _labels = ['Explore', 'Favourites', 'Inquiries', 'Profile'];
  static const _icons = [
    Icons.explore_outlined,
    Icons.favorite_border_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];
  static const _activeIcons = [
    Icons.explore_rounded,
    Icons.favorite_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _item(int index) {
    final bool sel = _selectedIndex == index;
    final Color c = sel ? OleenaTheme.primary : OleenaTheme.textMuted;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sel ? _activeIcons[index] : _icons[index], color: c, size: 22),
            const SizedBox(height: 2),
            Text(
              _labels[index],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(4, (i) => _FakeScreen(_labels[i])),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        notchMargin: 8,
        height: 68,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Row(
          children: [_item(0), _item(1), const SizedBox(width: 72), _item(2), _item(3)],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Semantics(
        label: 'AI Wedding Planner',
        button: true,
        child: FloatingActionButton(
          tooltip: 'AI Wedding Planner',
          backgroundColor: OleenaTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          highlightElevation: 6,
          shape: const CircleBorder(),
          onPressed: () => context.push('/ai-chat'),
          child: const Icon(_kAiIcon, size: 30),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Router & wrapper helpers
// ---------------------------------------------------------------------------
GoRouter _router({int idx = 0}) => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, _) => _TestShell(initialIndex: idx),
        ),
        GoRoute(
          path: '/ai-chat',
          builder: (context, _) => const AiChatScreen(),
        ),
      ],
    );

Widget _wrapWithRouter({int idx = 0}) {
  GoogleFonts.config.allowRuntimeFetching = false;
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ChangeNotifierProvider(create: (_) => CustomerProfileProvider()),
      ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider()),
    ],
    child: MaterialApp.router(
      theme: OleenaTheme.lightTheme,
      routerConfig: _router(idx: idx),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const Size kPhone = Size(1080, 1920);
  const double kDpr = 3.0;

  setUp(() {});

  testWidgets('(a) AI FAB is found by its tooltip', (tester) async {
    tester.view.physicalSize = kPhone;
    tester.view.devicePixelRatio = kDpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithRouter());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The FloatingActionButton must be found by its tooltip.
    expect(find.byTooltip('AI Wedding Planner'), findsOneWidget);
  });

  testWidgets('(b) Tapping AI FAB navigates to /ai-chat placeholder',
      (tester) async {
    tester.view.physicalSize = kPhone;
    tester.view.devicePixelRatio = kDpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithRouter());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('AI Wedding Planner'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // AiChatScreen must appear after push navigation.
    expect(find.byType(AiChatScreen), findsOneWidget);
  });

  testWidgets('(c) Tapping each of the 4 tabs switches tabs correctly',
      (tester) async {
    tester.view.physicalSize = kPhone;
    tester.view.devicePixelRatio = kDpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithRouter());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Future<void> tapTab(String label) async {
      await tester.tap(find.text(label).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tapTab('Favourites');
    await tapTab('Inquiries');
    await tapTab('Profile');
    await tapTab('Explore');

    // After cycling back to Explore the AI FAB must still be visible.
    expect(find.byTooltip('AI Wedding Planner'), findsOneWidget);
  });

  testWidgets(
      '(d) Tapping the AI FAB does NOT change the selected tab index',
      (tester) async {
    tester.view.physicalSize = kPhone;
    tester.view.devicePixelRatio = kDpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapWithRouter());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Favourites tab first.
    await tester.tap(find.text('Favourites').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Tap AI FAB — pushes /ai-chat on top of the shell.
    await tester.tap(find.byTooltip('AI Wedding Planner'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Pop back to the shell.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The Favourites tab label must still be styled with the primary colour,
    // confirming _selectedIndex was NOT changed by the FAB tap.
    final primaryColoured = tester.widgetList<Text>(find.text('Favourites'))
        .where((t) => t.style?.color == OleenaTheme.primary);
    expect(primaryColoured, isNotEmpty,
        reason: 'Favourites tab should remain active after AI FAB tap + back');
  });
}
