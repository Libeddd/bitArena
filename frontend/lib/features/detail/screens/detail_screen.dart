import 'dart:async';
import 'dart:math';
import 'package:universal_io/io.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitarena/app/app_routes.dart';
import 'package:bitarena/features/detail/cubit/detail_cubit.dart';
import 'package:bitarena/data/models/game_model.dart';
import 'package:bitarena/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String gameId;
  const DetailScreen({super.key, required this.gameId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DetailCubit>().fetchGameDetails(widget.gameId);
  }

  void _showDownloadDialog(
      BuildContext context, String gameName, String gameImage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _DownloadPopup(
          gameName: gameName,
          gameImage: gameImage,
          onDownloadStart: () => _executeDownloadLogic(gameName),
        );
      },
    );
  }

// detail_screen.dart

Future<bool> _executeDownloadLogic(String gameName) async {
  try {
    if (kIsWeb) {
      // Platform Web
      return await _createDummyGameFileWeb(gameName);
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Platform Mobile (membutuhkan pemeriksaan izin)
      return await _checkPermissionAndDownloadNative(gameName);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Platform Desktop (tidak memerlukan pemeriksaan izin eksternal)
      return await _createDummyGameFileNative(gameName);
    }
    return false;
  } catch (e) {
    debugPrint("Download Exception: $e");
    return false;
  }
}
// detail_screen.dart

