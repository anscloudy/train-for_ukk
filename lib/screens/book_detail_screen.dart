import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final bool readOnly;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.readOnly = false,
    this.onEdit,
    this.onDelete,
    this.onRefresh,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Map<String, dynamic> _book;

  @override
  void initState() {
    super.initState();
    _book = Map<String, dynamic>.from(widget.book);
  }

  Future<void> _borrowBook() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final userId = prefs.getInt('userId');

    if (role != 'anggota') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya anggota yang dapat meminjam')),
      );
      return;
    }

    if ((_book['stock'] as int) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok buku habis')),
      );
      return;
    }

    final now = DateTime.now();
    final due = now.add(const Duration(days: 7));

    // Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Judul: ${_book['title']}'),
            Text('Pengarang: ${_book['author']}'),
            const SizedBox(height: 12),
            Text('Tanggal Pinjam: ${DateFormat('dd/MM/yyyy').format(now)}'),
            Text('Jatuh Tempo: ${DateFormat('dd/MM/yyyy').format(due)}'),
            const SizedBox(height: 12),
            const Text(
              'Durasi peminjaman: 7 hari',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Text(
              'Denda keterlambatan: Rp 1.000/hari',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4F3A),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pinjam', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Ambil member ID — untuk demo, user id 2 = member 1
    int memberId = 1;
    if (userId != null) {
      // Coba cari member dengan nama yang cocok, atau default 1
      final members = await DatabaseService.getMembers();
      if (userId == 2 && members.isNotEmpty) {
        memberId = members.first['id'] as int;
      }
    }

    await DatabaseService.borrowBook(
      bookId: _book['id'] as int,
      memberId: memberId,
      borrowDate: now,
      dueDate: due,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil meminjam "${_book['title']}"'),
        backgroundColor: Colors.green,
      ),
    );

    // Refresh stok
    final updated = await DatabaseService.getBook(_book['id'] as int);
    if (updated != null && mounted) {
      setState(() => _book = updated);
    }
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        title: Text(_book['title'] ?? 'Detail Buku'),
        backgroundColor: const Color(0xFF6B4F3A),
        foregroundColor: Colors.white,
        actions: [
          if (!widget.readOnly && widget.onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
          if (!widget.readOnly && widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============ COVER ============
                  Container(
                    width: isMobile ? double.infinity : 300,
                    height: 400,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A3428), Color(0xFF6B4F3A), Color(0xFFA67B5B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, size: 120, color: Colors.white),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _book['title'] ?? '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _book['author'] ?? '-',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isMobile ? 0 : 32, height: isMobile ? 24 : 0),

                  // ============ INFO ============
                  Expanded(
                    flex: isMobile ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA67B5B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _book['category'] ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _book['title'] ?? '-',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A3428),
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              _book['author'] ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),

                        // Detail info
                        _infoRow('Penerbit', _book['publisher'] ?? '-'),
                        _infoRow('Tahun Terbit', '${_book['year'] ?? '-'}'),
                        _infoRow('Kategori', _book['category'] ?? '-'),
                        _infoRow('Lokasi Rak', _book['shelf'] ?? '-'),
                        _infoRow(
                          'Stok Tersedia',
                          '${_book['stock'] ?? 0} buku',
                          highlight: true,
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A3428),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _book['desc'] ?? 'Tidak ada deskripsi.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ============ ACTION BUTTONS ============
                        if (widget.readOnly) ...[
                          // Tombol pinjam untuk anggota
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: (_book['stock'] as int) > 0
                                  ? _borrowBook
                                  : null,
                              icon: const Icon(Icons.book),
                              label: Text(
                                (_book['stock'] as int) > 0
                                    ? 'PINJAM BUKU INI'
                                    : 'STOK HABIS',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B4F3A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Peminjaman selama 7 hari. Denda Rp 1.000/hari jika terlambat.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Tombol untuk petugas
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onEdit?.call();
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF6B4F3A),
                                    side: const BorderSide(color: Color(0xFF6B4F3A)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    widget.onDelete?.call();
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Hapus'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: highlight ? const Color(0xFF6B4F3A) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}