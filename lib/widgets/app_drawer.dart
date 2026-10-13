import 'package:flutter/material.dart';
import '../screens/graph_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../landingpage.dart';

import '../data/user_profile_data.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom Colors
    final Color primaryColor = const Color(0xFF4ADE80); // Neon Green
    final Color cardColor = const Color(0xFF1E1E1E);
    final Color backgroundColor = const Color(0xFF121212);

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, const Color(0xFF1E1E1E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: ValueListenableBuilder(
              valueListenable: UserProfileData().notifier,
              builder: (context, value, child) {
                final user = UserProfileData();
                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                        boxShadow: [
                           BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 10)
                        ]
                      ),
                      child: CircleAvatar(
                        backgroundColor: cardColor,
                        radius: 30,
                        backgroundImage: user.imagePath != null 
                            ? (kIsWeb 
                                ? NetworkImage(user.imagePath!) as ImageProvider 
                                : FileImage(File(user.imagePath!)))
                            : null,
                        child: user.imagePath == null ? Icon(Icons.person, size: 30, color: Colors.grey[400]) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Email removed as requested
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              children: [
                _buildDrawerItem(
                  context, 
                  icon: Icons.public, 
                  title: 'Landing Page', 
                  onTap: () {
                     Navigator.pop(context);
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MonkeyIdScreen()));
                  }
                ),
                _buildDrawerItem(
                  context, 
                  icon: Icons.bar_chart, 
                  title: 'Graph', 
                  onTap: () {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const GraphScreen()));
                  }
                ),
                _buildDrawerItem(
                  context, 
                  icon: Icons.settings, 
                  title: 'Settings', 
                  onTap: () {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  }
                ),
                _buildDrawerItem(
                  context, 
                  icon: Icons.person, 
                  title: 'Profile', 
                  onTap: () {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                  }
                ),
              ],
            ),
          ),
          
          // Footer Version
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "v1.0.0",
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4ADE80)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