Future<bool> _checkPermissionAndDownloadNative(String gameName) async {
  if (Platform.isAndroid) {
    // 🔥 PERBAIKAN: Kita menggunakan Permission.storage.request().
    // Di Android API 33+ (terbaru), permintaan ini akan memunculkan izin media (Foto/Video)
    // atau izin "Files and Media" (Penyimpanan), tergantung target SDK.
    // Kita anggap jika status granted, OS telah memberikan izin yang cukup.
    var status = await Permission.storage.request(); 
    
    // Periksa status
    if (status.isGranted) {
        debugPrint("Permission STORAGE/Media granted. Proceeding with download.");
        return await _createDummyGameFileNative(gameName);
    }
    
    // Jika ditolak atau ditolak permanen
    if (status.isPermanentlyDenied) {
        // Arahkan pengguna ke pengaturan untuk memberikan izin secara manual.
        openAppSettings();
    }
    
    return false; 
    
  } else if (Platform.isIOS) {
    // Untuk iOS, izin PhotoLibrary diperlukan untuk menyimpan media atau file
    var status = await Permission.photos.request();
    if (status.isGranted || await Permission.photosAddOnly.isGranted) {
        debugPrint("Permission PHOTOS granted.");
        return await _createDummyGameFileNative(gameName);
    }
    return false;
  }
  return false;
}

  Future<bool> _createDummyGameFileWeb(String gameName) async {
    try {
      final safeName =
          gameName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final fileName = "$safeName.exe";
      List<int> dummyBytes =
          List.generate(1024 * 50, (index) => Random().nextInt(255));

      final blob = html.Blob([dummyBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return true;
    } catch (e) {
      return false;
    }
  }

// detail_screen.dart

Future<bool> _createDummyGameFileNative(String gameName) async {
  try {
    final safeName =
        gameName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final fileName = "$safeName.exe";

    Directory? directory;

    // 🔥 PRIORITAS UTAMA: Gunakan getDownloadsDirectory()
    // Ini adalah metode yang disarankan dan paling aman untuk Android Scoped Storage 
    // dan juga berfungsi untuk Desktop.
    directory = await getDownloadsDirectory();
    
    if (directory == null) {
        // FALLBACK: Hanya dijalankan jika getDownloadsDirectory() gagal.
        if (Platform.isAndroid) {
            // Fallback ke direktori spesifik aplikasi (selalu bisa ditulis)
            directory = await getApplicationDocumentsDirectory(); 
            debugPrint("Fallback to App Documents directory.");
        } else {
            // Fallback ke direktori dokumen umum (untuk Desktop jika downloads null)
            directory = await getApplicationDocumentsDirectory(); 
        }
    }

    if (directory == null) {
        debugPrint("Fatal: Could not determine any writable download directory.");
        return false;
    }

    // Pastikan folder download ada
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    final String filePath = "${directory.path}/$fileName";
    final File file = File(filePath);
    List<int> dummyBytes =
        List.generate(1024 * 50, (index) => Random().nextInt(255));

    await file.writeAsBytes(dummyBytes);
    return true;
  } catch (e) {
    debugPrint("File creation error: $e");
    return false;
  }
}

  void _handleWishlistToggle(
      BuildContext context, GameModel game, bool isCurrentlyWishlisted) {
    context.read<WishlistCubit>().toggleWishlist(game);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !isCurrentlyWishlisted
              ? "Added to Wishlist"
              : "Removed from Wishlist",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor:
            !isCurrentlyWishlisted ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openFullScreenGallery(
      BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(images: images, initialIndex: index),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          if (state is DetailLoading) return _buildLoadingScreen();
          if (state is DetailError) {
            return _buildErrorScreen(context, state.message);
          }
          if (state is DetailSuccess) {
            return _buildSuccessContent(context, state.game);
          }
          return _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, GameModel game) {

    const double kMaxWidth = 1250.0;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 600,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: game.backgroundImage,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: (context, url) => Container(color: Colors.black),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      const Color(0xFF121212).withOpacity(0.8),
                      const Color(0xFF121212),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isDesktop = constraints.maxWidth > 800;

                        if (isDesktop) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderInfo(game, isCenter: false),
                              const SizedBox(height: 10),
                              Text(game.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.1)),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildActionButtons(game),
                                            const SizedBox(height: 32),
                                            _buildRatingsSection(game),
                                            const SizedBox(height: 32),
                                            _buildAboutSection(game),
                                            const SizedBox(height: 32),
                                            _buildSpecsAndDetails(game)
                                          ])),
                                  const SizedBox(width: 40),
                                  Expanded(
                                      flex: 3,
                                      child: _buildMediaGallery(
                                        game,
                                      )),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildHeaderInfo(game, isCenter: true),
                              const SizedBox(height: 10),
                              Text(game.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.1)),
                              const SizedBox(height: 24),
                              _buildActionButtons(game),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMediaGallery(
                                      game,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildRatingsSection(game),
                                    const SizedBox(height: 32),
                                    _buildAboutSection(game),
                                    const SizedBox(height: 32),
                                    _buildSpecsAndDetails(game),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildDownloadButton(
                        context, game.name, game.backgroundImage),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => context.pop()),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo(GameModel game, {required bool isCenter}) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: isCenter ? WrapAlignment.center : WrapAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Text(game.releasedDate.toUpperCase(),
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: game.platforms
              .take(4)
              .map((p) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child:
                      Icon(_getPlatformIcon(p), color: Colors.white, size: 16)))
              .toList(),
        ),
        if (game.playtime > 0)
          Text("AVERAGE PLAYTIME: ${game.playtime} HOURS",
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildActionButtons(GameModel game) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final isWishlisted =
            context.read<WishlistCubit>().isWishlisted(game.id);
        return OutlinedButton(
          onPressed: () => _handleWishlistToggle(context, game, isWishlisted),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
                color: isWishlisted ? Colors.redAccent : Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isWishlisted ? "In Wishlist" : "Add to Wishlist",
                  style: TextStyle(
                      color: isWishlisted ? Colors.redAccent : Colors.white)),
              const SizedBox(width: 8),
              Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isWishlisted ? Colors.redAccent : Colors.white),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton(
      BuildContext context, String gameName, String gameImage) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showDownloadDialog(context, gameName, gameImage),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded),
            const SizedBox(width: 12),
            Text('Download Game',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16))
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsSection(GameModel game) {
    List<Map<String, dynamic>> ratings = game.ratingsDistribution;
    if (ratings.isEmpty) {
      if (game.rating > 4.5) {
        ratings = [
          {'title': 'Exceptional', 'percent': 70.0, 'id': 5},
          {'title': 'Recommended', 'percent': 20.0, 'id': 4},
          {'title': 'Meh', 'percent': 5.0, 'id': 3},
          {'title': 'Skip', 'percent': 5.0, 'id': 1}
        ];
      } else {
        ratings = [
          {'title': 'Recommended', 'percent': 60.0, 'id': 4},
          {'title': 'Meh', 'percent': 30.0, 'id': 3},
          {'title': 'Skip', 'percent': 10.0, 'id': 1}
        ];
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(_getRatingTitle(game.rating),
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(width: 8),
        Icon(_getRatingIcon(game.rating), color: Colors.amber, size: 24),
        const SizedBox(width: 16),
        Text("${game.rating} Rating",
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white54))
      ]),
      const SizedBox(height: 16),
      ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
              height: 50,
              child: Row(
                  children: ratings
                      .map((r) => Expanded(
                          flex: (r['percent'] as double).toInt() == 0
                              ? 1
                              : (r['percent'] as double).toInt(),
                          child: Container(color: _getRatingColor(r['id']))))
                      .toList()))),
      const SizedBox(height: 12),
      Wrap(
          spacing: 16,
          runSpacing: 8,
          children: ratings
              .map((r) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle,
                        color: _getRatingColor(r['id']), size: 10),
                    const SizedBox(width: 6),
                    Text(r['title'].toString().capitalize(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text("${r['count'] ?? ''}",
                        style: const TextStyle(color: Colors.white54))
                  ]))
              .toList())
    ]);
  }

  Widget _buildMediaGallery(GameModel game) {
    final List<String> images =
        game.screenshots.isNotEmpty ? game.screenshots : [game.backgroundImage];
    final String mainImage = images.first;
    final List<String> gridImages = images.length > 1 ? images.sublist(1) : [];

    return Column(
      children: [
        InkWell(
          onTap: () => _openFullScreenGallery(context, images, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(mainImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (gridImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 16 / 9,
            ),
            itemCount: gridImages.length > 4 ? 4 : gridImages.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => _openFullScreenGallery(context, images, index + 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: gridImages[index],
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: Colors.grey[900]),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAboutSection(GameModel game) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _ExpandableText(text: game.description),
        ],
      );

  Widget _buildSpecsAndDetails(GameModel game) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              "Platforms",
              _buildFilterButtons(
                  context: context,
                  items: game.detailedPlatforms,
                  isPlatform: true)),
          const SizedBox(height: 16),
          _buildDetailRow(
              "Genres",
              _buildFilterButtons(
                  context: context,
                  items: game.detailedGenres,
                  isPlatform: false)),
          const SizedBox(height: 16),
          _buildDetailRow(
              "Developer", _buildSimpleText(game.developers.join(', '))),
          const SizedBox(height: 16),
          _buildDetailRow(
              "Publisher", _buildSimpleText(game.publishers.join(', '))),
          const SizedBox(height: 32),
          if (game.pcRequirements['minimum']!.isNotEmpty) ...[
            Text("System requirements for PC",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.pcRequirements['minimum']!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 16),
                    if (game.pcRequirements['recommended']!.isNotEmpty) ...[
                      Text(game.pcRequirements['recommended']!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13, height: 1.5))
                    ]
                  ]),
            ),
          ],
        ],
      );

  Widget _buildDetailRow(String label, Widget child) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14))),
        Expanded(child: child)
      ]);
  Widget _buildSimpleText(String text) => Text(text,
      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4));
  Widget _buildFilterButtons(
      {required BuildContext context,
      required List<Map<String, dynamic>> items,
      required bool isPlatform}) {
    if (items.isEmpty) return _buildSimpleText("Unknown");
    return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map((item) => InkWell(
                onTap: () {
                  final Map<String, String> filters = {};
                  if (isPlatform) {
                    filters['parent_platforms'] = item['id'].toString();
                  } else {
                    filters['genres'] = item['slug'];
                  }
                  context.pushNamed(AppRoutes.browse, queryParameters: {
                    'title': "${item['name']} Games",
                    ...filters
                  });
                },
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(item['name'],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)))))
            .toList());
  }

      IconData _getPlatformIcon(String platform) {
        final p = platform.toLowerCase();
        if (p.contains('pc') || p.contains('windows')) {
          return FontAwesomeIcons.windows;
        }
        if (p.contains('playstation') || p.contains('ps')) {
          return FontAwesomeIcons.playstation;
        }
        if (p.contains('xbox')) return FontAwesomeIcons.xbox;
        if (p.contains('switch') || p.contains('nintendo')) {
          return FontAwesomeIcons.gamepad;
        }
        if (p.contains('mac') || p.contains('apple')) return FontAwesomeIcons.apple;
        if (p.contains('linux')) return FontAwesomeIcons.linux;
        if (p.contains('android')) return FontAwesomeIcons.android;
        if (p.contains('ios')) return FontAwesomeIcons.appStoreIos;
        return FontAwesomeIcons.gamepad;
      }

      String _getRatingTitle(double rating) {
        if (rating >= 4.5) return "Exceptional";
        if (rating >= 3.5) return "Recommended";
        if (rating >= 2.5) return "Meh";
        return "Skip";
      }

      IconData _getRatingIcon(double rating) {
        if (rating >= 4.5) return FontAwesomeIcons.bullseye;
        if (rating >= 3.5) return FontAwesomeIcons.thumbsUp;
        if (rating >= 2.5) return FontAwesomeIcons.faceMeh;
        return FontAwesomeIcons.ban;
      }

      Color _getRatingColor(int id) {
        switch (id) {
          case 5:
            return const Color(0xFF6DC849);
          case 4:
            return const Color(0xFF4D85F0);
          case 3:
            return const Color(0xFFFDCA52);
          case 1:
            return const Color(0xFFFF4842);
          default:
            return Colors.grey;
        }
      }

  Widget _buildLoadingScreen() => const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(child: CircularProgressIndicator()));
  Widget _buildErrorScreen(BuildContext context, String msg) => Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      backgroundColor: const Color(0xFF121212),
      body: Center(
          child: Text("Error: $msg",
              style: const TextStyle(color: Colors.white))));
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});
  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Text(widget.text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5),
              maxLines: _isExpanded ? null : 4,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.fade)),
      const SizedBox(height: 8),
      GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Text(_isExpanded ? "Show less" : "Show more",
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11))))
    ]);
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenGallery({required this.images, required this.initialIndex});
  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                        child: CachedNetworkImage(
                            imageUrl: widget.images[index],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error, color: Colors.white))));
              }),
          Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: SafeArea(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    const SizedBox(width: 48),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.chevron_left,
                                  color: _currentIndex > 0
                                      ? Colors.white
                                      : Colors.white38),
                              onPressed: _goToPrevious),
                          const SizedBox(width: 16),
                          IconButton(
                              icon: Icon(Icons.chevron_right,
                                  color:
                                      _currentIndex < widget.images.length - 1
                                          ? Colors.white
                                          : Colors.white38),
                              onPressed: _goToNext)
                        ])),
                    Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle),
                            child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context))))
                  ]))),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 100,
                  color: Colors.black.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length + 1,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        if (index == widget.images.length) {
                          return Container(
                              width: 60,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24)),
                              child: const Icon(Icons.more_horiz,
                                  color: Colors.white));
                        }
                        final bool isSelected = index == _currentIndex;
                        return GestureDetector(
                            onTap: () {
                              _pageController.jumpToPage(index);
                            },
                            child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.white, width: 2)
                                        : null),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                            isSelected
                                                ? Colors.transparent
                                                : Colors.black.withOpacity(0.5),
                                            BlendMode.darken),
                                        child: CachedNetworkImage(
                                            imageUrl: widget.images[index],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                    color:
                                                        Colors.grey[900]))))));
                      })))
        ]));
  }
}

