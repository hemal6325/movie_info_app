import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // ১. সেভ করা ছবি লোড করা
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localImagePath = prefs.getString('profile_image_path');
    });
  }

  // ২. ছবি বাছা এবং সেভ করা
  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', image.path);

    setState(() {
      _localImagePath = image.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text(
                "No User Logged In",
                style: TextStyle(color: Colors.white),
              ),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                // লোডিং অবস্থা
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }

                // ডিফল্ট ডাটা
                String customUserId = "N/A";
                String joinDate = "Unknown";
                String fullName = user.email!.split(
                  '@',
                )[0]; // ইমেইল থেকে নাম বানানো (ব্যাকআপ)
                String location = "Earth";
                String dob = "Not Set";

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  customUserId = data['user_id'] ?? "N/A";

                  if (data['joined_at'] != null) {
                    DateTime dt = DateTime.parse(data['joined_at']);
                    joinDate = DateFormat('dd MMM yyyy').format(dt);
                  }

                  // নাম এবং অন্যান্য তথ্য নেওয়া
                  String fName = data['first_name'] ?? "";
                  String lName = data['last_name'] ?? "";
                  if (fName.isNotEmpty) fullName = "$fName $lName";

                  location = data['location'] ?? "Unknown";
                  dob = data['dob'] ?? "Not Set";
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ১. প্রোফাইল ছবি
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[900],
                            backgroundImage: _localImagePath != null
                                ? FileImage(File(_localImagePath!))
                                : null,
                            child: _localImagePath == null
                                ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndSaveImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // ২. নাম
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),

                      // ৩. কাস্টম আইডি (ব্যাজ আকারে)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Text(
                          "ID: $customUserId",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ৪. লোকেশন
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ৫. ডিটেইলস কার্ড
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildProfileItem(
                              Icons.email,
                              "Email",
                              user.email ?? "",
                            ),
                            const Divider(color: Colors.grey, height: 1),
                            _buildProfileItem(Icons.cake, "Date of Birth", dob),
                            const Divider(color: Colors.grey, height: 1),
                            _buildProfileItem(
                              Icons.calendar_today,
                              "Joined Date",
                              joinDate,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ৬. লগআউট বাটন
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logged Out Successfully"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // হেল্পার উইজেট (কোড ক্লিন রাখার জন্য)
  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
