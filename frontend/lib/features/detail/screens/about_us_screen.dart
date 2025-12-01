import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _isExpanded = false;

  // Konstanta untuk Lebar Maksimum Konten (Desktop)
  static const double kMaxWidth = 1000.0;

  final List<Map<String, String>> _teamMembers = const [
    {
      'name': 'Mochammad Abid Sunaryo',
      'role': 'Leader Engineer',
      'image': 'https://avatars.githubusercontent.com/u/174584123?v=4',
      'github': 'https://github.com/alexwijaya',
      'instagram': 'https://instagram.com/alexwijaya',
    },
    {
      'name': 'Gofur Aryan Nur Karim',
      'role': 'Vice Leader Engineer',
      'image': 'https://avatars.githubusercontent.com/u/207808411?v=4',
      'github': 'https://github.com/Gofurryan',
      'instagram': 'https://instagram.com/gfryann',
    },
    {
      'name': 'Gilang Kelvin Saputra',
      'role': 'Lead Frontend Engineer',
      'image': 'https://avatars.githubusercontent.com/u/208259638?v=4',
      'github': 'https://github.com/vsarutobi',
      'instagram': 'https://instagram.com/gilangkelv',
    },
    {
      'name': 'Muhammad nur thohir',
      'role': 'Lead Mobile Developer',
      'image': 'https://avatars.githubusercontent.com/u/212884099?s=60&v=4',
      'github': 'https://github.com/draxel03',
      'instagram': 'https://instagram.com/nrthohir',
    },
    {
      'name': 'Izha Valensy',
      'role': 'Lead Backend Engineer',
      'image': 'https://avatars.githubusercontent.com/u/208361358?v=4',
      'github': 'https://github.com/1jaxxx',
      'instagram': 'https://instagram.com/ijakk_iv',
    },
    {
      'name': 'Muhammad Amrullah Widyapratama',
      'role': 'Support Frontend Engineer',
      'image': 'https://avatars.githubusercontent.com/u/182313276?s=60&v=4',
      'github': 'https://github.com/AxelPra',
      'instagram': 'https://instagram.com/xel_prtmaa_',
    },
    {
      'name': 'Ismail Ali Mukharom',
      'role': 'Quality Assurance',
      'image': 'https://avatars.githubusercontent.com/u/200033565?s=60&v=4',
      'github': 'https://github.com/IlDarkCloud',
      'instagram': 'https://instagram.com/ishllmho',
    },
    {
      'name': 'Muhammad Dava Khoirur Roziqy',
      'role': 'System Analyst',
      'image': 'https://avatars.githubusercontent.com/u/208224463?v=4',
      'github': 'https://github.com/SUPERChild973/SUPER973',
      'instagram': 'https://www.instagram.com/davajharzqyy__',
    },
    {
      'name': 'Muhammad Noor Abizar',
      'role': 'System Analyst',
      'image': 'https://avatars.githubusercontent.com/u/208147443?s=60&v=4',
      'github': 'https://github.com/mnabizar',
      'instagram': 'https://instagram.com/mnabizar',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar saat ini
    final screenWidth = MediaQuery.of(context).size.width;
    // Menentukan jumlah kolom GridView berdasarkan lebar layar
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

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
      body: Center(
        // CENTER KONTEN UTAMA
        child: ConstrainedBox(
          // BATAS LEBAR MAKSIMUM
          constraints: const BoxConstraints(maxWidth: kMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. DESKRIPSI PROJECT (NARRATIVE) ---
                Text(
                  'bitArena Story',
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
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
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
                        'Orang-orang di balik layar',
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Variabel responsif
                    childAspectRatio: 0.7,
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
                    '© 2025 bitArena Team. All rights reserved.',
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
              border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
              color: Colors.grey[800],
              image: DecorationImage(
                image: CachedNetworkImageProvider(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint("Gagal memuat gambar: $exception");
                },
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
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
