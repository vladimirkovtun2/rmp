import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Лабораторная работа №2.7 — работа с файлами (file_picker по методичке):
/// выбор файла/папки, сохранение файла, очистка временных файлов,
/// обработка ошибок через SnackBar.
///
/// Примечание: сниппеты методички написаны под file_picker 8.x; в проекте
/// 13.x — API сузился: нет множественного выбора и lockParentWindow,
/// saveFile требует байты и возвращает Uri, clearTemporaryFiles — void.
class Lab27Screen extends StatefulWidget {
  const Lab27Screen({super.key});

  @override
  State<Lab27Screen> createState() => _Lab27ScreenState();
}

class _Lab27ScreenState extends State<Lab27Screen> {
  final _defaultFileNameController = TextEditingController();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  final _fileExtensionController = TextEditingController();

  String? _saveAsFileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _isLoading = false;
  bool _userAborted = false;
  FileType _pickingType = FileType.any;

  @override
  void initState() {
    super.initState();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
  }

  @override
  void dispose() {
    _defaultFileNameController.dispose();
    _dialogTitleController.dispose();
    _initialDirectoryController.dispose();
    _fileExtensionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    _resetState();
    try {
      _directoryPath = null;
      _paths = await FilePicker.pickFiles(
        compressionQuality: 30,
        type: _pickingType,
        onFileLoading: (FilePickerStatus status) => debugPrint('$status'),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
      );
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      // Отмена — пустой список
      _userAborted = _paths == null || _paths!.isEmpty;
    });
  }

  Future<void> _clearCachedFiles() async {
    _resetState();
    try {
      await FilePicker.clearTemporaryFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Temporary files removed.')),
        );
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectFolder() async {
    _resetState();
    try {
      final path = await FilePicker.getDirectoryPath(
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
      );
      setState(() {
        _directoryPath = path;
        _userAborted = path == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFile() async {
    _resetState();
    try {
      // Сохраняем небольшой текстовый файл с именем из поля конфигурации
      final name = _defaultFileNameController.text.trim().isEmpty
          ? 'file.txt'
          : _defaultFileNameController.text.trim();
      final uri = await FilePicker.saveFile(
        fileName: name,
        bytes: utf8.encode('Hello from rmp_9plus!\n'),
        mimeType: 'text/plain',
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
      );
      setState(() {
        _saveAsFileName = uri?.toString();
        _userAborted = uri == null;
      });
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logException(String message) {
    debugPrint(message);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _directoryPath = null;
      _paths = null;
      _saveAsFileName = null;
      _userAborted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №2.7')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==== Configuration ====
          const _SectionTitle('Configuration'),
          TextField(
            controller: _dialogTitleController,
            decoration: const InputDecoration(
              labelText: 'Dialog Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _initialDirectoryController,
            decoration: const InputDecoration(
              labelText: 'Initial Directory',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _defaultFileNameController,
            decoration: const InputDecoration(
              labelText: 'Default File Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FileType>(
            initialValue: _pickingType,
            decoration: const InputDecoration(
              labelText: 'File Type',
              border: OutlineInputBorder(),
            ),
            items: FileType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.name)),
                )
                .toList(),
            onChanged: (value) => setState(() => _pickingType = value!),
          ),
          if (_pickingType == FileType.custom) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _fileExtensionController,
              decoration: const InputDecoration(
                labelText: 'Custom Extension (например: jpg, png)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // ==== Actions ====
          const _SectionTitle('Actions'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick file'),
              ),
              FilledButton.tonalIcon(
                onPressed: _selectFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text('Pick folder'),
              ),
              FilledButton.tonalIcon(
                onPressed: _saveFile,
                icon: const Icon(Icons.save),
                label: const Text('Save file'),
              ),
              FilledButton.tonalIcon(
                onPressed: _clearCachedFiles,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear temporary files'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ==== File Picker Result ====
          const _SectionTitle('File Picker Result'),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_userAborted)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('User has aborted the dialog')),
            )
          else if (_directoryPath != null)
            _ResultTile(title: 'Directory path', value: _directoryPath!)
          else if (_saveAsFileName != null)
            _ResultTile(title: 'Save as', value: _saveAsFileName!)
          else if (_paths != null)
            ..._paths!.map(
              (file) => _ResultTile(
                title: file.name,
                value: file.path ?? 'путь недоступен',
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Результат появится здесь',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String title;
  final String value;

  const _ResultTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
