import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:video_player/video_player.dart';

// --- Variabel Global untuk Kamera & State Aplikasi (Untuk Prototipe) ---
late List<CameraDescription> cameras;
List<CollectedPlant> globalCollectedPlants = [];
int globalHintCount = 0;
DateTime? globalLastHintResetDate;

// --- STATE PENGGUNA GLOBAL (Untuk Sinkronisasi Data) ---
class User {
  String name;
  int points;
  User({required this.name, required this.points});
}

User currentUser = User(name: "Nama Pengguna", points: 1250);

// --- FUNGSI UTAMA APLIKASI ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MainApp());
}

// --- WIDGET ROOT APLIKASI ---
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthPage(), // Aplikasi dimulai dari halaman login
    );
  }
}

// =================================================================
// MODEL DATA (Semua model data digabungkan di sini)
// =================================================================

class PlantInfo {
  final String name;
  final String? commonName;
  final String description;
  final String benefits;
  PlantInfo({
    required this.name,
    this.commonName,
    required this.description,
    required this.benefits,
  });
}

class CollectedPlant {
  final PlantInfo plantInfo;
  final File imageFile;
  CollectedPlant({required this.plantInfo, required this.imageFile});
}

class PuzzleStage {
  final String assetPath;
  final String plantKey;
  final int gridSize;
  bool isUnlocked;
  List<int>? currentArrangement;
  PuzzleStage({
    required this.assetPath,
    required this.plantKey,
    required this.gridSize,
    this.isUnlocked = false,
    this.currentArrangement,
  });
}

class Player {
  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;
  Player({
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });
}

class NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;
  bool isRead;
  NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}

// --- MODEL DATA UNTUK GAME CERITA ---
class QuizOption {
  final String text;
  final bool isCorrect;
  QuizOption(this.text, this.isCorrect);
}

class StoryFrame {
  final String imagePath;
  final String text;
  final List<QuizOption>? quizOptions;

  StoryFrame({required this.imagePath, required this.text, this.quizOptions});
}

class StoryGameStage {
  final String title;
  final String subtitle;
  bool isUnlocked;
  final List<StoryFrame> storyFrames;

  StoryGameStage({
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
    required this.storyFrames,
  });
}

// =================================================================
// DATA DUMMY (Semua data contoh digabungkan di sini)
// =================================================================

final Map<String, PlantInfo> plantDatabase = {
  'Calochortus luteus': PlantInfo(
    name: 'Calochortus luteus',
    commonName: 'Bunga Mariposa Lily Kuning',
    description:
        'Bunga Calochortus luteus adalah spesies mariposa lily asli California. Ini adalah tumbuhan berbunga abadi dengan bunga berbentuk tulip berwarna kuning cerah di ujung batang yang dapat tumbuh hingga sekitar 18 inci.',
    benefits: 'Karena keindahannya, bunga ini dapat dijadikan tanaman hias.',
  ),
  'Rosa palustris': PlantInfo(
    name: 'Rosa palustris',
    commonName: 'Mawar Rawa',
    description:
        'Mawar adalah tanaman hias populer yang dikenal karena bunganya yang indah dan harum...',
    benefits:
        'Selain kaya rasa, wortel memiliki banyak manfaat bagi kesehatan. Kandungan beta-karoten di dalamnya akan diubah tubuh menjadi vitamin A yang penting untuk menjaga kesehatan mata.',
  ),
  'Urtica dioica': PlantInfo(
    name: 'Urtica dioica',
    commonName: 'Jelatang',
    description:
        'Jelatang adalah tanaman herbal abadi yang memiliki sejarah panjang penggunaan sebagai sumber makanan, teh, dan obat tradisional.',
    benefits:
        'Daunnya kaya akan vitamin dan mineral, sering digunakan untuk mengurangi peradangan, meredakan alergi, dan mendukung kesehatan sendi.',
  ),
};

final List<PuzzleStage> puzzleStages = List.generate(15, (index) {
  int gridSize;
  if (index < 5) {
    gridSize = 2;
  } else if (index < 10) {
    gridSize = 3;
  } else {
    gridSize = 4;
  }

  String assetPath;
  String plantKey;
  int dummyIndex = index % 3;
  if (dummyIndex == 0) {
    assetPath = 'assets/WhatsApp Image 2025-09-11 at 00.38.53_838607c2.jpg';
    plantKey = 'Rosa palustris';
  } else if (dummyIndex == 1) {
    assetPath = 'assets/images/nettle.jpg';
    plantKey = 'Urtica dioica';
  } else {
    assetPath = 'assets/images/calochortus.jpg';
    plantKey = 'Calochortus luteus';
  }

  return PuzzleStage(
    assetPath: assetPath,
    plantKey: plantKey,
    gridSize: gridSize,
    isUnlocked: index == 0,
  );
});

