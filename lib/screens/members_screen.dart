import 'package:flutter/material.dart';
import '../services/database_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await DatabaseService.getMembers();
    if (!mounted) return;
    setState(() => _members = res);
  }

  Future<void> _addOrEdit([Map<String, dynamic>? m]) async {
    final name = TextEditingController(text: m?['name']);
    final email = TextEditingController(text: m?['email']);
    final phone = TextEditingController(text: m?['phone']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(m == null ? 'Tambah Anggota' : 'Edit Anggota'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Telepon'),
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
              if (name.text.isEmpty) return;
              final data = {
                'name': name.text,
                'email': email.text,
                'phone': phone.text,
              };
              if (m == null) {
                await DatabaseService.addMember(data);
              } else {
                data['id'] = m['id'];
                await DatabaseService.updateMember(data);
              }
              if (mounted) Navigator.pop(context);
              _load();
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
        title: const Text('Hapus Anggota'),
        content: const Text('Yakin ingin menghapus anggota ini?'),
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
      await DatabaseService.deleteMember(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Anggota'),
        backgroundColor: const Color(0xFF6B4F3A),
        foregroundColor: Colors.white,
      ),
      body: _members.isEmpty
          ? const Center(child: Text('Belum ada anggota'))
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (_, i) {
                final m = _members[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6B4F3A),
                      child: Text(
                        (m['name'] ?? '?').toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(m['name'] ?? '-'),
                    subtitle: Text('${m['email']} | ${m['phone']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEdit(m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(m['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        backgroundColor: const Color(0xFF6B4F3A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}