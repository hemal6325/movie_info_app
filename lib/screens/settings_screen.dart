import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // লিংক ওপেন করার জন্য

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationOn = true;
  bool _isAdultContentAllowed = false;

  // ক্যাশ ক্লিয়ার ফাংশন
  void _clearCache() {
    PaintingBinding.instance.imageCache.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cache cleared successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // অ্যাপ ভার্সন বের করা
  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "v${packageInfo.version} (${packageInfo.buildNumber})";
  }

  // 🔥 লিংক ওপেন করার ফাংশন
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          _buildSectionHeader("General"),

          SwitchListTile(
            activeColor: Colors.amber,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Receive updates about new movies",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            value: _isNotificationOn,
            onChanged: (val) {
              setState(() {
                _isNotificationOn = val;
              });
            },
          ),

          SwitchListTile(
            activeColor: Colors.amber,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              "Include Adult Content",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Show 18+ movies in search results",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            value: _isAdultContentAllowed,
            onChanged: (val) {
              setState(() {
                _isAdultContentAllowed = val;
              });
            },
          ),

          const Divider(color: Colors.grey),

          _buildSectionHeader("Storage"),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              "Clear Cache",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Free up space by clearing images",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onTap: _clearCache,
          ),

          const Divider(color: Colors.grey),

          _buildSectionHeader("About"),

          FutureBuilder<String>(
            future: _getAppVersion(),
            builder: (context, snapshot) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: const Text(
                  "App Version",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  snapshot.data ?? "Loading...",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          // 🔥 Terms & Conditions Link Updated
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              "Terms of Service",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              _launchURL(
                "https://doc-hosting.flycricket.io/movie-info-app-terms-of-use/ec8f6706-c845-436c-a531-a8d27f67e030/terms",
              );
            },
          ),

          // 🔥 Privacy Policy Link Updated
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              "Privacy Policy",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              _launchURL(
                "https://doc-hosting.flycricket.io/movie-info-app-privacy-policy/4b0ef4c9-1c67-476d-be56-1aba019d0256/privacy",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.amber.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
