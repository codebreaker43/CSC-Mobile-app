import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/monkey_data.dart';

class DetailScreen extends StatelessWidget {
  final Monkey monkey;
  final String? heroTag;

  const DetailScreen({super.key, required this.monkey, this.heroTag});

  final Color primaryColor = const Color(0xFF4ADE80); // Neon Green
  final Color backgroundColor = const Color(0xFF121212); // Dark Background
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Image with Gradient Overlay and AppBar integration
            Stack(
              children: [
                Hero(
                  tag: heroTag ?? monkey.name,
                  child: Container(
                    height: 380,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 40, bottom: 60, left: 20, right: 20),
                    alignment: Alignment.center,
                    child: Image.asset(
                      monkey.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Gradient Overlay for Text Readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          backgroundColor.withOpacity(0.8),
                          backgroundColor,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Custom Back Button
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26, 
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                // Title Section (Overlaid on image bottom)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monkey.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        monkey.scientificName,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.public, color: Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              monkey.place.toUpperCase(), 
                              style: const TextStyle(
                                color: Colors.white70, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. Content Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Stats Row
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.texture, "TEXTURE", monkey.habitat)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.restaurant, "USAGE", monkey.diet)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.timelapse, "MATURITY", monkey.lifespan.replaceAll("years", "Yrs"))),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Key Characteristics
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryColor, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        "Key Characteristics",
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    monkey.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Distribution Map Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text(
                        "Cultivation Regions",
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        width: double.infinity,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                          color: cardColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(monkey.latitude, monkey.longitude),
                              initialZoom: 4.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all & ~InteractiveFlag.rotate, 
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.test',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(monkey.latitude, monkey.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF4ADE80), // Primary Color
                                      size: 40,
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