// --- DATA DUMMY UNTUK GAME CERITA ---
final List<StoryGameStage> storyGameStages = List.generate(15, (index) {
  final storyFrames = [
    StoryFrame(
      imagePath: 'assets/2.jpg',
      text:
          'Hai teman-teman! Aku biji kecil. Hari ini aku mulai petualangan seru untuk jadi tanaman. Aku sudah masuk ke tanah yang hangat dan empuk. Rasanya nyaman sekali!',
    ),
    StoryFrame(
      imagePath: 'assets/1.jpg',
      text:
          'Aku haus… aku harus mencari air. Tapi, akarku harus tumbuh ke mana ya supaya bisa minum?',
      quizOptions: [
        QuizOption('A. Ke atas, menuju matahari.', false),
        QuizOption('B. Ke bawah, masuk ke dalam tanah.', true),
      ],
    ),
    StoryFrame(
      imagePath: 'assets/3.jpg',
      text:
          'Ahhh… segarnya! Air membuatku kuat, batangku jadi tegak, daunku jadi hijau cerah. Bersama air dan cahaya matahari, aku bisa tumbuh lebih tinggi, lebih sehat, dan suatu hari nanti aku akan jadi pohon besar yang menyejukkan semua.',
    ),
  ];

  return StoryGameStage(
    title: "Petualangan ${index + 1}",
    subtitle: "Level ${index + 1}",
    isUnlocked: index == 0,
    storyFrames: storyFrames,
  );
});

List<Player> getPlayersWithCurrentUser() {
  List<Player> players = [
    Player(rank: 0, name: "Pengguna 1", points: 1100),
    Player(rank: 0, name: "Pengguna 2", points: 980),
    Player(rank: 0, name: "Pengguna 3", points: 850),
    Player(rank: 0, name: "Pengguna 4", points: 840),
    Player(rank: 0, name: "Pengguna 5", points: 760),
    Player(rank: 0, name: "Pengguna 6", points: 720),
    Player(rank: 0, name: "Pengguna 7", points: 680),
  ];

  players.add(
    Player(
      rank: 0,
      name: currentUser.name,
      points: currentUser.points,
      isCurrentUser: true,
    ),
  );
  players.sort((a, b) => b.points.compareTo(a.points));

  List<Player> rankedPlayers = [];
  for (int i = 0; i < players.length; i++) {
    rankedPlayers.add(
      Player(
        rank: i + 1,
        name: players[i].name,
        points: players[i].points,
        isCurrentUser: players[i].isCurrentUser,
      ),
    );
  }

  return rankedPlayers;
}

final List<NotificationItem> notifications = [
  NotificationItem(
    icon: Icons.star,
    iconColor: Colors.amber,
    title: 'Puzzle Level 2 Terbuka!',
    description: 'Anda telah menyelesaikan Level 1.',
    time: '5 menit lalu',
  ),
  NotificationItem(
    icon: Icons.emoji_events,
    iconColor: Colors.green,
    title: 'Selamat! Anda mendapatkan +10 Poin',
    description: 'Poin didapatkan dari kuis.',
    time: '1 jam lalu',
    isRead: true,
  ),
];

// =================================================================
// HALAMAN-HALAMAN APLIKASI
// =================================================================

// --- HALAMAN LOGIN (AuthPage) ---
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<void> _loginUser(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 78, 116, 104),
              Color.fromARGB(255, 101, 119, 100),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                alignment: Alignment.bottomLeft,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELAMAT DATANG KEMBALI!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kami sangat senang bisa bertemu lagi dengan Anda!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Kata Sandi',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _loginUser(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            78,
                            116,
                            104,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN UTAMA (DashboardPage) ---
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeContainerPage(),
    const SettingsPage(),
    const CollectionPage(),
    const ProfilePage(),
  ];

  static const List<String> _pageTitles = <String>[
    'Beranda',
    'Pengaturan',
    'Koleksi Tanaman',
    'Profil',
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar:
          _selectedIndex == 0
              ? null
              : AppBar(
                title: Text(
                  _pageTitles[_selectedIndex],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
      body: _pages.elementAt(_selectedIndex),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20),
        child: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantScannerPage(),
                ),
              ).then((_) => setState(() {}));
            },
            backgroundColor: const Color.fromARGB(255, 78, 116, 104),
            elevation: 2.0,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 4.0,
          color: Colors.transparent,
          elevation: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildNavItem(
                  icon: Icons.home_outlined,
                  index: 0,
                  label: 'Beranda',
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  index: 1,
                  label: 'Pengaturan',
                ),
                const SizedBox(width: 80),
                _buildNavItem(
                  icon: Icons.collections_bookmark_outlined,
                  index: 2,
                  label: 'Koleksi',
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  index: 3,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final color =
        _selectedIndex == index
            ? const Color.fromARGB(255, 78, 116, 104)
            : Colors.grey;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --- CONTAINER UNTUK BERANDA & PERINGKAT (HomeContainerPage) ---
class HomeContainerPage extends StatelessWidget {
  const HomeContainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.vertical,
      children: const [HomePage(), LeaderboardPage(showAppBar: false)],
    );
  }
}