class _DownloadPopup extends StatefulWidget {
  final String gameName;
  final String gameImage;
  final Future<bool> Function() onDownloadStart;

  const _DownloadPopup(
      {required this.gameName,
      required this.gameImage,
      required this.onDownloadStart});

  @override
  State<_DownloadPopup> createState() => _DownloadPopupState();
}

class _DownloadPopupState extends State<_DownloadPopup> {
  int _currentStatus = 0;

  Future<void> _runDownloadProcess() async {
    setState(() {
      _currentStatus = 1;
    });

    bool isSuccess = await widget.onDownloadStart();

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _currentStatus = isSuccess ? 2 : 3;
      });

      if (isSuccess) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[900],
                backgroundImage: CachedNetworkImageProvider(widget.gameImage),
              ),
            ),
            Text(
              _currentStatus == 0
                  ? "Starting Download..."
                  : _currentStatus == 1
                      ? "Downloading..."
                      : _currentStatus == 2
                          ? "Success!"
                          : "Failed",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.gameName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _buildStateWidget(),
            ),
            if (_currentStatus == 3)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close",
                      style: TextStyle(color: Colors.white54)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildStateWidget() {
    switch (_currentStatus) {
      case 0:
        return TweenAnimationBuilder<double>(
          key: const ValueKey("CountdownTween"),
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(seconds: 7),
          onEnd: () {
            _runDownloadProcess();
          },
          builder: (context, value, child) {
            final int secondsLeft = (value * 7).ceil();

            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[800],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  "$secondsLeft",
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            );
          },
        );
      case 1:
        return const SizedBox(
          key: ValueKey("Loading"),
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          ),
        );
      case 2:
        return Column(
          key: const ValueKey("Success"),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF4CAF50), size: 80),
            const SizedBox(height: 8),
            Text("File Saved",
                style: GoogleFonts.poppins(
                    color: const Color(0xFF4CAF50), fontSize: 12)),
          ],
        );
      case 3:
        return Column(
          key: const ValueKey("Error"),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.highlight_off, color: Color(0xFFE53935), size: 80),
            const SizedBox(height: 8),
            Text("Permission Denied / Error",
                style: GoogleFonts.poppins(
                    color: const Color(0xFFE53935), fontSize: 12)),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}
