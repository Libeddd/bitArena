import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _isExpanded = false;

  // --- DATA ANGGOTA TIM (9 ORANG) ---
  final List<Map<String, String>> _teamMembers = const [
    {
      'name': 'Alex Wijaya',
      'role': 'Chief Executive Officer',
      'image': 'assets/team_member_1.png',
      'github': 'https://github.com/alexwijaya',
      'instagram': 'https://instagram.com/alexwijaya',
    },
    {
      'name': 'Sarah Putri',
      'role': 'Product Manager',
      'image': 'assets/team_member_2.png',
      'github': 'https://github.com/sarahputri',
      'instagram': 'https://instagram.com/sarahputri',
    },
    {
      'name': 'Budi Santoso',
      'role': 'Lead Backend Engineer',
      'image': 'assets/team_member_3.png',
      'github': 'https://github.com/budisantoso',
      'instagram': 'https://instagram.com/budisantoso',
    },
    {
      'name': 'Dina Kusuma',
      'role': 'Lead Mobile Developer',
      'image': 'assets/team_member_4.png',
      'github': 'https://github.com/dinakusuma',
      'instagram': 'https://instagram.com/dinakusuma',
    },
    {
      'name': 'Eko Prasetyo',
      'role': 'DevOps Specialist',
      'image': 'assets/team_member_5.png',
      'github': 'https://github.com/ekoprasetyo',
      'instagram': 'https://instagram.com/ekoprasetyo',
    },
    {
      'name': 'Fanny Rahma',
      'role': 'UI/UX Designer',
      'image': 'assets/team_member_6.png',
      'github': 'https://github.com/fannyrahma',
      'instagram': 'https://instagram.com/fannyrahma',
    },
    {
      'name': 'Gilang Ramadhan',
      'role': 'Frontend Developer',
      'image': 'assets/team_member_7.png',
      'github': 'https://github.com/gilang',
      'instagram': 'https://instagram.com/gilang',
    },
    {
      'name': 'Haniifah',
      'role': 'Quality Assurance',
      'image': 'assets/team_member_8.png',
      'github': 'https://github.com/haniifah',
      'instagram': 'https://instagram.com/haniifah',
    },
    {
      'name': 'Indra Lesmana',
      'role': 'System Analyst',
      'image': 'assets/team_member_9.png',
      'github': 'https://github.com/indralesmana',
      'instagram': 'https://instagram.com/indralesmana',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DESKRIPSI PROJECT (NARRATIVE) ---
            Text(
              'The bitArena Story',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Paragraf 1: Pengenalan & Misi (Selalu Ditampilkan)
            Text(
              'Selamat datang di bitArena, gerbang utama Anda menuju dunia hiburan digital tanpa batas. Dibangun dengan teknologi Flutter terbaru dan ditenagai oleh performa handal, bitArena bukan sekadar katalog game—ini adalah ekosistem yang dirancang untuk para pencinta game lintas platform.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
            
            // --- KONTEN EXPANDABLE (Show More) ---
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              // Paragraf 2: Fitur Teknis & Keunggulan
              Text(
                'Kami memahami betapa sulitnya menemukan game yang tepat di tengah lautan pilihan. Oleh karena itu, kami menghadirkan fitur pencarian cerdas, filter genre yang mendalam, dan kategori platform spesifik (PC, PlayStation, Xbox) untuk memastikan Anda menemukan petualangan berikutnya dengan mudah. Dengan antarmuka yang responsif dan integrasi data real-time, kami berkomitmen menyajikan informasi akurat dan pengalaman pengguna yang mulus.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              // Paragraf 3: Visi Tim
              Text(
                'bitArena lahir dari passion kami terhadap kode dan gaming. Kami percaya bahwa teknologi harus mempermudah hobi Anda, bukan mempersulitnya. Terus mainkan, terus jelajahi, dan biarkan bitArena menjadi panduan Anda.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.justify,
              ),
            ],

            // --- TOMBOL TOGGLE SHOW MORE / LESS ---
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? "Sembunyikan" : "Lihat Selengkapnya",
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 30),

            // --- 2. MEET OUR TEAM SECTION ---
            Center(
              child: Column(
                children: [
                  Text(
                    'Meet The Squad',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orang-orang hebat di balik layar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid untuk Kartu Tim (Builder untuk 9 item)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.8,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _teamMembers.length,
              itemBuilder: (context, index) {
                final member = _teamMembers[index];
                return TeamMemberCard(
                  name: member['name']!,
                  role: member['role']!,
                  imagePath: member['image']!,
                  githubUrl: member['github']!,
                  instagramUrl: member['instagram']!,
                );
              },
            ),
            
            // Copyright footer kecil
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2024 bitArena Team. All rights reserved.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET KARTU TIM ---
class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final String githubUrl;
  final String instagramUrl;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.githubUrl,
    required this.instagramUrl,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Foto Anggota
          Container(
            width: 80, 
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
              color: Colors.grey[800],
              image: DecorationImage(
                image: AssetImage(imagePath), 
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white24, size: 40), 
          ),
          const SizedBox(height: 12),
          
          // Nama & Role
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Link Sosial Media
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIconBtn(
                icon: FontAwesomeIcons.github,
                color: Colors.white,
                onTap: () => _launchURL(githubUrl),
              ),
              const SizedBox(width: 12),
              _SocialIconBtn(
                icon: FontAwesomeIcons.instagram,
                color: Colors.pinkAccent,
                onTap: () => _launchURL(instagramUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FaIcon(
            icon,
            color: color,
            size: 26, 
          ),
        ),
      ),
    );
  }
}