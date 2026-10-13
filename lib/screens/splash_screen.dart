// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../landingpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _runController;
  late Animation<double> _runBobAnimation;
  late Animation<double> _runTiltAnimation;
  int _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize Progress Controller for 3.5 seconds duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    )..addListener(() {
        setState(() {
          _loadingPercentage = (_animation.value * 100).toInt();
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Navigate to Landing Page after animation completes
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MonkeyIdScreen()),
          );
        }
      });

    // Running gait animation controller (bobs up and down and tilts like running)
    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..repeat(reverse: true);

    _runBobAnimation = Tween<double>(begin: -5.0, end: 3.0).animate(
      CurvedAnimation(parent: _runController, curve: Curves.easeInOut),
    );

    _runTiltAnimation = Tween<double>(begin: -0.07, end: 0.08).animate(
      CurvedAnimation(parent: _runController, curve: Curves.easeInOut),
    );

    // Start the progress animation
    _controller.forward();
  }

  @override
  void dispose() {
    _runController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Matching landing page clean canvas
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Organic Ambient Background Gradient matching landing page theme
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  Color(0xFFECFDF5), // Soft emerald mist
                  Color(0xFFFEFCE8), // Warm golden papaya tint
                  Color(0xFFF8FAFC), // Clean slate base
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 2. Center Branding: Badge, Title & Maturity Chips
          Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Prominent Brand Logo Badge at the top
                    FadeInDown(
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        width: 145,
                        height: 145,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withOpacity(0.22),
                              blurRadius: 36,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.16),
                              blurRadius: 22,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/papaya_logo_top.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/papaya_badge.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFDCFCE7),
                                      border: Border.all(
                                        color: const Color(0xFF16A34A),
                                        width: 3,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.eco_rounded,
                                        size: 64,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Title: "Papaya Maturity Classification"
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      duration: const Duration(milliseconds: 700),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(text: "Papaya Maturity\n"),
                            TextSpan(
                              text: "Classification",
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 700),
                      child: const Text(
                        "Intelligent Harvest Assessment & Quality Grading",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Maturity Stage Preview Chips
                    FadeInUp(
                      delay: const Duration(milliseconds: 550),
                      duration: const Duration(milliseconds: 700),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStageChip("UNRIPE", const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                            const SizedBox(width: 8),
                            _buildStageChip("RIPENING", const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                            const SizedBox(width: 8),
                            _buildStageChip("RIPE", const Color(0xFFFFEDD5), const Color(0xFFC2410C)),
                            const SizedBox(width: 8),
                            _buildStageChip("OVERRIPE", const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Progress Bar & Animated Running Papaya Mascot
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      // Loading Status & Percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "INITIALIZING SYSTEM...",
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            "$_loadingPercentage%",
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Progress Bar with Animated Running Papaya Mascot
                      SizedBox(
                        width: 280,
                        height: 68,
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          clipBehavior: Clip.none,
                          children: [
                            // Loading Track
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 4,
                              child: Container(
                                width: 280,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFE5E7EB),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 280 * _animation.value,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF16A34A), // Green (Unripe)
                                            Color(0xFFF59E0B), // Amber (Ripening)
                                            Color(0xFFEA580C), // Orange (Ripe)
                                            Color(0xFFDC2626), // Crimson (Overripe)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Dynamic Running Papaya Mascot
                            Positioned(
                              left: ((280 - 54) * _animation.value).clamp(0.0, 226.0),
                              bottom: 6,
                              child: AnimatedBuilder(
                                animation: _runController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _runBobAnimation.value),
                                    child: Transform.rotate(
                                      angle: _runTiltAnimation.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/papaya_run.png',
                                  width: 54,
                                  height: 58,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/monkey_run.png',
                                    width: 54,
                                    height: 58,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Version / System Tagline
                const Text(
                  "Precision Agricultural System • v1.0",
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
