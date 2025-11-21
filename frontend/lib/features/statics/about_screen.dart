import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("About", style: GoogleFonts.poppins()),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "bitArena adalah aplikasi katalog game yang menyediakan informasi "
          "seputar game terbaru, game trending, serta berbagai genre dan platform.",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
