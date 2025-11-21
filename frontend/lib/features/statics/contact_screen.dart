import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget buildGridCard({
    required String title,
    required String imagePath,
    required String url,
  }) {
    return InkWell(
      onTap: () => _openUrl(url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Title
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 50),

            Text(
              url,
              style: GoogleFonts.poppins(
                color: Colors.blueAccent,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Contact", style: GoogleFonts.poppins()),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 3,            
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.96,     
          children: [
            buildGridCard(
              title: "GitHub",
              imagePath: "assets/amine.jpeg",
              url: "https://github.com/SUPERChild973",
            ),
            buildGridCard(
              title: "GitHub",
              imagePath: "assets/logo.png",
              url: "https://bitarena.com",
            ),
            buildGridCard(
              title: "GitHub",
              imagePath: "assets/logo.png",
              url: "https://bitarena.com",
            ),
            buildGridCard(
              title: "GitHub",
              imagePath: "assets/logo.png",
              url: "https://bitarena.com",
            ),
            buildGridCard(
              title: "GitHub",
              imagePath: "assets/logo.png",
              url: "https://bitarena.com",
            ),
          ],
        ),
      ),
    );
  }
}
