import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static SharedPreferences? _prefs;

  static Future<void> initDB() async {
    _prefs ??= await SharedPreferences.getInstance();

    // ==== EARLY RETURN: kalau data sudah lengkap, tidak perlu seed ====
    final hasUsers = _prefs!.containsKey('users');
    final hasBooks = _prefs!.containsKey('books');
    if (hasUsers && hasBooks) {
      return;
    }

    // ============ SEED USERS ============
    if (!_prefs!.containsKey('users')) {
      await _saveList('users', [
        {'id': 1, 'username': 'petugas', 'password': '123', 'role': 'petugas'},
        {'id': 2, 'username': 'anggota', 'password': '123', 'role': 'anggota'},
      ]);
    }

    // ============ SEED BOOKS (17 buku) ============
    if (!_prefs!.containsKey('books')) {
      await _saveList('books', [
        // 1. Pramoedya Ananta Toer
        {'id': 1, 'title': 'Bumi Manusia', 'author': 'Pramoedya Ananta Toer', 'publisher': 'Hasta Mitra', 'category': 'Sejarah', 'stock': 5, 'shelf': 'A1', 'year': 1980, 'desc': 'Kisah Minke di era kolonial, kritik sosial yang mendalam.'},
        {'id': 2, 'title': 'Anak Semua Bangsa', 'author': 'Pramoedya Ananta Toer', 'publisher': 'Hasta Mitra', 'category': 'Sejarah', 'stock': 4, 'shelf': 'A1', 'year': 1981, 'desc': 'Lanjutan Bumi Manusia, Minke menghadapi realitas kolonial.'},
        {'id': 3, 'title': 'Perburuan', 'author': 'Pramoedya Ananta Toer', 'publisher': 'Balai Pustaka', 'category': 'Novel', 'stock': 3, 'shelf': 'A2', 'year': 1950, 'desc': 'Karya awal Pramoedya, kisah perjuangan di masa pendudukan Jepang.'},

        // 2. Andrea Hirata
        {'id': 4, 'title': 'Laskar Pelangi', 'author': 'Andrea Hirata', 'publisher': 'Bentang Pustaka', 'category': 'Inspiratif', 'stock': 8, 'shelf': 'B1', 'year': 2005, 'desc': 'Kisah 10 anak Belitung mengejar pendidikan dengan keterbatasan.'},
        {'id': 5, 'title': 'Sang Pemimpi', 'author': 'Andrea Hirata', 'publisher': 'Bentang Pustaka', 'category': 'Inspiratif', 'stock': 6, 'shelf': 'B1', 'year': 2006, 'desc': 'Perjalanan Ikal dan Arai mengejar mimpi ke Prancis.'},
        {'id': 6, 'title': 'Edensor', 'author': 'Andrea Hirata', 'publisher': 'Bentang Pustaka', 'category': 'Inspiratif', 'stock': 5, 'shelf': 'B2', 'year': 2007, 'desc': 'Petualangan Ikal menuntut ilmu di Eropa.'},

        // 3. Tere Liye
        {'id': 7, 'title': 'Hujan', 'author': 'Tere Liye', 'publisher': 'Gramedia', 'category': 'Fiksi Ilmiah', 'stock': 7, 'shelf': 'C1', 'year': 2016, 'desc': 'Kisah cinta Lail dan Esok di dunia masa depan.'},
        {'id': 8, 'title': 'Rindu', 'author': 'Tere Liye', 'publisher': 'Republika', 'category': 'Religi', 'stock': 5, 'shelf': 'C1', 'year': 2014, 'desc': 'Perjalanan haji yang penuh makna dan haru.'},
        {'id': 9, 'title': 'Pulang', 'author': 'Tere Liye', 'publisher': 'Republika', 'category': 'Aksi', 'stock': 6, 'shelf': 'C2', 'year': 2015, 'desc': 'Bujang, pemuda desa yang menjadi bagian dunia gelap.'},
        {'id': 10, 'title': 'Tentang Kamu', 'author': 'Tere Liye', 'publisher': 'Republika', 'category': 'Drama', 'stock': 4, 'shelf': 'C2', 'year': 2016, 'desc': 'Kisah hidup Sri Ningsih yang penuh liku.'},

        // 4. Dewi Lestari
        {'id': 11, 'title': 'Supernova: Ksatria, Puteri, dan Bintang Jatuh', 'author': 'Dewi Lestari', 'publisher': 'Truedee Books', 'category': 'Fiksi Ilmiah', 'stock': 5, 'shelf': 'D1', 'year': 2001, 'desc': 'Novel pembuka seri Supernova, sains dan spiritualitas.'},
        {'id': 12, 'title': 'Filosofi Kopi', 'author': 'Dewi Lestari', 'publisher': 'Truedee Books', 'category': 'Kumpulan Cerpen', 'stock': 6, 'shelf': 'D1', 'year': 2006, 'desc': 'Kumpulan cerita pendek yang puitis dan penuh makna.'},
        {'id': 13, 'title': 'Perahu Kertas', 'author': 'Dewi Lestari', 'publisher': 'Bentang Pustaka', 'category': 'Romansa', 'stock': 7, 'shelf': 'D2', 'year': 2009, 'desc': 'Kisah Kugy dan Keenan mengejar mimpi dan cinta.'},
        {'id': 14, 'title': 'Aroma Karsa', 'author': 'Dewi Lestari', 'publisher': 'Bentang Pustaka', 'category': 'Thriller', 'stock': 4, 'shelf': 'D2', 'year': 2018, 'desc': 'Pencarian aroma langka yang membawa pada misteri.'},

        // 5. Eka Kurniawan
        {'id': 15, 'title': 'Cantik Itu Luka', 'author': 'Eka Kurniawan', 'publisher': 'Gramedia', 'category': 'Realisme Magis', 'stock': 5, 'shelf': 'E1', 'year': 2002, 'desc': 'Kisah Dewi Ayu, tragedi dan sejarah Indonesia.'},
        {'id': 16, 'title': 'Lelaki Harimau', 'author': 'Eka Kurniawan', 'publisher': 'Gramedia', 'category': 'Realisme Magis', 'stock': 4, 'shelf': 'E1', 'year': 2004, 'desc': 'Misteri kematian dan transformasi di sebuah desa.'},
        {'id': 17, 'title': 'Seperti Dendam, Rindu Harus Dibayar Tuntas', 'author': 'Eka Kurniawan', 'publisher': 'Gramedia', 'category': 'Realisme Magis', 'stock': 3, 'shelf': 'E2', 'year': 2014, 'desc': 'Kisah Ajo Kawir dan dendam yang membara.'},
      ]);
    }

    // ============ SEED MEMBERS ============
    if (!_prefs!.containsKey('members')) {
      await _saveList('members', [
        {'id': 1, 'name': 'Budi Santoso', 'email': 'budi@mail.com', 'phone': '08123456789'},
        {'id': 2, 'name': 'Siti Aminah', 'email': 'siti@mail.com', 'phone': '08129876543'},
      ]);
    }

    if (!_prefs!.containsKey('transactions')) {
      await _saveList('transactions', []);
    }
  }

  // ===================== GENERIC =====================
  static List<Map<String, dynamic>> _getList(String key) {
    final raw = _prefs!.getString(key);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  static Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    await _prefs!.setString(key, jsonEncode(list));
  }

  static int _nextId(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return 1;
    return (list.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  }

  // ===================== BOOKS =====================
  static Future<List<Map<String, dynamic>>> getBooks({String? search, String? category}) async {
    var list = _getList('books');
    if (search != null && search.isNotEmpty) {
      list = list.where((b) =>
        (b['title'] as String).toLowerCase().contains(search.toLowerCase()) ||
        (b['author'] as String).toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    if (category != null && category.isNotEmpty && category != 'Semua') {
      list = list.where((b) => b['category'] == category).toList();
    }
    return list;
  }

  static Future<List<String>> getCategories() async {
    final list = _getList('books');
    final set = <String>{'Semua'};
    for (final b in list) {
      set.add(b['category'] as String);
    }
    return set.toList();
  }

  static Future<void> addBook(Map<String, dynamic> book) async {
    final list = _getList('books');
    book['id'] = _nextId(list);
    list.add(book);
    await _saveList('books', list);
  }

  static Future<void> updateBook(Map<String, dynamic> book) async {
    final list = _getList('books');
    final idx = list.indexWhere((b) => b['id'] == book['id']);
    if (idx != -1) list[idx] = book;
    await _saveList('books', list);
  }

  static Future<void> deleteBook(int id) async {
    final list = _getList('books');
    list.removeWhere((b) => b['id'] == id);
    await _saveList('books', list);
  }

  static Future<Map<String, dynamic>?> getBook(int id) async {
    final list = _getList('books');
    try {
      return list.firstWhere((b) => b['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // ===================== MEMBERS =====================
  static Future<List<Map<String, dynamic>>> getMembers() async => _getList('members');

  static Future<void> addMember(Map<String, dynamic> m) async {
    final list = _getList('members');
    m['id'] = _nextId(list);
    list.add(m);
    await _saveList('members', list);
  }

  static Future<void> updateMember(Map<String, dynamic> m) async {
    final list = _getList('members');
    final idx = list.indexWhere((e) => e['id'] == m['id']);
    if (idx != -1) list[idx] = m;
    await _saveList('members', list);
  }

  static Future<void> deleteMember(int id) async {
    final list = _getList('members');
    list.removeWhere((e) => e['id'] == id);
    await _saveList('members', list);
  }

  // ===================== USERS =====================
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final list = _getList('users');
    try {
      return list.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> register(String username, String password) async {
    final list = _getList('users');
    if (list.any((u) => u['username'] == username)) return false;
    list.add({
      'id': _nextId(list),
      'username': username,
      'password': password,
      'role': 'anggota',
    });
    await _saveList('users', list);
    return true;
  }

  // ===================== TRANSACTIONS =====================
  static Future<List<Map<String, dynamic>>> getTransactions({int? memberId}) async {
    var list = _getList('transactions');
    if (memberId != null) {
      list = list.where((t) => t['member_id'] == memberId).toList();
    }
    final books = _getList('books');
    final members = _getList('members');
    return list.reversed.map((t) {
      final b = books.firstWhere((e) => e['id'] == t['book_id'], orElse: () => {});
      final m = members.firstWhere((e) => e['id'] == t['member_id'], orElse: () => {});
      return {
        ...t,
        'book_title': b['title'] ?? '-',
        'member_name': m['name'] ?? '-',
      };
    }).toList();
  }

  static Future<void> borrowBook({
    required int bookId,
    required int memberId,
    required DateTime borrowDate,
    required DateTime dueDate,
  }) async {
    final list = _getList('transactions');
    list.add({
      'id': _nextId(list),
      'book_id': bookId,
      'member_id': memberId,
      'borrow_date': borrowDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'return_date': null,
      'fine': 0,
      'status': 'dipinjam',
    });
    await _saveList('transactions', list);

    final books = _getList('books');
    final idx = books.indexWhere((b) => b['id'] == bookId);
    if (idx != -1) books[idx]['stock'] = (books[idx]['stock'] as int) - 1;
    await _saveList('books', books);
  }

  static Future<void> returnBook(int transactionId, DateTime returnDate) async {
    final list = _getList('transactions');
    final idx = list.indexWhere((t) => t['id'] == transactionId);
    if (idx == -1) return;

    final dueDate = DateTime.parse(list[idx]['due_date']);
    int fine = 0;
    if (returnDate.isAfter(dueDate)) {
      fine = returnDate.difference(dueDate).inDays * 1000;
    }

    final bookId = list[idx]['book_id'];
    list[idx]['return_date'] = returnDate.toIso8601String();
    list[idx]['fine'] = fine;
    list[idx]['status'] = 'kembali';
    await _saveList('transactions', list);

    final books = _getList('books');
    final bIdx = books.indexWhere((b) => b['id'] == bookId);
    if (bIdx != -1) books[bIdx]['stock'] = (books[bIdx]['stock'] as int) + 1;
    await _saveList('books', books);
  }

  // ===================== REPORTS =====================
  static Future<int> getTotalTransactions() async {
    return _getList('transactions').length;
  }

  static Future<List<Map<String, dynamic>>> getPopularBooks() async {
    final transactions = _getList('transactions');
    final books = _getList('books');
    final counter = <int, int>{};
    for (final t in transactions) {
      final id = t['book_id'] as int;
      counter[id] = (counter[id] ?? 0) + 1;
    }
    final sorted = counter.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) {
      final b = books.firstWhere((bk) => bk['id'] == e.key, orElse: () => {});
      return {'title': b['title'] ?? '-', 'count': e.value};
    }).toList();
  }

  // ===================== RESET =====================
  static Future<void> resetAll() async {
    await _prefs!.clear();
    await initDB();
  }
}