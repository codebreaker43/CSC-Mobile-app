import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../data/user_profile_data.dart';
import 'package:animate_do/animate_do.dart';
import 'settings_screen.dart';
import '../landingpage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileData _userProfile = UserProfileData();
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classifications");

  // Editing controllers
  bool _isEditing = false;
  late TextEditingController _nameController;
  
  // Stats
  int _totalScans = 0;
  int _uniqueSpecies = 0;
  bool _loadingStats = true;

  // Theme Colors
  final Color primaryColor = const Color(0xFF4ADE80);
  final Color cyanColor = const Color(0xFF22D3EE);
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userProfile.name);
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int scans = data.length;
        Set<String> speciesSet = {};

        data.forEach((key, value) {
          if (value is Map && value['label'] != null) {
            String label = value['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
            speciesSet.add(label);
          }
        });

        if (mounted) {
          setState(() {
            _totalScans = scans;
            _uniqueSpecies = speciesSet.length;
            _loadingStats = false;
          });
        }
      } else {
         if (mounted) setState(() => _loadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _userProfile.updateProfile(newImagePath: image.path);
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Save changes - Name Only
        _userProfile.updateProfile(
          newName: _nameController.text,
          // Not updating email at all as requested
        );
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          )
        ],
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
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF0F2B1B), // Emerald ambient glow
              Color(0xFF07140B), // Deep forest base
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Profile Picture Showcase
              FadeInDown(
                child: Center(
                  child: GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF4ADE80),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF112619),
                            backgroundImage: _userProfile.imagePath != null
                                ? (kIsWeb
                                    ? NetworkImage(_userProfile.imagePath!) as ImageProvider
                                    : FileImage(File(_userProfile.imagePath!)))
                                : null,
                            child: _userProfile.imagePath == null
                                ? const Icon(Icons.person, size: 64, color: Color(0xFF4ADE80))
                                : null,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 18),
              
              // Name Display / Field
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "Enter Name",
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ADE80))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ADE80), width: 2)),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          _userProfile.name,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Certified Field Assessor",
                            style: TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
              ),

              const SizedBox(height: 28),

              // Stats Section
              FadeInUp(
                 delay: const Duration(milliseconds: 250),
                 child: Container(
                   padding: const EdgeInsets.all(18),
                   decoration: BoxDecoration(
                     color: const Color(0xFF112619),
                     borderRadius: BorderRadius.circular(22),
                     border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.35),
                         blurRadius: 16,
                         offset: const Offset(0, 4),
                       ),
                     ],
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       _buildStatItem("Total Scans", _loadingStats ? "..." : "$_totalScans", const Color(0xFF4ADE80)),
                       Container(width: 1, height: 36, color: Colors.white12),
                       _buildStatItem("Stages", _loadingStats ? "..." : "$_uniqueSpecies", const Color(0xFFF59E0B)),
                       Container(width: 1, height: 36, color: Colors.white12),
                       _buildStatItem("Model Engine", "Edge TFLite", const Color(0xFF38BDF8)),
                     ],
                   ),
                 ),
              ),
              
              const SizedBox(height: 24),

              // Quick Landing Page Action Card
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MonkeyIdScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF143823), Color(0xFF0F2B1B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF16A34A).withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.public, color: Color(0xFF4ADE80), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Papaya Landing Page",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "View market overview, stages guide & harvest info",
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Color(0xFF4ADE80), size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Action Button - Edit Profile
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: ElevatedButton.icon(
                  onPressed: _toggleEdit,
                  icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
                  label: Text(
                    _isEditing ? "SAVE CHANGES" : "EDIT PROFILE", 
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? const Color(0xFF22C55E) : const Color(0xFF16A34A).withOpacity(0.2),
                    foregroundColor: _isEditing ? Colors.black : const Color(0xFF4ADE80),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF22C55E), width: 1.2),
                    ),
                    elevation: _isEditing ? 4 : 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color accent) {
    return Column(
      children: [
        Text(
          value, 
          style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(), 
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
