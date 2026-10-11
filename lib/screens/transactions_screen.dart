import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class TransactionsScreen extends StatefulWidget {
  final bool memberView;
  const TransactionsScreen({super.key, this.memberView = false});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> _trx = [];
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final role = prefs.getString('role');

    // Fix: filter untuk anggota, tampilkan semua untuk petugas
    int? filterMemberId;
    if (role == 'anggota') {
      final members = await DatabaseService.getMembers();
      if (members.isNotEmpty) {
        filterMemberId = members.first['id'] as int;
      }
    }

    final trx = await DatabaseService.getTransactions(memberId: filterMemberId);
    final books = await DatabaseService.getBooks();
    final members = await DatabaseService.getMembers();

    if (!mounted) return;
    setState(() {
      _trx = trx;
      _books = books;
      _members = members;
      _loading = false;
    });
  }

  Future<void> _borrow() async {
    if (_books.isEmpty || _members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data buku atau anggota kosong')),
      );
      return;
    }

    int? bookId;
    // Pilih buku yang stoknya > 0
    final available = _books.where((b) => (b['stock'] as int) > 0).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua buku stok habis')),
      );
      return;
    }
    bookId = available.first['id'];
    int? memberId = _members.first['id'];
    final now = DateTime.now();
    final due = now.add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pinjam Buku'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: bookId,
                  isExpanded: true,
                  items: available
                      .map((b) => DropdownMenuItem(
                            value: b['id'] as int,
                            child: Text(
                              '${b['title']} (Stok: ${b['stock']})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => bookId = v),
                  decoration: const InputDecoration(labelText: 'Buku'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: memberId,
                  isExpanded: true,
                  items: _members
                      .map((m) => DropdownMenuItem(
                            value: m['id'] as int,
                            child: Text(m['name']),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => memberId = v),
                  decoration: const InputDecoration(labelText: 'Anggota'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pinjam: ${DateFormat('dd/MM/yyyy').format(now)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Jatuh tempo: ${DateFormat('dd/MM/yyyy').format(due)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Text(
                        'Denda: Rp 1.000/hari',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4F3A),
              ),
              onPressed: () async {
                final book = await DatabaseService.getBook(bookId!);
                if (book == null || (book['stock'] as int) <= 0) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stok habis')),
                    );
                  }
                  return;
                }
                await DatabaseService.borrowBook(
                  bookId: bookId!,
                  memberId: memberId!,
                  borrowDate: now,
                  dueDate: due,
                );
                if (mounted) Navigator.pop(context);
                _load();
              },
              child: const Text('Pinjam', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _return(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kembalikan Buku'),
        content: const Text('Konfirmasi pengembalian buku ini?'),
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
            child: const Text('Kembalikan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.returnBook(id, DateTime.now());
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memberView ? 'Riwayat Peminjaman' : 'Transaksi'),
        backgroundColor: const Color(0xFF6B4F3A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trx.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.black26),
                      SizedBox(height: 16),
                      Text('Belum ada transaksi',
                          style: TextStyle(color: Colors.black45)),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _trx.length,
                      itemBuilder: (_, i) {
                        final t = _trx[i];
                        return _trxCard(t, isMobile);
                      },
                    ),
                  ),
                ),
      floatingActionButton: !widget.memberView
          ? FloatingActionButton.extended(
              onPressed: _borrow,
              backgroundColor: const Color(0xFF6B4F3A),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Pinjam Buku',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _trxCard(Map<String, dynamic> t, bool isMobile) {
    final due = DateTime.parse(t['due_date']);
    final isLate = DateTime.now().isAfter(due) && t['status'] == 'dipinjam';
    final isReturned = t['status'] == 'kembali';

    Color statusColor;
    String statusText;
    if (isReturned) {
      statusColor = Colors.green;
      statusText = 'KEMBALI';
    } else if (isLate) {
      statusColor = Colors.red;
      statusText = 'TERLAMBAT';
    } else {
      statusColor = Colors.orange;
      statusText = 'DIPINJAM';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['book_title'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4A3428),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Anggota: ${t['member_name']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Tanggal info
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  child: _dateInfo(
                    'Tanggal Pinjam',
                    DateTime.parse(t['borrow_date']),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _dateInfo(
                    'Jatuh Tempo',
                    due,
                    Icons.event,
                    color: isLate ? Colors.red : null,
                  ),
                ),
                if (isReturned)
                  Expanded(
                    child: _dateInfo(
                      'Dikembalikan',
                      DateTime.parse(t['return_date']),
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            if ((t['fine'] as int) > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Denda: Rp ${t['fine']}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!widget.memberView && t['status'] == 'dipinjam') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _return(t['id']),
                  icon: const Icon(Icons.check),
                  label: const Text('KEMBALIKAN BUKU'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4F3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dateInfo(String label, DateTime date, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.black45),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}