import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "Version ${packageInfo.version} (Build ${packageInfo.buildNumber})";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("About App"),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // ১. লোগো এবং নাম
            Center(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/app-logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Movie Info App",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  FutureBuilder<String>(
                    future: _getAppVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ২. ডেসক্রিপশন
            const Text(
              "Movie Info App is a modern movie discovery application. Explore trending, popular, and newly released movies all in one place using TMDB API.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 30),

            const SizedBox(height: 25),

            // 🔥 ৩. ভিশন এবং মিশন বক্স
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🚀 Our Vision & Mission",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "To provide movie lovers with a fast, reliable, and beautifully designed platform where anyone can easily explore and discover movies with accurate information. We aim to make entertainment discovery effortless.",
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 ৪. কী ফিচারস লিস্ট
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Key Features",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _buildFeatureItem("🎬 Trending Movies", "Daily & Weekly updates"),
            _buildFeatureItem("🔍 Instant Search", "Find any movie instantly"),
            _buildFeatureItem("📺 Watch Trailers", "Direct YouTube access"),
            _buildFeatureItem("❤️ Favorites", "Save movies locally"),
            _buildFeatureItem("✨ Smooth UI", "Dark mode & Hero animations"),

            // ৩. টেকনোলজি চিপস
            const SizedBox(height: 20), // 🔥 এই লাইনটা স্পেস বাড়াবে
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Built With",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTechChip("Flutter"),
                _buildTechChip("Dart"),
                _buildTechChip("Provider"),
                _buildTechChip("TMDB API"),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.grey),

            // ৪. ডেভেলপার ইনফো
            _buildInfoTile(Icons.business, "Developed Company", "Crimon Tech"),
            _buildInfoTile(
              Icons.code,
              "Developed by",
              "MD Rohejul Islam Hemal",
            ),
            _buildInfoTile(
              Icons.location_on,
              "Location",
              "Uttara Model Town, Dhaka-1230",
            ),

            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Connect with Us",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 🔥 ৫. সোশ্যাল লিংকস (Design 1: List Style)
            // এখানে তোমার দেওয়া সব লিংক অ্যাড করা হয়েছে
            Column(
              children: [
                _buildSocialCard(
                  icon: Icons.email,
                  title: "Email",
                  subTitle: "rohejulislamhimal0099@gmail.com",
                  color: Colors.orange,
                  url: "mailto:rohejulislamhimal0099@gmail.com",
                ),
                _buildSocialCard(
                  icon: Icons.code, // GitHub Icon substitute
                  title: "GitHub",
                  subTitle: "github.com/hemal6325",
                  color: Colors.white,
                  url: "https://github.com/hemal6325",
                ),
                _buildSocialCard(
                  icon: Icons.facebook,
                  title: "Facebook",
                  subTitle: "facebook.com/rohejulhemal",
                  color: Colors.blue,
                  url: "https://facebook.com/rohejulhemal",
                ),
                _buildSocialCard(
                  icon: Icons.camera_alt,
                  title: "Instagram",
                  subTitle: "instagram.com/rohejulhemal",
                  color: Colors.pinkAccent,
                  url: "https://instagram.com/rohejulhemal",
                ),
                _buildSocialCard(
                  icon: Icons.share, // Twitter Icon substitute
                  title: "Twitter (X)",
                  subTitle: "twitter.com/rohejulhemal",
                  color: Colors.lightBlueAccent,
                  url: "https://twitter.com/rohejulhemal",
                ),
                _buildSocialCard(
                  icon: Icons.linked_camera, // LinkedIn Icon substitute
                  title: "LinkedIn",
                  subTitle: "linkedin.com/in/rohejulhemal",
                  color: Colors.blueAccent,
                  url: "https://www.linkedin.com/in/rohejulhemal/",
                ),
                _buildSocialCard(
                  icon: Icons.play_circle_fill,
                  title: "YouTube",
                  subTitle: "youtube.com/@rohejul_hemal",
                  color: Colors.red,
                  url: "https://www.youtube.com/@rohejul_hemal",
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Text(
              "© 2024-2025 Movie Info App. All Rights Reserved.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- হেল্পার উইজেট ---

  Widget _buildTechChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[900],
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      side: const BorderSide(color: Colors.amber),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 🔥 নতুন কার্ড ডিজাইন উইজেট
  Widget _buildSocialCard({
    required IconData icon,
    required String title,
    required String subTitle,
    required Color color,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subTitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 14,
        ),
        onTap: () => _launchURL(url),
      ),
    );
  }
}

// এই হেল্পার উইজেটটি ক্লাসের শেষে রাখো
Widget _buildFeatureItem(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            "- $subtitle",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
