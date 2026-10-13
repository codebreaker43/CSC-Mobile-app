// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'screens/main_screen.dart';
import 'screens/detail_screen.dart';
import 'data/monkey_data.dart';

// Standalone execution support
void main() {
  runApp(const MonkeyIdApp());
}

class MonkeyIdApp extends StatelessWidget {
  const MonkeyIdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Papaya Maturity Classification',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MonkeyIdScreen(),
    );
  }
}

class MonkeyIdScreen extends StatefulWidget {
  const MonkeyIdScreen({super.key});

  @override
  State<MonkeyIdScreen> createState() => _MonkeyIdScreenState();
}

class _MonkeyIdScreenState extends State<MonkeyIdScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stagesSectionKey = GlobalKey();

  void _scrollToStages() {
    final context = _stagesSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToClassifier() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _navigateToStageDetail(int stageIndex) {
    if (stageIndex >= 0 && stageIndex < monkeyData.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            monkey: monkeyData[stageIndex],
            heroTag: "landing_stage_$stageIndex",
          ),
        ),
      );
    } else {
      _navigateToClassifier();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TOP NAVIGATION BAR
              _buildNavBar(),

              // 2. HERO SECTION
              _buildHeroSection(),

              // 3. KEY BENEFIT BADGES
              _buildFeatureBadges(),

              // 4. PAPAYA MATURITY STAGES SECTION
              _buildStagesSection(),

              // 5. FOOTER
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Top Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildNavBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 820;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo + Title
              InkWell(
                onTap: () {
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/papaya_logo_top.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/papaya_logo_leaf.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.eco,
                                color: Color(0xFF15803D),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Papaya Maturity",
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            "Classification",
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Links (Visible on Wide Displays)
              if (isDesktop)
                Row(
                  children: [
                    _buildNavPill("Home", isSelected: true, onTap: () {
                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }),
                    _buildNavLink("Maturity Stages", onTap: _scrollToStages),
                    _buildNavLink("Maturity Classifier", onTap: _navigateToClassifier),
                    _buildNavLink("How It Works", onTap: _scrollToStages),
                  ],
                ),

              // Get Started Action Button
              OutlinedButton.icon(
                onPressed: _navigateToClassifier,
                icon: const Icon(Icons.center_focus_weak, size: 16, color: Color(0xFF111827)),
                label: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF111827), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavPill(String title, {required bool isSelected, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isSelected ? const Color(0xFF15803D) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Hero Section
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 860;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48,
            vertical: isMobile ? 32 : 48,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAFCFA),
                Colors.white,
              ],
            ),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroTextContent(),
                    const SizedBox(height: 32),
                    _buildHeroImageContent(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 11, child: _buildHeroTextContent()),
                    const SizedBox(width: 32),
                    Expanded(flex: 12, child: _buildHeroImageContent()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeroTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tagline badge
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: const Text(
            "SMARTER FARMING, BETTER HARVEST",
            style: TextStyle(
              color: Color(0xFF15803D),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Main Title
        FadeInLeft(
          duration: const Duration(milliseconds: 700),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
                height: 1.12,
              ),
              children: [
                TextSpan(text: "Papaya Maturity\n"),
                TextSpan(
                  text: "Classification",
                  style: TextStyle(color: Color(0xFF16A34A)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Description Paragraph
        FadeInLeft(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 700),
          child: const Text(
            "An intelligent and easy-to-use system that classifies papayas based on their maturity stage. Get accurate results to help farmers and sellers ensure the best quality and market value.",
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Action Buttons
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 700),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              // Classify Now Button
              ElevatedButton.icon(
                onPressed: _navigateToClassifier,
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Classify Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  elevation: 2,
                  shadowColor: const Color(0xFF15803D).withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              // Learn More Button
              OutlinedButton.icon(
                onPressed: _scrollToStages,
                icon: const Icon(Icons.info_outline, color: Color(0xFF111827), size: 18),
                label: const Text(
                  "Learn More",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImageContent() {
    return FadeInRight(
      duration: const Duration(milliseconds: 800),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/landing_hero_papayas.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/papaya_bg.png',
                height: 320,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Feature Badges Bar
  // ---------------------------------------------------------------------------
  Widget _buildFeatureBadges() {
    final features = [
      {
        "icon": Icons.track_changes,
        "title": "High Accuracy",
        "desc": "Reliable automated classification",
      },
      {
        "icon": Icons.eco_outlined,
        "title": "Fast & Easy",
        "desc": "Just upload or capture a photo",
      },
      {
        "icon": Icons.verified_user_outlined,
        "title": "Helps Farmers",
        "desc": "Reduce waste and improve market value",
      },
      {
        "icon": Icons.trending_up,
        "title": "Supports Agriculture",
        "desc": "Promotes smart and sustainable farming",
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FDF9),
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isMedium = constraints.maxWidth >= 600;

          if (isWide) {
            return Row(
              children: features.asMap().entries.map((entry) {
                final index = entry.key;
                final f = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFeatureItem(
                          f["icon"] as IconData,
                          f["title"] as String,
                          f["desc"] as String,
                        ),
                      ),
                      if (index < features.length - 1)
                        Container(
                          height: 48,
                          width: 1,
                          color: const Color(0xFFE5E7EB),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          } else if (isMedium) {
            return Wrap(
              runSpacing: 20,
              spacing: 20,
              children: features.map((f) {
                return SizedBox(
                  width: (constraints.maxWidth - 44) / 2,
                  child: _buildFeatureItem(
                    f["icon"] as IconData,
                    f["title"] as String,
                    f["desc"] as String,
                  ),
                );
              }).toList(),
            );
          } else {
            return Column(
              children: features.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFeatureItem(
                    f["icon"] as IconData,
                    f["title"] as String,
                    f["desc"] as String,
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7), // Soft mint green circle
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF86EFAC), width: 1),
          ),
          child: Icon(icon, color: const Color(0xFF16A34A), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Maturity Stages: "Know the Difference"
  // ---------------------------------------------------------------------------
  Widget _buildStagesSection() {
    return Container(
      key: _stagesSectionKey,
      color: const Color(0xFFEFF8F1), // Gentle mint background
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          // Section Subtitle Line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1.5, color: const Color(0xFF16A34A)),
              const SizedBox(width: 12),
              const Text(
                "PAPAYA MATURITY STAGES",
                style: TextStyle(
                  color: Color(0xFF15803D),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 40, height: 1.5, color: const Color(0xFF16A34A)),
            ],
          ),

          const SizedBox(height: 8),

          // Heading
          const Text(
            "Know the Difference",
            style: TextStyle(
              color: Color(0xFF0F3622),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 36),

          // 4 Stage Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStageCard(
                        imagePath: 'assets/images/papaya_unripe.png',
                        badgeText: 'UNRIPE',
                        badgeColor: const Color(0xFF15803D),
                        desc: 'Generally green in color and firm to the touch.',
                        cardBg: const Color(0xFFDCFCE7),
                        cardBorder: const Color(0xFFBBF7D0),
                        stageIndex: 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStageCard(
                        imagePath: 'assets/images/papaya_ripening.png',
                        badgeText: 'RIPENING',
                        badgeColor: const Color(0xFFF59E0B),
                        desc: 'Shows signs of yellowing and color changes.',
                        cardBg: const Color(0xFFFEF3C7),
                        cardBorder: const Color(0xFFFDE68A),
                        stageIndex: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStageCard(
                        imagePath: 'assets/images/papaya_ripe.png',
                        badgeText: 'RIPE',
                        badgeColor: const Color(0xFFEA580C),
                        desc: 'Mostly yellow-orange in color and ready to eat.',
                        cardBg: const Color(0xFFFFEDD5),
                        cardBorder: const Color(0xFFFED7AA),
                        stageIndex: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStageCard(
                        imagePath: 'assets/images/papaya_overripe.png',
                        badgeText: 'OVERRIPE',
                        badgeColor: const Color(0xFFDC2626),
                        desc: 'Amber with dark freckles, soft and sweet for purees.',
                        cardBg: const Color(0xFFFEF2F2),
                        cardBorder: const Color(0xFFFECACA),
                        stageIndex: 3,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStageCard(
                      imagePath: 'assets/images/papaya_unripe.png',
                      badgeText: 'UNRIPE',
                      badgeColor: const Color(0xFF15803D),
                      desc: 'Generally green in color and firm to the touch.',
                      cardBg: const Color(0xFFDCFCE7),
                      cardBorder: const Color(0xFFBBF7D0),
                      stageIndex: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildStageCard(
                      imagePath: 'assets/images/papaya_ripening.png',
                      badgeText: 'RIPENING',
                      badgeColor: const Color(0xFFF59E0B),
                      desc: 'Shows signs of yellowing and color changes.',
                      cardBg: const Color(0xFFFEF3C7),
                      cardBorder: const Color(0xFFFDE68A),
                      stageIndex: 1,
                    ),
                    const SizedBox(height: 16),
                    _buildStageCard(
                      imagePath: 'assets/images/papaya_ripe.png',
                      badgeText: 'RIPE',
                      badgeColor: const Color(0xFFEA580C),
                      desc: 'Mostly yellow-orange in color and ready to eat.',
                      cardBg: const Color(0xFFFFEDD5),
                      cardBorder: const Color(0xFFFED7AA),
                      stageIndex: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildStageCard(
                      imagePath: 'assets/images/papaya_overripe.png',
                      badgeText: 'OVERRIPE',
                      badgeColor: const Color(0xFFDC2626),
                      desc: 'Amber with dark freckles, soft and sweet for purees.',
                      cardBg: const Color(0xFFFEF2F2),
                      cardBorder: const Color(0xFFFECACA),
                      stageIndex: 3,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard({
    required String imagePath,
    required String badgeText,
    required Color badgeColor,
    required String desc,
    required Color cardBg,
    required Color cardBorder,
    required int stageIndex,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToStageDetail(stageIndex),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Fruit illustration
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.eco,
                    size: 60,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Stage Badge + Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Footer
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0F3622), // Deep Forest Green Footer
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;

          if (isMobile) {
            return Column(
              children: [
                _buildFooterBrand(),
                const SizedBox(height: 12),
                const Text(
                  "Better Data. Better Harvests.",
                  style: TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                _buildFooterRight(),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterBrand(),
              const Text(
                "Better Data. Better Harvests.",
                style: TextStyle(
                  color: Color(0xFFD1FAE5),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              _buildFooterRight(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.eco, color: Color(0xFF4ADE80), size: 18),
        const SizedBox(width: 8),
        const Text(
          "Papaya Maturity Classification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterRight() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.public, color: Colors.white70, size: 16),
        SizedBox(width: 14),
        Icon(Icons.ondemand_video, color: Colors.white70, size: 16),
        SizedBox(width: 14),
        Icon(Icons.code, color: Colors.white70, size: 16),
        SizedBox(width: 18),
        Text(
          "v1.0",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
