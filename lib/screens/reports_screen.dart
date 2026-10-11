import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _popular = [];
  int _totalTrx = 0;
  int _totalBooks = 0;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final popular = await DatabaseService.getPopularBooks();
    final totalTrx = await DatabaseService.getTotalTransactions();
    final books = await DatabaseService.getBooks();
    final members = await DatabaseService.getMembers();

    if (!mounted) return;
    setState(() {
      _popular = popular;
      _totalTrx = totalTrx;
      _totalBooks = books.length;
      _totalMembers = members.length;
    });
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: const Color(0xFF6B4F3A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Perpustakaan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 200,
                  child: _statCard(
                    'Total Transaksi',
                    '$_totalTrx',
                    Icons.swap_horiz,
                    const Color(0xFF6B4F3A),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _statCard(
                    'Total Buku',
                    '$_totalBooks',
                    Icons.library_books,
                    Colors.orange,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _statCard(
                    'Total Anggota',
                    '$_totalMembers',
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Buku Terfavorit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _popular.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Belum ada data peminjaman'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _popular.length,
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: i == 0
                              ? Colors.amber
                              : i == 1
                                  ? Colors.grey
                                  : i == 2
                                      ? Colors.brown
                                      : const Color(0xFF6B4F3A),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_popular[i]['title'] ?? '-'),
                        trailing: Text(
                          '${_popular[i]['count']}x dipinjam',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B4F3A),
                          ),
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