// --- KONTEN HALAMAN BERANDA (HomePage) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- DIUBAH --- Menambahkan path video
  // Ganti dengan path video Anda, atau biarkan null untuk menampilkan placeholder
  // Pastikan file ini ada di folder assets/videos/
  final List<String?> videoPaths = [
    'assets/dummy_vid2.mp4', // Contoh jika video ada
    null, // Contoh jika video belum ada
    'assets/dummy_vid2.mp4', // Contoh lagi
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.2),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
            icon: const Icon(Icons.notifications_none_outlined, size: 30),
          ),
          SizedBox(width: 15),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'Mengenal Tanaman!',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllVideosPage()),
              ),
            ),
            const SizedBox(height: 16),
            _buildVideoCarousel(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const Spacer(),
            _buildScrollIndicator(context),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 78, 116, 104).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 30,
              color: Color.fromARGB(255, 78, 116, 104),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currentUser.name,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Siap cari tanaman baru hari ini?',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
      ],
    );
  }

  Widget _buildVideoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 195,
          width: 360,
          child: PageView.builder(
            controller: _pageController,
            itemCount: videoPaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: VideoPlayerItem(
                  key: ValueKey(
                    videoPaths[index],
                  ), // Key untuk state management
                  videoPath: videoPaths[index],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            videoPaths.length,
            (index) => buildDot(index: index),
          ),
        ),
      ],
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionButton(
          context,
          Icons.map_outlined,
          'PETA (Petualangan Tanaman)',
          'Ikuti petualangan seru di dunia tumbuhan',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameStageMapPage()),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context,
          Icons.extension_outlined,
          'Puzzle Tanaman',
          'Asah otakmu dengan menyusun gambar acak tanaman',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PuzzleMenuPage()),
            ).then((_) {
              (context as Element).reassemble();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            78,
            116,
            104,
          ).withOpacity(onTap != null ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(
              255,
              78,
              116,
              104,
            ).withOpacity(onTap != null ? 0.3 : 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color:
                  onTap != null
                      ? const Color.fromARGB(255, 78, 116, 104)
                      : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: onTap != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: onTap != null ? Colors.black54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade600,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Geser ke bawah untuk melihat peringkat',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SlideTransition(
          position: _animation,
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 15,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// --- WIDGET BARU UNTUK MEMUTAR VIDEO ---
// --- WIDGET BARU UNTUK MEMUTAR VIDEO (SUDAH DIPERBAIKI) ---
class VideoPlayerItem extends StatefulWidget {
  final String? videoPath;
  const VideoPlayerItem({super.key, required this.videoPath});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset(widget.videoPath!);
    await _videoPlayerController.initialize();

    // Inisialisasi ChewieController SETELAH video siap
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
      // MENGGUNAKAN ASPECT RATIO ASLI DARI VIDEO
      aspectRatio: _videoPlayerController.value.aspectRatio,
      autoInitialize: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    // Memicu build ulang untuk menampilkan Chewie
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Pastikan controller hanya di-dispose jika sudah diinisialisasi
    if (widget.videoPath != null) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          widget.videoPath == null
              ? _buildVideoNotAvailable()
              : _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              ),
    );
  }

  Widget _buildVideoNotAvailable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: 60,
                ),
                const SizedBox(height: 8),
                Text(
                  'Video Belum Tersedia',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN SEMUA VIDEO (BARU) ---
class AllVideosPage extends StatelessWidget {
  const AllVideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua Video')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: 10, // Jumlah video placeholder
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Video', style: TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}

// --- HALAMAN MENU GAME ---
class GameMenuPage extends StatelessWidget {
  const GameMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGameCard(
            context: context,
            title: 'Game Puzzle',
            description: 'Asah otakmu dengan menyusun gambar tanaman.',
            icon: Icons.extension,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PuzzleMenuPage()),
                ).then((_) {
                  (context as Element).reassemble();
                }),
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            context: context,
            title: 'PETA (Petualangan Tanaman)',
            description: 'Ikuti petualangan seru di dunia tanaman.',
            icon: Icons.menu_book,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameStageMapPage()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// --- HALAMAN PEMINDAI TANAMAN ---
class PlantScannerPage extends StatefulWidget {
  const PlantScannerPage({super.key});

  @override
  State<PlantScannerPage> createState() => _PlantScannerPageState();
}

class _PlantScannerPageState extends State<PlantScannerPage> {
  File? _image;
  bool _isLoading = false;
  PlantInfo? _detectionResult;
  String? _confidence;
  CameraController? _cameraController;
  Classifier? _classifier;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  Future<void> _loadModel() async {
    _classifier = await Classifier.create();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _classifier?.close();
    super.dispose();
  }

  void _processImage(File imageFile) {
    setState(() {
      _image = imageFile;
      _isLoading = true;
      _detectionResult = null;
      _confidence = null;
    });
    _analyzeImage(imageFile);
  }

  Future<void> _analyzeImage(File imageFile) async {
    if (_classifier == null) return;

    final prediction = await _classifier!.predict(imageFile);

    String scientificName = "Tidak Terdeteksi";
    double maxScore = 0.0;
    if (prediction.isNotEmpty) {
      final topPrediction = prediction.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      scientificName = topPrediction.key;
      maxScore = topPrediction.value;
    }

    setState(() {
      _detectionResult = plantDatabase[scientificName];
      _confidence = (maxScore * 100).toStringAsFixed(1);
      _isLoading = false;
    });
  }

  void _addToCollection() {
    if (_detectionResult != null && _image != null) {
      final newPlant = CollectedPlant(
        plantInfo: _detectionResult!,
        imageFile: _image!,
      );
      if (!globalCollectedPlants.any(
        (p) => p.plantInfo.name == newPlant.plantInfo.name,
      )) {
        globalCollectedPlants.add(newPlant);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_detectionResult!.name} ditambahkan ke koleksi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Info untuk tanaman ini tidak ada di database, tidak dapat ditambahkan.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _initializeCamera() async {
    if (cameras.isEmpty) return;
    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile imageFile = await _cameraController!.takePicture();
      _cameraController?.dispose();
      _cameraController = null;
      _processImage(File(imageFile.path));
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    _cameraController?.dispose();
    _cameraController = null;
    _processImage(File(pickedFile.path));
  }

  void _resetScanner() {
    setState(() {
      _image = null;
      _detectionResult = null;
      _isLoading = false;
      _confidence = null;
    });
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _image != null ? _buildResultScreen() : _buildCameraPreview(),
    );
  }

  Widget _buildResultScreen() {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => _resetScanner()),
          title: const Text('Menganalisis...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(_image!, height: 250),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _resetScanner()),
        title: const Text('Hasil Pemindaian'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(_image!),
            ),
            const SizedBox(height: 24),
            Text(
              _detectionResult?.name ?? 'Tidak Terdeteksi',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (_detectionResult?.commonName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _detectionResult!.commonName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            if (_confidence != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Keyakinan: $_confidence%',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Tambahkan ke Koleksi'),
              onPressed: _detectionResult != null ? _addToCollection : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _resetScanner,
              icon: const Icon(Icons.replay),
              label: const Text('Pindai Lagi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: IconButton(
              icon: const Icon(
                size: 35,
                Icons.arrow_back_outlined,
                color: Color.fromARGB(255, 78, 116, 104),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.grey),
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 4),
                    ),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 78, 116, 104),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.grey),
                  onPressed: _pickFromGallery,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- HALAMAN KOLEKSI ---
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    return globalCollectedPlants.isEmpty
        ? const Center(child: Text('Koleksi kamu masih kosong.'))
        : GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: globalCollectedPlants.length,
          itemBuilder: (context, index) {
            final plant = globalCollectedPlants[index];
            return GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailPage(plant: plant),
                    ),
                  ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.file(plant.imageFile, fit: BoxFit.cover),
              ),
            );
          },
        );
  }
}

