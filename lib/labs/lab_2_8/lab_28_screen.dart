import 'package:flutter/material.dart';

import 'db_service.dart';

/// Лабораторная работа №2.8 — SQLite: CRUD-операции с таблицей записей.
class Lab28Screen extends StatefulWidget {
  const Lab28Screen({super.key});

  @override
  State<Lab28Screen> createState() => _Lab28ScreenState();
}

class _Lab28ScreenState extends State<Lab28Screen> {
  final DBService dbService = DBService();
  List<Map<String, dynamic>> records = [];

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Получение всех записей
  Future<void> _fetchRecords() async {
    final data = await dbService.getAllRecords();
    setState(() {
      records = data;
    });
  }

  // Сортировка по имени
  Future<void> _sortRecords() async {
    final data = await dbService.getSortedRecords();
    setState(() {
      records = data;
    });
  }

  // Добавление записи
  Future<void> _addRecord() async {
    if (_nameController.text.isNotEmpty) {
      await dbService.addRecord(_nameController.text);
      _nameController.clear();
      await _fetchRecords();
    }
  }

  // Редактирование записи
  Future<void> _updateRecord(int id, String currentName) async {
    final editController = TextEditingController(text: currentName);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Редактировать запись'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Введите новое имя',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отменить'),
          ),
          TextButton(
            onPressed: () async {
              if (editController.text.isNotEmpty) {
                await dbService.updateRecord(id, editController.text);
                await _fetchRecords();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  // Удаление записи
  Future<void> _deleteRecord(int id) async {
    await dbService.deleteRecord(id);
    await _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №2.8')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Введите имя',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _addRecord,
                child: const Text('Добавить запись'),
              ),
              ElevatedButton(
                onPressed: _sortRecords,
                child: const Text('Сортировка по имени'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  title: Text(record['name'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        // Передаём ID и имя
                        onPressed: () =>
                            _updateRecord(record['id'] as int, record['name'] as String),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteRecord(record['id'] as int),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
