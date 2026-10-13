import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classifications");
  final ScreenshotController _screenshotController = ScreenshotController();
  
  bool _isLoading = true;
  List<Map<dynamic, dynamic>> _allData = [];
  Map<String, int> _frequencyMap = {};
  List<Map<String, dynamic>> _timeSeriesData = [];
  
  // Theme Colors
  final Color primaryColor = const Color(0xFF4ADE80); // Neon Green (Main Theme)
  final Color chartOrange = const Color(0xFFFF5722); // Orange for Frequency Chart
  final Color chartYellow = const Color(0xFFFFC107); // Yellow accent
  final Color cyanColor = const Color(0xFF22D3EE); // Cyan (formerly secondaryColor)
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<dynamic, dynamic>> parsedData = [];
        final Map<String, int> freqMap = {};
        
        // Helper to parse dates
        DateTime parseDate(String? timestamp) {
          if (timestamp == null) return DateTime.now();
          try {
            return DateTime.parse(timestamp);
          } catch (e) {
            return DateTime.now();
          }
        }

        data.forEach((key, value) {
          if (value is Map) {
            parsedData.add(value);
            
            // Frequency processing
            final label = value['label']?.toString() ?? 'Unknown';
            final cleanLabel = label.replaceAll(RegExp(r'[0-9]'), '').trim();
            freqMap[cleanLabel] = (freqMap[cleanLabel] ?? 0) + 1;
          }
        });

        // Sort by timestamp descending
        parsedData.sort((a, b) {
          final dateA = parseDate(a['timestamp']);
          final dateB = parseDate(b['timestamp']);
          return dateB.compareTo(dateA);
        });

        // Time Series Processing (Last 7 days)
        final Map<String, int> timeMap = {};
        final now = DateTime.now();
        for (int i = 6; i >= 0; i--) {
          final d = now.subtract(Duration(days: i));
          final dateStr = DateFormat('MM-dd').format(d);
          timeMap[dateStr] = 0; 
        }

        for (var item in parsedData) {
          final date = parseDate(item['timestamp']);
          if (date.isAfter(now.subtract(const Duration(days: 7)))) {
             final dateStr = DateFormat('MM-dd').format(date);
             if (timeMap.containsKey(dateStr)) {
               timeMap[dateStr] = (timeMap[dateStr] ?? 0) + 1;
             }
          }
        }
        
        final List<Map<String, dynamic>> timeSeriesList = [];
        timeMap.forEach((key, value) {
          timeSeriesList.add({'date': key, 'count': value});
        });

        setState(() {
          _allData = parsedData;
          _frequencyMap = freqMap;
          _timeSeriesData = timeSeriesList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareReport() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/report_graph.png').create();
        await imagePath.writeAsBytes(image);
        await Share.shareXFiles([XFile(imagePath.path)], text: 'Check out my Papaya Maturity classification stats!');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to share report')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Analytics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        backgroundColor: Colors.transparent, // Transparent for gradient body
        elevation: 0,
        centerTitle: true,
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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Color(0xFF4ADE80), size: 20),
            ),
            onPressed: _shareReport,
            tooltip: "Export & Share",
          )
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _allData.isEmpty
              ? const Center(child: Text("No data available yet.", style: TextStyle(color: Colors.white)))
              : Screenshot(
                  controller: _screenshotController,
                  child: Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [backgroundColor, const Color(0xFF0D0D0D)],
                       )
                     ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummarySection(),
                          const SizedBox(height: 24),
                          
                          // Frequency Area Chart Section
                          _buildSectionTitle("Prediction Frequency"),
                          const Text(
                            "Shows how often each species class was predicted",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          _buildFrequencyAreaChart(),
                          
                          const SizedBox(height: 16),
                          _buildClassFrequenciesList(), // New List added here

                          const SizedBox(height: 24),
                          _buildSectionTitle("Activity Trends"),
                          const SizedBox(height: 12),
                          _buildTimeChart(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("History Breakdown"),
                          const SizedBox(height: 12),
                          _buildDataBreakdown(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title, // Removed uppercase for a softer look matching the reference
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    int totalScans = _allData.length;
    String topSpecies = "N/A";
    
    if (_frequencyMap.isNotEmpty) {
      final sortedEntries = _frequencyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topSpecies = sortedEntries.first.key;
    }

    return Row(
      children: [
        Expanded(child: _buildSummaryCard("TOTAL SCANS", "$totalScans", Icons.qr_code_scanner, Colors.blueAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard("TOP SPECIES", topSpecies, Icons.star, Colors.orangeAccent, isSmallText: true)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color accentColor, {bool isSmallText = false}) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [cardColor, const Color(0xFF252525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(value, 
                 style: TextStyle(
                   color: Colors.white, 
                   fontSize: isSmallText ? 18 : 32, 
                   fontWeight: FontWeight.bold
                 ),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
               ),
               Text(title.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
             ],
          )
        ],
      ),
    );
  }

  // --- NEW: Area Chart Style for Frequency ---
  Widget _buildFrequencyAreaChart() {
    final List<MapEntry<String, int>> sortedData = _frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // Take top 7 for graph readability
    final displayData = sortedData.take(7).toList();

    return Container(
      height: 320, // Taller for rotated labels
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      decoration: BoxDecoration(
        color: cardColor, // Fixed: removed duplicate color prop
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (displayData.length - 1).toDouble(),
          minY: 0,
          maxY: (displayData.isEmpty ? 10 : displayData.map((e) => e.value).reduce((a,b)=>a>b?a:b).toDouble()) * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white12,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
             getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white12,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60, // Space for rotation
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < displayData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Transform.rotate(
                        angle: -0.8, // Rotate ~45 degrees
                        child: Text(
                          displayData[value.toInt()].key,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1, // You might want dynamic interval based on max
                getTitlesWidget: (value, meta) {
                   if (value % 1 == 0) {
                      return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                   }
                   return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white12),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: displayData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.value.toDouble());
              }).toList(),
              isCurved: false, // Sharp lines as in reference image? Or slightly curved. Image looks sharp-ish.
              gradient: LinearGradient(colors: [primaryColor, cyanColor]),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                   return FlDotCirclePainter(
                     radius: 4,
                     color: Colors.white, 
                     strokeWidth: 2,
                     strokeColor: cyanColor,
                   );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [cyanColor.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassFrequenciesList() {
    final List<MapEntry<String, int>> sortedData = _frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text("Class Frequencies:", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor, // Dark background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: sortedData.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853), // Green badge
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
         border: Border.all(color: Colors.white.withOpacity(0.08)),
         boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
           )
         ]
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (_timeSeriesData.length - 1).toDouble(),
          minY: 0,
          maxY: (_timeSeriesData.isEmpty ? 5 : 
                 _timeSeriesData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b).toDouble() + 1),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white10.withOpacity(0.05),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _timeSeriesData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _timeSeriesData[value.toInt()]['date'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
             leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, 
                getTitlesWidget: (value, meta) {
                  if (value == value.toInt()) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 10,
                        ),
                      );
                  }
                  return const Text("");
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _timeSeriesData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), (e.value['count'] as int).toDouble());
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(colors: [primaryColor, cyanColor]),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                   return FlDotCirclePainter(
                     radius: 4,
                     color: Colors.white,
                     strokeWidth: 2,
                     strokeColor: cyanColor,
                   );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [cyanColor.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent, 
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: const Text(
              "Full History",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "${_allData.length} total identifications",
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            iconColor: cyanColor,
            collapsedIconColor: Colors.grey,
            childrenPadding: EdgeInsets.zero,
            children: [
               Container(
                 color: Colors.black.withOpacity(0.2), // Slightly darker background for list
                 child: ListView.separated(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: _allData.length,
                   separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                   itemBuilder: (context, index) {
                     final item = _allData[index];
                     final label = item['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
                     final conf = ((double.tryParse(item['confidence'].toString()) ?? 0) * 100).toStringAsFixed(1);
                     final timestamp = item['timestamp']?.toString() ?? "";
                     
                     String prettyTime = timestamp;
                     try {
                       final dt = DateTime.parse(timestamp);
                       prettyTime = DateFormat('MMM d • h:mm a').format(dt);
                     } catch (_) {}
            
                     return ListTile(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                       leading: Container(
                         width: 40, height: 40,
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.05),
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white.withOpacity(0.1)),
                         ),
                         child: Center(
                           child: Text(
                             label.isNotEmpty ? label[0] : "?",
                             style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                           ),
                         ),
                       ),
                       title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                       subtitle: Text(prettyTime, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                       trailing: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                         decoration: BoxDecoration(
                           color: primaryColor.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: primaryColor.withOpacity(0.2)),
                         ),
                         child: Text(
                           "$conf%",
                           style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                         ),
                       ),
                     );
                   },
                 ),
               ),
               if (_allData.length > 5)
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.black.withOpacity(0.2),
                   ),
                   child: const Center(
                     child: Text(
                       "End of Records",
                       style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5),
                     ),
                   ),
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