// --- HALAMAN DETAIL TANAMAN ---
class PlantDetailPage extends StatelessWidget {
  final CollectedPlant plant;
  const PlantDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plant.plantInfo.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              plant.imageFile,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.plantInfo.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.plantInfo.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Manfaat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.plantInfo.benefits,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN GAME PUZZLE ---
class PuzzleMenuPage extends StatefulWidget {
  const PuzzleMenuPage({super.key});

  @override
  State<PuzzleMenuPage> createState() => _PuzzleMenuPageState();
}

class _PuzzleMenuPageState extends State<PuzzleMenuPage> {
  void _unlockNextStage(int solvedStageIndex) {
    if (solvedStageIndex + 1 < puzzleStages.length) {
      if (mounted) {
        setState(() => puzzleStages[solvedStageIndex + 1].isUnlocked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Puzzle'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Chip(
              avatar: Icon(Icons.star, color: Colors.amber.shade800),
              label: Text(
                '${currentUser.points} Poin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.amber.shade100,
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: puzzleStages.length,
        itemBuilder: (context, index) {
          final stage = puzzleStages[index];
          return GestureDetector(
            onTap:
                stage.isUnlocked
                    ? () async {
                      final bool? puzzleSolved = await Navigator.of(
                        context,
                      ).push(
                        MaterialPageRoute(
                          builder: (context) => PuzzlePage(stageIndex: index),
                        ),
                      );
                      if (mounted) {
                        setState(() {
                          if (puzzleSolved == true) {
                            _unlockNextStage(index);
                          }
                        });
                      }
                    }
                    : null,
            child: Container(
              decoration: BoxDecoration(
                color:
                    stage.isUnlocked
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: stage.isUnlocked ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child:
                    stage.isUnlocked
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        stage.assetPath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Text(
                                            "Ayo Mainkan",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Level ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        )
                        : Icon(
                          Icons.lock,
                          color: Colors.grey.shade500,
                          size: 50,
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PuzzlePage extends StatefulWidget {
  final int stageIndex;
  const PuzzlePage({super.key, required this.stageIndex});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late List<int> tiles;
  late int emptyTileIndex;
  late int gridSize;
  late int totalTiles;
  bool isSolved = false;
  int? _hintedTileIndex;

  @override
  void initState() {
    super.initState();
    final stage = puzzleStages[widget.stageIndex];
    gridSize = stage.gridSize;
    totalTiles = gridSize * gridSize;

    if (stage.currentArrangement != null) {
      tiles = List.from(stage.currentArrangement!);
      isSolved = false;
    } else {
      tiles = List.generate(totalTiles, (index) => index);
      isSolved = true;
    }
    emptyTileIndex = tiles.indexOf(totalTiles - 1);
    _loadHintData();
  }

  void _loadHintData() {
    final now = DateTime.now();
    if (globalLastHintResetDate == null ||
        now.difference(globalLastHintResetDate!).inDays >= 1) {
      setState(() {
        globalHintCount = 0;
        globalLastHintResetDate = now;
      });
    }
  }

  void _useHint() {
    if (globalHintCount >= 3 || isSolved) return;
    final misplacedTiles = <int>[];
    for (int i = 0; i < totalTiles; i++) {
      if (tiles[i] != i && tiles[i] != totalTiles - 1) misplacedTiles.add(i);
    }
    if (misplacedTiles.isNotEmpty) {
      setState(() {
        globalHintCount++;
        _hintedTileIndex =
            misplacedTiles[math.Random().nextInt(misplacedTiles.length)];
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _hintedTileIndex = null);
      });
    }
  }

  void shuffleTiles() {
    setState(() {
      final random = math.Random();
      for (int i = 0; i < totalTiles * 10; i++) {
        final neighbors = getValidNeighbors(emptyTileIndex);
        final randomNeighbor = neighbors[random.nextInt(neighbors.length)];
        swapTiles(randomNeighbor, emptyTileIndex);
        emptyTileIndex = randomNeighbor;
      }
      isSolved = false;
      puzzleStages[widget.stageIndex].currentArrangement = List.from(tiles);
    });
  }

  void moveTile(int tileIndex) {
    if (isSolved) return;
    if (isAdjacent(tileIndex, emptyTileIndex)) {
      setState(() {
        swapTiles(tileIndex, emptyTileIndex);
        emptyTileIndex = tileIndex;
        puzzleStages[widget.stageIndex].currentArrangement = List.from(tiles);
        checkIfSolved();
      });
    }
  }

  void swapTiles(int index1, int index2) {
    final temp = tiles[index1];
    tiles[index1] = tiles[index2];
    tiles[index2] = temp;
  }

  void checkIfSolved() async {
    bool solved = true;
    for (int i = 0; i < totalTiles; i++) {
      if (tiles[i] != i) {
        solved = false;
        break;
      }
    }
    if (solved) {
      setState(() {
        isSolved = true;
        puzzleStages[widget.stageIndex].currentArrangement = null;
        currentUser.points += 10;
      });

      final stage = puzzleStages[widget.stageIndex];
      final plantInfo = plantDatabase[stage.plantKey];

      if (plantInfo != null && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => _PuzzleCompleteDialog(
                plantInfo: plantInfo,
                level: widget.stageIndex,
                points: 10,
                onContinue: () {
                  Navigator.of(context).pop(); // Tutup dialog custom
                  Navigator.of(context).pop(true); // Kembali ke menu
                },
              ),
        );
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text("Selamat!"),
                content: Text(
                  "Anda berhasil menyelesaikan Puzzle Level ${widget.stageIndex + 1} dan mendapat +10 Poin!",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Lanjut"),
                  ),
                ],
              ),
        );
      }
    }
  }

  bool isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ gridSize;
    int col1 = index1 % gridSize;
    int row2 = index2 ~/ gridSize;
    int col2 = index2 % gridSize;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  List<int> getValidNeighbors(int index) {
    List<int> neighbors = [];
    int row = index ~/ gridSize;
    int col = index % gridSize;
    if (row > 0) neighbors.add(index - gridSize);
    if (row < gridSize - 1) neighbors.add(index + gridSize);
    if (col > 0) neighbors.add(index - 1);
    if (col < gridSize - 1) neighbors.add(index + 1);
    return neighbors;
  }

  @override
  Widget build(BuildContext context) {
    final stage = puzzleStages[widget.stageIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Puzzle Level ${widget.stageIndex + 1}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Susun kembali gambar tanaman ini!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: totalTiles,
                itemBuilder: (context, index) {
                  if (tiles[index] == totalTiles - 1) {
                    return Container(color: Colors.grey.shade200);
                  }
                  return GestureDetector(
                    onTap: () => moveTile(index),
                    child: _PuzzleTile(
                      image: Image.asset(stage.assetPath, fit: BoxFit.cover),
                      tileNumber: tiles[index],
                      gridSize: gridSize,
                      showHint: index == _hintedTileIndex,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: shuffleTiles,
                      icon: const Icon(Icons.shuffle),
                      label: Text(isSolved ? 'Mulai Acak' : 'Acak Ulang'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed:
                          globalHintCount < 3 && !isSolved ? _useHint : null,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: Text('Hint (${3 - globalHintCount})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                    ),
                  ],
                ),
                if (globalHintCount >= 3)
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Hint akan tersedia lagi besok.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  final Image image;
  final int tileNumber;
  final int gridSize;
  final bool showHint;
  const _PuzzleTile({
    required this.image,
    required this.tileNumber,
    required this.gridSize,
    this.showHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final int correctRow = tileNumber ~/ gridSize;
    final int correctCol = tileNumber % gridSize;
    final double alignmentX = (correctCol / (gridSize - 1)) * 2 - 1;
    final double alignmentY = (correctRow / (gridSize - 1)) * 2 - 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.fill,
            child: ClipRect(
              child: Align(
                alignment: Alignment(alignmentX, alignmentY),
                widthFactor: 1 / gridSize,
                heightFactor: 1 / gridSize,
                child: image,
              ),
            ),
          ),
          if (showHint)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Text(
                  '${tileNumber + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PuzzleCompleteDialog extends StatelessWidget {
  final PlantInfo plantInfo;
  final int level;
  final int points;
  final VoidCallback onContinue;

  const _PuzzleCompleteDialog({
    required this.plantInfo,
    required this.level,
    required this.points,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              "Level ${level + 1} Selesai!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Anda mengungkap tanaman: ${plantInfo.name}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Manfaat Tanaman",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plantInfo.benefits,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Chip(
              avatar: const Icon(Icons.star, color: Colors.white),
              label: Text(
                "+$points Poin",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 78, 116, 104),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text("Lanjutkan"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN GAME CERITA (KODE DIMODIFIKASI) ---
class GameStageMapPage extends StatefulWidget {
  const GameStageMapPage({super.key});
  @override
  State<GameStageMapPage> createState() => _GameStageMapPageState();
}

class _GameStageMapPageState extends State<GameStageMapPage>
    with TickerProviderStateMixin {
  late AnimationController _leafAnimationController;
  late Animation<double> _swayAnimation;
  late Animation<double> _swayAnimationReversed;

  late AnimationController _cloudAnimationController;
  late Animation<Offset> _cloudAnimation1;
  late Animation<Offset> _cloudAnimation2;

  @override
  void initState() {
    super.initState();
    _leafAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    final curvedLeafAnimation = CurvedAnimation(
      parent: _leafAnimationController,
      curve: Curves.easeInOut,
    );
    _swayAnimation = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(curvedLeafAnimation);
    _swayAnimationReversed = Tween<double>(
      begin: 0.2,
      end: -0.2,
    ).animate(curvedLeafAnimation);

    _cloudAnimationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat(reverse: true);

    _cloudAnimation1 = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: const Offset(1.5, 0.0),
    ).animate(_cloudAnimationController);

    _cloudAnimation2 = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: const Offset(-0.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _cloudAnimationController,
        curve: const Interval(0.5, 1.0),
      ),
    );
  }

  @override
  void dispose() {
    _leafAnimationController.dispose();
    _cloudAnimationController.dispose();
    super.dispose();
  }

  Widget _buildLayeredSwayingLeaves({
    required bool isLeft,
    required Animation<double> animation,
  }) {
    const double speedMultiplier1 = 1.0;
    const double speedMultiplier2 = 0.8;
    const double speedMultiplier3 = 0.6;

    return Positioned(
      bottom: -40,
      left: isLeft ? -70 : null,
      right: isLeft ? null : -70,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Transform.rotate(
                  angle: animation.value * speedMultiplier3,
                  alignment: Alignment.bottomCenter,
                  child: Transform.flip(
                    flipX: !isLeft,
                    child: Icon(
                      Icons.eco,
                      color: Colors.green.shade800,
                      size: 290,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: animation.value * speedMultiplier2,
                  alignment: Alignment.bottomCenter,
                  child: Transform.flip(
                    flipX: !isLeft,
                    child: Icon(
                      Icons.eco,
                      color: Colors.green.shade600,
                      size: 270,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: animation.value * speedMultiplier1,
                  alignment: Alignment.bottomCenter,
                  child: Transform.flip(
                    flipX: !isLeft,
                    child: Icon(
                      Icons.eco,
                      color: Color.fromARGB(255, 101, 186, 105),
                      size: 250,
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

  Widget _buildMovingClouds() {
    return Stack(
      children: [
        SlideTransition(
          position: _cloudAnimation1,
          child: Align(
            alignment: const Alignment(-0.8, -0.8),
            child: Icon(
              Icons.cloud,
              color: Colors.white.withOpacity(0.5),
              size: 100,
            ),
          ),
        ),
        SlideTransition(
          position: _cloudAnimation2,
          child: Align(
            alignment: const Alignment(0.8, -0.6),
            child: Icon(
              Icons.cloud_queue,
              color: Colors.white.withOpacity(0.6),
              size: 120,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double bubbleSize = 90.0;
    const double verticalSpacing = 160.0;
    final List<Offset> stageCoordinates = List.generate(
      storyGameStages.length,
      (index) {
        final double x = index.isEven ? screenWidth * 0.75 : screenWidth * 0.25;
        final double y = 180.0 + index * verticalSpacing;
        return Offset(x, y);
      },
    );
    final double mapHeight = 180.0 + (storyGameStages.length) * verticalSpacing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Petualangan Tumbuhan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Chip(
              avatar: Icon(Icons.star, color: Colors.amber.shade800),
              label: Text(
                '${currentUser.points} Poin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.amber.shade100,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 133, 180, 171),
              Color.fromARGB(255, 134, 185, 99),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildMovingClouds(),
            SingleChildScrollView(
              child: SizedBox(
                width: screenWidth,
                height: mapHeight,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(screenWidth, mapHeight),
                      painter: PathPainter(offsets: stageCoordinates),
                    ),
                    ...List.generate(storyGameStages.length, (index) {
                      final stage = storyGameStages[index];
                      final position = stageCoordinates[index];
                      return Positioned(
                        left: position.dx - (bubbleSize / 2),
                        top: position.dy - (bubbleSize / 2),
                        width: bubbleSize,
                        height: bubbleSize,
                        child: _buildStageBubble(context, stage, index),
                      );
                    }),
                  ],
                ),
              ),
            ),
            _buildLayeredSwayingLeaves(isLeft: true, animation: _swayAnimation),
            _buildLayeredSwayingLeaves(
              isLeft: false,
              animation: _swayAnimationReversed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageBubble(
    BuildContext context,
    StoryGameStage stage,
    int index,
  ) {
    return GestureDetector(
      onTap:
          stage.isUnlocked
              ? () async {
                final bool? stageCompleted = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => StoryViewerPage(
                          frames: stage.storyFrames,
                          stageIndex: index,
                        ),
                  ),
                );

                if (stageCompleted == true &&
                    (index + 1) < storyGameStages.length) {
                  setState(() {
                    storyGameStages[index + 1].isUnlocked = true;
                  });
                }
              }
              : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              stage.isUnlocked
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:
                stage.isUnlocked ? Colors.green.shade100 : Colors.grey.shade400,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  stage.isUnlocked
                      ? Colors.green.shade800
                      : Colors.grey.shade600,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child:
                stage.isUnlocked
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stage.subtitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const Icon(Icons.eco, color: Colors.green, size: 30),
                      ],
                    )
                    : Icon(Icons.lock, color: Colors.grey.shade700, size: 40),
          ),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> offsets;
  PathPainter({required this.offsets});
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 90, 64, 43).withOpacity(0.7)
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    if (offsets.isNotEmpty) {
      path.moveTo(offsets.first.dx, offsets.first.dy);
      for (int i = 0; i < offsets.length - 1; i++) {
        final p1 = offsets[i];
        final p2 = offsets[i + 1];
        final controlPoint1 = Offset(p1.dx, (p1.dy + p2.dy) / 2);
        final controlPoint2 = Offset(p2.dx, (p1.dy + p2.dy) / 2);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );
      }
    }

    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final double length = 5.0;
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + length),
          paint,
        );
        distance += 15;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StoryViewerPage extends StatefulWidget {
  final List<StoryFrame> frames;
  final int stageIndex;
  const StoryViewerPage({
    super.key,
    required this.frames,
    required this.stageIndex,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  int _currentFrameIndex = 0;

  void _nextFrame({bool fromCorrectAnswer = false}) {
    bool isLastFrame = _currentFrameIndex >= widget.frames.length - 1;

    if (isLastFrame) {
      if (!fromCorrectAnswer &&
          widget.frames[_currentFrameIndex].quizOptions == null) {
        setState(() => currentUser.points += 0);
      }
      Navigator.of(context).pop(true);
    } else {
      setState(() => _currentFrameIndex++);
    }
  }

  void _handleQuizAnswer(bool isCorrect) {
    if (isCorrect) {
      setState(() => currentUser.points += 10);
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _QuizResultDialog(
            isCorrect: isCorrect,
            points: isCorrect ? 10 : 0,
            onContinue: () {
              Navigator.of(context).pop();
              if (isCorrect) {
                _nextFrame(fromCorrectAnswer: true);
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFrame = widget.frames[_currentFrameIndex];
    final bool isLastFrame = _currentFrameIndex == widget.frames.length - 1;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text('Level ${widget.stageIndex + 1}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- PERUBAHAN UTAMA DI SINI ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize
                            .min, // Membuat Card mengikuti ukuran kontennya
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar sekarang akan terlihat penuh
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          currentFrame.imagePath,
                          fit:
                              BoxFit.contain, // <-- Gambar tidak akan terpotong
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Teks akan mendorong Card ke bawah jika panjang
                      Text(
                        currentFrame.text,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 18, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(), // Mengisi sisa ruang agar Card tidak memenuhi layar
              // ------------------------------------
              if (currentFrame.quizOptions == null)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _nextFrame,
                    icon: Icon(isLastFrame ? Icons.flag : Icons.arrow_forward),
                    label: Text(isLastFrame ? 'Selesai' : 'Lanjut'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                _buildQuizOptions(currentFrame.quizOptions!),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizOptions(List<QuizOption> options) {
    return ListView(
      shrinkWrap: true, // Agar ListView tidak mengambil semua ruang vertikal
      children:
          options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => _handleQuizAnswer(option.isCorrect),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(option.text, textAlign: TextAlign.center),
              ),
            );
          }).toList(),
    );
  }
}

class _QuizResultDialog extends StatefulWidget {
  final bool isCorrect;
  final int points;
  final VoidCallback onContinue;

  const _QuizResultDialog({
    required this.isCorrect,
    required this.points,
    required this.onContinue,
  });

  @override
  State<_QuizResultDialog> createState() => _QuizResultDialogState();
}

class _QuizResultDialogState extends State<_QuizResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.isCorrect ? Icons.star_rounded : Icons.cancel_rounded,
                color: widget.isCorrect ? Colors.orange : Colors.red,
                size: 80,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isCorrect ? "Hebat!" : "Yah, salah...",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isCorrect
                  ? "Jawabanmu benar! Kamu mendapatkan +${widget.points} Poin."
                  : "Jangan menyerah, ya! Coba lagi nanti.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.isCorrect
                        ? const Color.fromARGB(255, 78, 116, 104)
                        : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text("Lanjutkan"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN PERINGKAT (DITAMBAHKAN KEMBALI) ---
class LeaderboardPage extends StatelessWidget {
  final bool showAppBar;
  const LeaderboardPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final List<Player> players = getPlayersWithCurrentUser();
    final topThree = players.take(3).toList();
    final restOfPlayers = players.skip(3).toList();

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Peringkat Siswa')) : null,
      body: Column(
        children: [
          if (showAppBar)
            const SizedBox(height: 10), // Padding if AppBar is shown
          _buildPodium(context, topThree),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8.0),
                itemCount: restOfPlayers.length,
                itemBuilder:
                    (context, index) =>
                        _buildRankItem(context, restOfPlayers[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<Player> topThree) {
    if (topThree.length < 3) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(context, topThree[1], height: 120),
          const SizedBox(width: 10),
          _buildPodiumItem(
            context,
            topThree[0],
            height: 150,
            isFirstPlace: true,
          ),
          const SizedBox(width: 10),
          _buildPodiumItem(context, topThree[2], height: 100),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    Player player, {
    required double height,
    bool isFirstPlace = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: isFirstPlace ? 30 : 25,
          backgroundColor:
              player.isCurrentUser ? Colors.green.shade100 : Colors.grey[300],
          child: const Icon(Icons.person, size: 30, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '${player.points} Points',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: 80,
          decoration: BoxDecoration(
            color: isFirstPlace ? Colors.green.shade300 : Colors.grey[200],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              player.rank.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isFirstPlace ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(BuildContext context, Player player) {
    return Container(
      color: player.isCurrentUser ? Colors.green.shade50 : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[200],
            child: Text(
              player.rank.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${player.points} Points',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN PROFIL ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Ambil Foto (Kamera)'),
                  onTap: () => _getImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () => _getImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child:
                      _profileImage == null
                          ? const CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showImageSourceActionSheet,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              currentUser.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentUser.points} Points',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.games, color: Colors.green.shade700, size: 30),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Ayo naikkan peringkatmu dengan menyelesaikan game-gamenya!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN NOTIFIKASI ---
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  void _markAllAsRead() {
    setState(() => notifications.forEach((n) => n.isRead = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Tandai Semua Dibaca'),
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? const Center(child: Text('Tidak ada notifikasi baru.'))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Container(
                    color: item.isRead ? Colors.white : Colors.green.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.iconColor.withOpacity(0.1),
                        child: Icon(item.icon, color: item.iconColor),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.description),
                      trailing: Text(
                        item.time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => setState(() => item.isRead = true),
                    ),
                  );
                },
              ),
    );
  }
}

// --- HALAMAN PENGATURAN ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Kebijakan Privasi',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.description_outlined,
          title: 'Ketentuan Penggunaan',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
              ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.logout_rounded,
          title: 'Keluar',
          onTap:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text('Lorem ipsum dolor sit amet...'),
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ketentuan Penggunaan')),
      body: const SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text('Dengan menggunakan aplikasi ini, Anda setuju...'),
      ),
    );
  }
}

// --- CLASS CLASSIFIER UNTUK TFLITE ---
class Classifier {
  final Interpreter _interpreter;
  final List<String> _labels;
  final int _inputSize = 224;

  Classifier._(this._interpreter, this._labels);

  static Future<Classifier> create() async {
    final interpreter = await Interpreter.fromAsset(
      'assets/vision-plant.tflite',
    );
    final labelsData = await rootBundle.loadString(
      'assets/aiy_plants_V1_labelmap.csv',
    );

    final labelsList =
        labelsData.split('\n').where((line) => line.isNotEmpty).toList();
    if (labelsList.isNotEmpty &&
        labelsList.first.toLowerCase().contains('id') &&
        labelsList.first.toLowerCase().contains('name')) {
      labelsList.removeAt(0);
    }

    int maxId = 0;
    for (var line in labelsList) {
      final parts = line.split(',');
      if (parts.isNotEmpty) {
        final id = int.tryParse(parts[0].trim());
        if (id != null && id > maxId) {
          maxId = id;
        }
      }
    }

    final labels = List.filled(maxId + 1, 'Unknown');
    for (var line in labelsList) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        final id = int.tryParse(parts[0].trim());
        final name = parts.sublist(1).join(',').trim().replaceAll('"', '');
        if (id != null && id >= 0 && id < labels.length) {
          labels[id] = name;
        }
      }
    }

    return Classifier._(interpreter, labels);
  }

  Future<Map<String, double>> predict(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return {};

    img.Image resizedImage = img.copyResize(
      originalImage,
      width: _inputSize,
      height: _inputSize,
    );

    var input = Uint8List(1 * _inputSize * _inputSize * 3);
    int pixelIndex = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        var pixel = resizedImage.getPixel(x, y);
        input[pixelIndex++] = pixel.r.toInt();
        input[pixelIndex++] = pixel.g.toInt();
        input[pixelIndex++] = pixel.b.toInt();
      }
    }
    final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);

    var output = List.filled(
      1 * _labels.length,
      0,
    ).reshape([1, _labels.length]);

    _interpreter.run(inputTensor, output);

    final resultsRaw = output[0] as List<dynamic>;
    final results = <String, double>{};

    for (int i = 0; i < resultsRaw.length; i++) {
      var currentScore = (resultsRaw[i] as num).toDouble() / 255.0;
      if (i < _labels.length) {
        results[_labels[i]] = currentScore;
      }
    }

    return results;
  }

  void close() => _interpreter.close();
}
