import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'book_detail_screen.dart';

class BooksScreen extends StatefulWidget {
  final bool readOnly;
  const BooksScreen({super.key, this.readOnly = false});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Map<String, dynamic>> _books = [];
  List<String> _categories = [];
  String _selectedCategory = 'Semua';
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _load();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService.getCategories();
    if (!mounted) return;
    setState(() => _categories = cats);
  }

  Future<void> _load() async {
    final res = await DatabaseService.getBooks(
      search: _search.text,
      category: _selectedCategory,
    );
    if (!mounted) return;
    setState(() => _books = res);
  }

  Future<void> _addOrEdit([Map<String, dynamic>? book]) async {
    final title = TextEditingController(text: book?['title']);
    final author = TextEditingController(text: book?['author']);
    final publisher = TextEditingController(text: book?['publisher']);
    final category = TextEditingController(text: book?['category']);
    final stock = TextEditingController(text: book?['stock']?.toString());
    final shelf = TextEditingController(text: book?['shelf']);
    final year = TextEditingController(text: book?['year']?.toString());
    final desc = TextEditingController(text: book?['desc']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(book == null ? 'Tambah Buku' : 'Edit Buku'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: author,
                  decoration: const InputDecoration(labelText: 'Pengarang'),
                ),
                TextField(
                  controller: publisher,
                  decoration: const InputDecoration(labelText: 'Penerbit'),
                ),
                TextField(
                  controller: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                TextField(
                  controller: stock,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: shelf,
                  decoration: const InputDecoration(labelText: 'Rak'),
                ),
                TextField(
                  controller: year,
                  decoration: const InputDecoration(labelText: 'Tahun'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: desc,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
              ],
            ),
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
              if (title.text.isEmpty) return;
              final data = {
                'title': title.text,
                'author': author.text,
                'publisher': publisher.text,
                'category': category.text,
                'stock': int.tryParse(stock.text) ?? 0,
                'shelf': shelf.text,
                'year': int.tryParse(year.text) ?? 0,
                'desc': desc.text,
              };
              if (book == null) {
                await DatabaseService.addBook(data);
              } else {
                data['id'] = book['id'];
                await DatabaseService.updateBook(data);
              }
              if (mounted) Navigator.pop(context);
              _load();
              _loadCategories();
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: const Text('Yakin ingin menghapus buku ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.deleteBook(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Katalog Buku' : 'Kelola Buku'),
        backgroundColor: const Color(0xFF6B4F3A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ============ FILTER BAR ============
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5EFE6),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau pengarang...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          _load();
                        },
                        selectedColor: const Color(0xFF6B4F3A),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF4A3428),
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: const Color(0xFFA67B5B).withOpacity(0.3)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ============ BOOK GRID ============
          Expanded(
            child: _books.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.black26),
                        SizedBox(height: 16),
                        Text('Belum ada buku', style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Hitung kolom berdasarkan lebar
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 1400) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 1000) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 2;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: isMobile ? 0.85 : 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _books.length,
                        itemBuilder: (_, i) {
                          final b = _books[i];
                          return _bookGridCard(b);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton(
              onPressed: () => _addOrEdit(),
              backgroundColor: const Color(0xFF6B4F3A),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _bookGridCard(Map<String, dynamic> b) {
    final stock = (b['stock'] as int?) ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(
              book: b,
              readOnly: widget.readOnly,
              onEdit: () => _addOrEdit(b),
              onDelete: () => _delete(b['id']),
              onRefresh: _load,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover (gradient)
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B4F3A), Color(0xFFA67B5B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 4),
                  Text(
                    b['author'] ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: stock > 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stok: $stock',
                          style: TextStyle(
                            fontSize: 11,
                            color: stock > 0 ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
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