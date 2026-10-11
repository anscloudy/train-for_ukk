import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'books_screen.dart';
import 'members_screen.dart';
import 'transactions_screen.dart';
import 'reports_screen.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _featured = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  Future<void> _loadFeatured() async {
    final books = await DatabaseService.getBooks();
    if (!mounted) return;
    setState(() {
      _featured = books.take(6).toList();
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // HANYA hapus key sesi, JANGAN clear() semua!
    await prefs.remove('isLoggedIn');
    await prefs.remove('role');
    await prefs.remove('userId');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPetugas = widget.role == 'petugas';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ============ HERO ============
                Container(
                  height: isMobile ? 500 : 550,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A3428),
                        Color(0xFF6B4F3A),
                        Color(0xFFA67B5B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book,
                              size: 72, color: Colors.white),
                          const SizedBox(height: 20),
                          Text(
                            'PEMINJAMAN BUKU',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: isMobile ? 2 : 4,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 80,
                            height: 3,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Selamat Datang, ${isPetugas ? 'Petugas' : 'Anggota'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistem Informasi Perpustakaan Sekolah',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 36),
                        ],
                      ),
                    ),
                  ),
                ),

                // ============ KATALOG ============
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 60,
                    vertical: isMobile ? 48 : 80,
                  ),
                  color: const Color(0xFFF5EFE6),
                  child: Column(
                    children: [
                      const Text(
                        'KATALOG BUKU',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 6,
                          color: Color(0xFFA67B5B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Koleksi Buku Terbaik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 26 : 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A3428),
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 100,
                        height: 3,
                        color: const Color(0xFF6B4F3A),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: const Text(
                          'Temukan berbagai koleksi buku dari penulis-penulis terkenal Indonesia seperti Pramoedya Ananta Toer, Andrea Hirata, Tere Liye, Dewi Lestari, dan Eka Kurniawan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ============ FEATURED GRID ============
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 40,
                    vertical: 20,
                  ),
                  color: const Color(0xFFF5EFE6),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int cols = 1;
                            if (constraints.maxWidth > 1200) {
                              cols = 3;
                            } else if (constraints.maxWidth > 800) {
                              cols = 2;
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _featured.length,
                              itemBuilder: (_, i) => _bookCard(_featured[i]),
                            );
                          },
                        ),
                ),

                // ============ MENU ============
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 48 : 80,
                    horizontal: isMobile ? 16 : 40,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Text(
                        'MENU UTAMA',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 6,
                          color: Color(0xFFA67B5B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPetugas ? 'Panel Petugas' : 'Panel Anggota',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A3428),
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          if (isPetugas) ...[
                            _menuCard(context, 'Kelola Buku',
                                Icons.library_books, const BooksScreen()),
                            _menuCard(context, 'Kelola Anggota', Icons.people,
                                const MembersScreen()),
                            _menuCard(context, 'Transaksi', Icons.swap_horiz,
                                const TransactionsScreen()),
                            _menuCard(context, 'Laporan', Icons.bar_chart,
                                const ReportsScreen()),
                          ] else ...[
                            _menuCard(context, 'Katalog Buku', Icons.search,
                                const BooksScreen(readOnly: true)),
                            _menuCard(
                                context,
                                'Riwayat Peminjaman',
                                Icons.history,
                                const TransactionsScreen(memberView: true)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ============ FOOTER ============
                Container(
                  padding: const EdgeInsets.all(40),
                  color: const Color(0xFF4A3428),
                  child: const Column(
                    children: [
                      Icon(Icons.menu_book, color: Colors.white, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'Sistem Informasi Perpustakaan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '© 2026 UKK Rekayasa Perangkat Lunak',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ============ FLOATING TOP BAR ============
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Peminjaman Buku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookCard(Map<String, dynamic> b) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BooksScreen(readOnly: true),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B4F3A), Color(0xFFA67B5B)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        b['category'] ?? '-',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b['title'] ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4A3428),
                      ),
                    ),
                    Text(
                      b['author'] ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (b['stock'] as int) > 0
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Stok: ${b['stock']}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: (b['stock'] as int) > 0
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                        Text(
                          'Rak ${b['shelf']}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
      BuildContext context, String title, IconData icon, Widget page) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final size = isMobile ? 160.0 : 220.0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFE6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFA67B5B).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMobile ? 36 : 48, color: const Color(0xFF6B4F3A)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3428),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}