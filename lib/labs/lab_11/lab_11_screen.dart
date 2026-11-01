import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'maps_urls.dart';

enum InputMode { address, coordinates }

class Lab11Screen extends StatefulWidget {
  const Lab11Screen({super.key});

  @override
  State<Lab11Screen> createState() => _Lab11ScreenState();
}

class _Lab11ScreenState extends State<Lab11Screen> {
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  InputMode _mode = InputMode.address;

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  double? _parseCoordinate(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  (double, double)? _readCoordinates() {
    final lat = _parseCoordinate(_latController.text);
    final lng = _parseCoordinate(_lngController.text);
    if (lat == null || lng == null) {
      _showSnack('Введите широту и долготу числами');
      return null;
    }
    if (lat < -90 || lat > 90) {
      _showSnack('Широта должна быть от -90 до 90');
      return null;
    }
    if (lng < -180 || lng > 180) {
      _showSnack('Долгота должна быть от -180 до 180');
      return null;
    }
    return (lat, lng);
  }

  Future<void> _openMaps() async {
    if (_mode == InputMode.address) {
      final address = _addressController.text.trim();
      if (address.isEmpty) {
        _showSnack('Введите адрес');
        return;
      }
      await _openUrl(MapsUrls.searchByAddress(address));
      return;
    }
    final coords = _readCoordinates();
    if (coords == null) return;
    await _openUrl(MapsUrls.searchByCoordinates(coords.$1, coords.$2));
  }

  Future<void> _openStreetView() async {
    if (_mode == InputMode.address) {
      _showSnack('Просмотр улиц работает только в режиме координат');
      return;
    }
    final coords = _readCoordinates();
    if (coords == null) return;
    await _openUrl(MapsUrls.streetView(coords.$1, coords.$2));
  }

  Future<void> _openUrl(String url) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _showSnack('Не удалось открыть карты');
    } catch (_) {
      if (mounted) _showSnack('Не удалось открыть карты');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №11')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<InputMode>(
              segments: const [
                ButtonSegment(
                  value: InputMode.address,
                  label: Text('Адрес'),
                  icon: Icon(Icons.location_city),
                ),
                ButtonSegment(
                  value: InputMode.coordinates,
                  label: Text('Координаты'),
                  icon: Icon(Icons.gps_fixed),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
            const SizedBox(height: 16),
            if (_mode == InputMode.address)
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Адрес',
                  hintText: 'Москва, Красная площадь, 1',
                  border: OutlineInputBorder(),
                ),
              )
            else ...[
              TextField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Широта',
                  hintText: '55.7558',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lngController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Долгота',
                  hintText: '37.6173',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.map),
              label: const Text('Показать на картах'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openStreetView,
              icon: const Icon(Icons.streetview),
              label: const Text('Просмотр улиц'),
            ),
          ],
        ),
      ),
    );
  }
}
