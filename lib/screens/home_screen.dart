// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../data/monkey_data.dart';
import 'detail_screen.dart';
import '../widgets/app_drawer.dart';
import '../landingpage.dart';

class HomeScreen extends StatelessWidget {
  final String heroTagPrefix;
  
  const HomeScreen({super.key, this.heroTagPrefix = 'home'});

  // Theme Colors
  final Color primaryGreen = const Color(0xFF22C55E); // Emerald
  final Color primaryAmber = const Color(0xFFF59E0B); // Amber
  final Color primaryOrange = const Color(0xFFEA580C); // Warm Orange
  final Color bgDark = const Color(0xFF09160E); // Deep Forest Obsidian
  final Color bgCard = const Color(0xFF112619); // Forest Glass Card

  Color _getStageColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF22C55E); // Green (Unripe)
      case 1:
        return const Color(0xFFF59E0B); // Amber (Ripening)
      case 2:
        return const Color(0xFFEA580C); // Warm Orange (Ripe)
      case 3:
        return const Color(0xFFEF4444); // Crimson (Overripe)
      default:
        return const Color(0xFF22C55E);
    }
  }

  String _getStageBadge(int index) {
    switch (index) {
      case 0:
        return "STAGE 1 • UNRIPE";
      case 1:
        return "STAGE 2 • RIPENING";
      case 2:
        return "STAGE 3 • RIPE";
      case 3:
        return "STAGE 4 • OVERRIPE";
      default:
        return "STAGE";
    }
  }

  String _getHarvestAdvice(int index) {
    switch (index) {
      case 0:
        return "0% - 15% Yellowing • Ideal for Cooking & Pickling";
      case 1:
        return "16% - 75% Yellowing • Breaker Stage (Transport)";
      case 2:
        return "76% - 100% Yellowing • Ready-to-Eat Fresh";
      case 3:
        return "Dark Freckles & Soft Flesh • Best for Purees & Baking";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Papaya Maturity",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
                fontSize: 17,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF07140B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Direct Action to Landing Page
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Tooltip(
              message: "Go to Landing Page",
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MonkeyIdScreen()),
                  );
                },
                icon: const Icon(Icons.public, color: Color(0xFF4ADE80), size: 16),
                label: const Text(
                  "Landing",
                  style: TextStyle(
                    color: Color(0xFF4ADE80),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A).withOpacity(0.18),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF4ADE80).withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [
              Color(0xFF0F2B1B), // Subtle emerald glow center
              Color(0xFF07140B), // Deep forest base
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: monkeyData.isEmpty 
            ? const Center(child: Text("No maturity stages found", style: TextStyle(color: Colors.white)))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Header Banner Card
                  SliverToBoxAdapter(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF143823), Color(0xFF0E2719)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "✨ 4 RIPENING PHASES",
                                    style: TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  "Standard Quality Scale",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Papaya Maturity Classification",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tap any maturity stage below to view visual markers, texture, sugar accumulation, and harvesting guidelines.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Interactive Stage Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final monkey = monkeyData[index];
                          final tag = "${heroTagPrefix}_${monkey.name}_$index";
                          final stageColor = _getStageColor(index);
                          final stageBadge = _getStageBadge(index);
                          final advice = _getHarvestAdvice(index);

                          return FadeInUp(
                            delay: Duration(milliseconds: 150 * index),
                            duration: const Duration(milliseconds: 650),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(monkey: monkey, heroTag: tag),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bgCard,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: stageColor.withOpacity(0.3),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: stageColor.withOpacity(0.12),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 6),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Top Image Showcase with Stage Spotlight Glow
                                      Expanded(
                                        flex: 3,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Radial Spotlight behind fruit
                                            Center(
                                              child: Container(
                                                width: 110,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      stageColor.withOpacity(0.25),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Isolated Floating Fruit Image
                                            Center(
                                              child: Hero(
                                                tag: tag,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Image.asset(
                                                    monkey.imagePath,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (_, __, ___) => const Icon(
                                                      Icons.eco,
                                                      size: 48,
                                                      color: Colors.white24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Top Stage Pill
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: stageColor.withOpacity(0.22),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: stageColor.withOpacity(0.4),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  stageBadge,
                                                  style: TextStyle(
                                                    color: stageColor,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Bottom Info Details
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.25),
                                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(21)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    monkey.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 15,
                                                      letterSpacing: 0.2,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    advice,
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.55),
                                                      fontSize: 10,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),

                                              // Explore Stage Link
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "Inspect Stage",
                                                    style: TextStyle(
                                                      color: stageColor,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: stageColor.withOpacity(0.18),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: stageColor.withOpacity(0.35),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      color: stageColor,
                                                      size: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: monkeyData.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
      ),
    );
  }
}
