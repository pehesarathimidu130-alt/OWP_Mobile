import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFE94B73);
const _kDark = Color(0xFF1F1F2E);
const _kGrey = Color(0xFF9A9AAF);
// ─────────────────────────────────────────────────────────────────────────────

/// Kreva-style Welcome / Onboarding screen.
/// Replaces the old SplashScreen. No asset dependencies.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const MainNavigation(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Logo wordmark ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _kAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'OLEENA',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _kDark,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Illustration blob ──────────────────────────────────
            Expanded(
              flex: 5,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: _IllustrationBlob(size: size),
                ),
              ),
            ),

            // ── Text + CTA (slides up) ─────────────────────────────
            Expanded(
              flex: 4,
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        // Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: _kDark,
                              height: 1.25,
                            ),
                            children: const [
                              TextSpan(text: 'Plan Your '),
                              TextSpan(
                                text: 'Wedding',
                                style: TextStyle(color: _kAccent),
                              ),
                              TextSpan(text: '\nEvents Easily'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          'Discover trusted vendors, manage your budget, and orchestrate your perfect day in Sri Lanka — all in one place.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _kGrey,
                            height: 1.65,
                          ),
                        ),

                        const Spacer(),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _goToMain,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kAccent,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shadowColor: _kAccent.withOpacity(0.40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Explore Vendors',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Page dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Dot(active: false),
                            const SizedBox(width: 6),
                            _Dot(active: true),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Illustration Blob ────────────────────────────────────────────────────────

class _IllustrationBlob extends StatelessWidget {
  final Size size;
  const _IllustrationBlob({required this.size});

  // Reliable Unsplash wedding couple shot
  static const _imageUrl =
      'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=600&q=80';

  @override
  Widget build(BuildContext context) {
    final blobSize = size.width * 0.72;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pink soft blob background
        Container(
          width: blobSize,
          height: blobSize,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8EE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(blobSize * 0.5),
              topRight: Radius.circular(blobSize * 0.5),
              bottomLeft: Radius.circular(blobSize * 0.42),
              bottomRight: Radius.circular(blobSize * 0.42),
            ),
          ),
        ),

        // Couple image inside clipped oval
        ClipOval(
          child: SizedBox(
            width: blobSize * 0.80,
            height: blobSize * 0.80,
            child: Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFFDE8EE),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _kAccent,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFFDE8EE),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: _kAccent, size: 56),
                    const SizedBox(height: 10),
                    Text(
                      'Oleena',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Decorative floating hearts
        Positioned(
          top: blobSize * 0.08,
          left: blobSize * 0.18,
          child: const _FloatHeart(size: 18, opacity: 0.55),
        ),
        Positioned(
          top: blobSize * 0.04,
          right: blobSize * 0.20,
          child: const _FloatHeart(size: 14, opacity: 0.40),
        ),
        Positioned(
          top: blobSize * 0.13,
          right: blobSize * 0.10,
          child: const _FloatHeart(size: 10, opacity: 0.30),
        ),
      ],
    );
  }
}

// ─── Small floating heart ornament ───────────────────────────────────────────

class _FloatHeart extends StatelessWidget {
  final double size;
  final double opacity;
  const _FloatHeart({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(Icons.favorite_rounded, color: _kAccent, size: size),
    );
  }
}

// ─── Page dot indicator ───────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? _kAccent : const Color(0xFFE0E0E8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
