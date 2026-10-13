import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  // Theme Colors
  final Color primaryColor = const Color(0xFF4ADE80);
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  // Help & Support Dialog (Moved from Profile)
  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: primaryColor),
            const SizedBox(width: 10),
            const Text("Help & Support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogItem("Identify Species", "Go to the 'Identify' tab and take a photo or upload from gallery to find out usage."),
            const SizedBox(height: 16),
            _buildDialogItem("View Statistics", "Check the 'Graph' screen to see your usage trends and top identifications."),
            const SizedBox(height: 16),
            _buildDialogItem("Edit Profile", "Go to Profile to change your name or picture."),
            const SizedBox(height: 20),
            Center(child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey[600], fontSize: 12))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: primaryColor)),
          )
        ],
      ),
    );
  }

  Widget _buildDialogItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [backgroundColor, const Color(0xFF0D0D0D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle("General"),
            const SizedBox(height: 10),
            _buildSwitchTile("Dark Mode", "Use dark theme for app", _isDarkMode, (val) {
               setState(() => _isDarkMode = val);
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Theme update requires restart")));
            }),
            const SizedBox(height: 10),
            _buildSwitchTile("Notifications", "Receive updates", _notificationsEnabled, (val) {
               setState(() => _notificationsEnabled = val);
            }),
            
            const SizedBox(height: 30),
            _buildSectionTitle("Support"),
            const SizedBox(height: 10),
            _buildActionTile(Icons.help_outline, "Help & Support", _showHelpSupport),
            const SizedBox(height: 10),
            _buildActionTile(Icons.info_outline, "About App", () {
               showAboutDialog(
                context: context,
                applicationName: "Papaya Maturity Classification",
                applicationVersion: "1.0.0",
                applicationIcon: Icon(Icons.eco, size: 50, color: primaryColor),
                children: [
                  const Text("An intelligent system for classifying papaya maturity.", style: TextStyle(fontSize: 14)),
                ]
              );
            }),
            
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(title.toUpperCase(), style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
