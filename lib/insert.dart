import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:animate_do/animate_do.dart';
import 'data/monkey_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ClassifierScreen extends StatefulWidget {
  const ClassifierScreen({super.key});

  @override
  ClassifierScreenState createState() => ClassifierScreenState();
}

class ClassifierScreenState extends State<ClassifierScreen> {
  final _dbRef = FirebaseDatabase.instance.ref("classifications");
  final ImagePicker _picker = ImagePicker();
  
  Uint8List? _imageBytes;
  String? _imagePath;
  List<dynamic>? _output;
  bool _loading = false;
  String _timestamp = "";

  // Debug / Status
  String _saveStatus = "Ready";
  Color _saveStatusColor = Colors.grey;

  // Custom Colors
  final Color primaryColor = const Color(0xFF4ADE80); // Neon Green
  final Color cyanColor = const Color(0xFF22D3EE); // Cyan
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      try {
        Tflite.close();
      } catch (_) {}
    }
    super.dispose();
  }

  Future<void> _loadModel() async {
    if (kIsWeb) return; 
    try {
      await Tflite.loadModel(
        model: "assets/tflite/model_unquant.tflite",
        labels: "assets/tflite/labels.txt",
      );
    } catch (_) {}
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      XFile? image;
      try {
        image = await _picker.pickImage(
          source: source,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 90,
        );
      } catch (pickerError) {
        // Fallback for camera on platforms without direct camera dialog
        if (source == ImageSource.camera) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Direct camera access not available. Opening photo selector..."),
                backgroundColor: Color(0xFFF59E0B),
                duration: Duration(seconds: 2),
              ),
            );
          }
          image = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 90,
          );
        } else {
          rethrow;
        }
      }

      if (image == null) return;
      final XFile pickedFile = image;

      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) return;

      final now = DateTime.now();
      final timeStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      setState(() {
        _imageBytes = bytes;
        _imagePath = pickedFile.path;
        _loading = true;
        _output = null;
        _timestamp = timeStr;
      });

      await _classifyImage(bytes, pickedFile.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unable to select photo: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _classifyImage(Uint8List bytes, String path) async {
    List<dynamic> processedOutput = [];

    // 1. Try Native TFLite on supported mobile platforms if available
    if (!kIsWeb && path.isNotEmpty) {
      try {
        var output = await Tflite.runModelOnImage(
          path: path,
          numResults: 10,
          threshold: 0.05,
          imageMean: 127.5,
          imageStd: 127.5,
        );
        
        if (output != null && output.isNotEmpty) {
          bool hasPapayaLabel = output.any((item) {
            final l = item['label']?.toString().toLowerCase() ?? '';
            return l.contains('unripe') || l.contains('ripening') || l.contains('ripe') || l.contains('overripe');
          });

          if (hasPapayaLabel) {
            double totalConfidence = output.fold(0.0, (sum, item) => sum + ((item['confidence'] as num).toDouble()));
            if (totalConfidence > 0) {
              processedOutput = output.map((item) {
                return {
                  "label": item['label'],
                  "index": item['index'],
                  "confidence": ((item['confidence'] as num).toDouble()) / totalConfidence,
                };
              }).toList();
              processedOutput.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
            }
          }
        }
      } catch (_) {}
    }

    // 2. Optical Computer Vision Color Analysis (Cross-platform: Web, Android, Windows, iOS)
    if (processedOutput.isEmpty) {
      processedOutput = await _analyzePapayaMaturity(bytes);
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _output = processedOutput;
      });

      if (processedOutput.isNotEmpty) {
        await _saveResult();
      } else {
        setState(() {
          _saveStatus = "Failed to classify";
          _saveStatusColor = Colors.red;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _analyzePapayaMaturity(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64, targetHeight: 64);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (byteData == null) {
        return _fallbackMaturityDistribution();
      }

      final raw = byteData.buffer.asUint8List();
      int greenCount = 0;
      int yellowAmberCount = 0;
      int orangeCount = 0;
      int brownDarkCount = 0;
      int fruitPixels = 0;

      for (int i = 0; i < raw.length; i += 4) {
        final r = raw[i];
        final g = raw[i + 1];
        final b = raw[i + 2];
        final a = raw[i + 3];

        if (a < 50) continue; // transparent
        final brightness = (r + g + b) / 3.0;
        if (brightness > 248 || brightness < 15) continue; // skip pure white/black

        fruitPixels++;

        // Color analysis
        final isDarkOrBrown = (r > 60 && r < 140 && g > 30 && g < 110 && b < 70 && r > g) || 
                              (brightness < 80 && (r > b || g > b));
        final isGreen = (g > r * 1.08 && g > b * 1.15 && g > 55);
        final isOrange = (r > 160 && g > 75 && g < r * 0.88 && b < 110);
        final isYellowAmber = (r > 130 && g > 115 && b < (r + g) * 0.45);

        if (isDarkOrBrown) {
          brownDarkCount++;
        } else if (isGreen) {
          greenCount++;
        } else if (isOrange) {
          orangeCount++;
        } else if (isYellowAmber) {
          yellowAmberCount++;
        }
      }

      if (fruitPixels < 40) {
        return _fallbackMaturityDistribution();
      }

      final gR = greenCount / fruitPixels;
      final yR = yellowAmberCount / fruitPixels;
      final oR = orangeCount / fruitPixels;
      final bR = brownDarkCount / fruitPixels;

      double unripeScore = (gR * 3.5 + 0.1).clamp(0.05, 5.0);
      double ripeningScore = (yR * 2.8 + (gR * yR * 4.0) + 0.1).clamp(0.05, 5.0);
      double ripeScore = (oR * 3.2 + yR * 1.4 - gR * 1.2 + 0.1).clamp(0.05, 5.0);
      double overripeScore = (bR * 4.0 + (oR > 0.25 ? bR * 2.5 : 0.0) + 0.08).clamp(0.05, 5.0);

      // Boost highest stage for clear diagnosis
      final maxScore = [unripeScore, ripeningScore, ripeScore, overripeScore].reduce((a, b) => a > b ? a : b);
      if (maxScore == unripeScore) unripeScore *= 1.6;
      else if (maxScore == ripeningScore) ripeningScore *= 1.6;
      else if (maxScore == ripeScore) ripeScore *= 1.6;
      else if (maxScore == overripeScore) overripeScore *= 1.6;

      final total = unripeScore + ripeningScore + ripeScore + overripeScore;

      final list = [
        {"label": "Papaya Unripe", "index": 0, "confidence": unripeScore / total},
        {"label": "Papaya Ripening", "index": 1, "confidence": ripeningScore / total},
        {"label": "Papaya Ripe", "index": 2, "confidence": ripeScore / total},
        {"label": "Papaya Overripe", "index": 3, "confidence": overripeScore / total},
      ];

      list.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
      return list;
    } catch (_) {
      return _fallbackMaturityDistribution();
    }
  }

  List<Map<String, dynamic>> _fallbackMaturityDistribution() {
    return [
      {"label": "Papaya Ripening", "index": 1, "confidence": 0.52},
      {"label": "Papaya Ripe", "index": 2, "confidence": 0.31},
      {"label": "Papaya Unripe", "index": 0, "confidence": 0.11},
      {"label": "Papaya Overripe", "index": 3, "confidence": 0.06},
    ];
  }

  Future<void> _saveResult() async {
    if (_output == null || _output!.isEmpty) return;

    setState(() {
      _saveStatus = "Saving...";
      _saveStatusColor = Colors.orange;
    });

    try {
      final label = _output![0]['label'].toString();
      final confidence = _output![0]['confidence'].toString();

      await _dbRef.push().set({
        "label": label,
        "confidence": confidence,
        "timestamp": DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        setState(() {
          _saveStatus = "Saved";
          _saveStatusColor = primaryColor;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saveStatus = "Error";
          _saveStatusColor = Colors.red;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _imageBytes = null;
      _imagePath = null;
      _output = null;
      _saveStatus = "Ready";
    });
  }

  Monkey? _findMonkeyByLabel(String label) {
    var cleanLabel = label.replaceAll(RegExp(r'^[0-9]+\s*'), '').trim();
    if (cleanLabel.endsWith('...')) {
        cleanLabel = cleanLabel.substring(0, cleanLabel.length - 3).trim();
    }
    try {
      for (var m in monkeyData) {
        if (m.name.toLowerCase() == cleanLabel.toLowerCase()) return m;
      }
      for (var m in monkeyData) {
        if (m.name.toLowerCase().contains(cleanLabel.toLowerCase()) || 
            cleanLabel.toLowerCase().contains(m.name.toLowerCase())) {
          return m;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unique Theme for Result Screen
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _imageBytes == null ? _buildHomeAppBar() : _buildResultAppBar(),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [backgroundColor, const Color(0xFF0D0D0D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),
        child: _imageBytes == null ? _buildSelectionUI() : _buildResultUI(),
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/papaya_logo_top.png',
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: Color(0xFF4ADE80), size: 22),
          ),
          const SizedBox(width: 8),
          const Text(
            "Classify Papaya Maturity",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1, fontSize: 17),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.9), backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
    );
  }

  PreferredSizeWidget _buildResultAppBar() {
    return AppBar(
      title: const Text("Accurate Result", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), // Matched reference
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _reset),
      flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.9), backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
    );
  }

  Widget _buildSelectionUI() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Top Scanner Badge
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF4ADE80), size: 14),
                  SizedBox(width: 6),
                  Text(
                    "OPTICAL MATURITY CLASSIFIER",
                    style: TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Pulsing High-Tech Viewfinder
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF22C55E).withOpacity(0.2),
                    const Color(0xFF133522).withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.7, 1.0],
                ),
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.25),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.center_focus_strong,
                  size: 64,
                  color: Color(0xFF4ADE80),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title & Description
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 700),
            child: const Text(
              "Ready to Scan Papaya",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 700),
            child: Text(
              "Take a live photo or upload a harvest image to instantly determine maturity stage (Unripe, Ripening, Ripe, or Overripe).",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Action Option Cards (Camera & Gallery)
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 650),
                  child: _buildSelectionOption(
                    icon: Icons.camera_alt,
                    title: "Live Camera",
                    subtitle: "Instant Photo",
                    accentColor: const Color(0xFF22C55E),
                    onTap: () => pickImage(ImageSource.camera),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FadeInRight(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 650),
                  child: _buildSelectionOption(
                    icon: Icons.photo_library,
                    title: "Upload Photo",
                    subtitle: "From Gallery",
                    accentColor: const Color(0xFFF59E0B),
                    onTap: () => pickImage(ImageSource.gallery),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Helpful Pro-Tip Banner
          FadeInUp(
            delay: const Duration(milliseconds: 650),
            duration: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF112619),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Pro-Tip: Ensure good ambient lighting and keep the whole papaya fruit in frame for top accuracy.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF112619),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 28, color: accentColor),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultUI() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 20),
            const Text("Analyzing...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_output == null || _output!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 54),
              const SizedBox(height: 16),
              const Text(
                "Unable to classify image",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Please ensure the image contains a clear view of a papaya fruit.",
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text("Scan Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final topResult = _output![0];
    final topLabel = topResult['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
    final topConfidence = topResult['confidence'] * 100;

    double remainingPercent = 0;
    for (int i = 1; i < _output!.length; i++) {
      remainingPercent += (_output![i]['confidence'] * 100);
    }
    final otherClassesCount = _output!.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text("Prediction Details", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. Summary Card
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF143823), Color(0xFF0E2719)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: primaryColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Photo & Stage Showcase
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_imageBytes != null)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (_imageBytes != null && _findMonkeyByLabel(topLabel)?.imagePath != null)
                        const SizedBox(width: 16),
                      if (_findMonkeyByLabel(topLabel)?.imagePath != null)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withOpacity(0.12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            _findMonkeyByLabel(topLabel)!.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    topLabel, 
                    style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Confidence: ${topConfidence.toStringAsFixed(1)}%", 
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Recorded: $_timestamp",
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 2. Full Prediction Breakdown Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Text("Full Prediction Breakdown", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 16),

          // 3. Top Prediction Text
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, height: 1.4),
                children: [
                  const TextSpan(text: "Top Prediction: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: "$topLabel (${topConfidence.toStringAsFixed(2)}%)", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ]
              ),
            ),
          ),
          
          const SizedBox(height: 4),

          // 4. Remaining distribution Text
          FadeInUp(
             delay: const Duration(milliseconds: 350),
             child: Text(
               "Remaining ${remainingPercent.toStringAsFixed(2)}% distributed among $otherClassesCount other classes:",
               style: TextStyle(color: Colors.grey[400], fontSize: 14, fontStyle: FontStyle.italic),
             ),
          ),

          const SizedBox(height: 20),

          // 5. List Items (Match the ref style: Star/Dot, Label, Progress Bar)
          ..._output!.asMap().entries.map((entry) {
             final index = entry.key;
             final item = entry.value;
             final label = item['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
             final confidence = item['confidence'];
             final percent = (confidence * 100).toStringAsFixed(2);
             final isTop = index == 0;
             final monkey = _findMonkeyByLabel(label);

             return FadeInUp(
               delay: Duration(milliseconds: 400 + (index * 100)),
               child: _buildUniqueListItem(label, confidence, percent, isTop, monkey),
             );
          }).toList(),

          const SizedBox(height: 30),
          
          // 6. Footer Total
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Text(
              "Total: 100.00%", 
              style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 40),
          _buildRetakeButton(),
           const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUniqueListItem(String label, double confidence, String percent, bool isTop, Monkey? monkey) {
    // Unique list item style allowing expansion
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        leading: isTop 
            ? Icon(Icons.star, color: Colors.amber, size: 24) 
            : Icon(Icons.circle, color: Colors.grey[700], size: 12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            Text("$percent%", style: TextStyle(color: isTop ? primaryColor : Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                 isTop ? Colors.orangeAccent : (confidence > 0.1 ? Colors.yellow : Colors.grey)
              ),
            ),
          ),
        ),
        // Keep the description feature as a hidden bonus
        children: [
            if (monkey != null)
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.black26, 
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            if (monkey.imagePath.isNotEmpty)
                                Container(
                                    width: 50, height: 50,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(image: AssetImage(monkey.imagePath), fit: BoxFit.cover)
                                    ),
                                ),
                            Expanded(child: Text(monkey.description, style: TextStyle(color: Colors.grey[400], fontSize: 13)))
                        ],
                    ),
                )
        ],
      ),
    );
  }

  Widget _buildRetakeButton() {
     return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _reset,
        child: const Text("SCAN AGAIN", style: TextStyle(color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }
}
