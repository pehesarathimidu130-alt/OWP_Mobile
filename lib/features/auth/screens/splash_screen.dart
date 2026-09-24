import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/auth_provider.dart';
import '../../../core/theme.dart';

/// Full-screen Splash Screen that verifies onboarding and authentication state
/// before navigating to the appropriate destination.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStateAndNavigate();
    });
  }

  Future<void> _checkStateAndNavigate() async {
    final startTime = DateTime.now();
    bool hasSeenOnboarding = false;

    // 1. Check Onboarding Flag ONLY (never check auth token to block startup)
    try {
      final prefs = await SharedPreferences.getInstance();
      hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      // Silently restore cached session in background so profile data is ready
      context.read<AuthProvider>().checkAuthStatus();
    } catch (_) {
      hasSeenOnboarding = false;
    }

    // 2. Minimum ~1.2s display before navigating for brand presentation
    final elapsed = DateTime.now().difference(startTime);
    const minDelay = Duration(milliseconds: 1200);
    if (elapsed < minDelay) {
      await Future.delayed(minDelay - elapsed);
    }

    if (!mounted) return;

    // 3. Navigate directly to Onboarding or MainNavigation (Home). Never force login.
    if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OleenaTheme.background,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Animated Monogram with soft shadow card container
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: OleenaTheme.primaryTint,
                      borderRadius: OleenaTheme.cardBorderRadius,
                      boxShadow: OleenaTheme.primaryShadow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: OleenaTheme.primary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Eyebrow and Serif Brand Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'PREMIER DISCOVERY',
                      style: OleenaTheme.eyebrow,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OLEENA',
                      style: OleenaTheme.brandTitle.copyWith(
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Wedding Planner',
                      style: OleenaTheme.body.copyWith(
                        letterSpacing: 1.2,
                        color: OleenaTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Small loading indicator with subtle caption
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: OleenaTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sri Lanka\'s Wedding Discovery',
                      style: OleenaTheme.caption.copyWith(
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
