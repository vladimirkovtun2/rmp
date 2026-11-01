import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'lab_audio_handler.dart';

/// Лабораторная работа №2.6 — воспроизведение аудио (audioplayers).
///
/// Плеер по методичке: play/pause/stop, ползунок позиции, выбор трека
/// на устройстве. Воспроизведением управляет глобальный LabAudioHandler
/// (создан в main) — обёртка в MediaSession, поэтому плеер доступен из
/// шторки уведомлений, с экрана блокировки и с кнопок гарнитуры.
class Lab26Screen extends StatefulWidget {
  const Lab26Screen({super.key});

  @override
  State<Lab26Screen> createState() => _Lab26ScreenState();
}

class _Lab26ScreenState extends State<Lab26Screen> {
  StreamSubscription<PlaybackState>? _stateSubscription;
  StreamSubscription<MediaItem?>? _itemSubscription;

  bool _hasTrack = false;
  bool _playing = false;
  bool _paused = false;
  Duration? _duration;
  Duration _position = Duration.zero;
  String _trackName = 'Трек не выбран';

  bool get _isPlaying => _playing;
  bool get _isPaused => _paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position.toString().split('.').first;

  @override
  void initState() {
    super.initState();
    // Хендлер создан в main; здесь только подписываемся на его потоки
    final handler = labAudioHandler;
    if (handler == null) return;
    // Состояние может уже существовать (трек играет с прошлого раза)
    _playing = handler.playbackState.value.playing;
    final item = handler.mediaItem.value;
    if (item != null) {
      _hasTrack = true;
      _trackName = item.title;
      _duration = item.duration;
    }
    _stateSubscription = handler.playbackState.listen((state) {
      setState(() {
        _playing = state.playing;
        if (state.playing) _paused = false;
        if (state.processingState != AudioProcessingState.idle) {
          _position = state.updatePosition;
        }
      });
    });
    _itemSubscription = handler.mediaItem.listen((item) {
      if (item == null) return;
      setState(() {
        _hasTrack = true;
        _trackName = item.title;
        _duration = item.duration;
      });
    });
  }

  // ====== Выбор трека на устройстве ======

  Future<void> _pickTrack() async {
    const audioGroup = XTypeGroup(
      label: 'Аудио',
      mimeTypes: ['audio/*'],
      extensions: ['mp3', 'aac', 'm4a', 'ogg', 'wav', 'flac'],
    );
    final file = await openFile(acceptedTypeGroups: const [audioGroup]);
    if (file == null) return; // пользователь отменил выбор

    final handler = labAudioHandler;
    if (handler == null) {
      _showMessage('Плеер недоступен: ${labAudioHandlerError ?? 'неизвестная ошибка'}');
      return;
    }
    await handler.setTrack(file.path, file.name);
  }

  // ====== Управление воспроизведением ======

  Future<void> _play() async {
    await labAudioHandler?.play();
    if (!mounted) return;
    setState(() {
      _playing = true;
      _paused = false;
    });
  }

  Future<void> _pause() async {
    await labAudioHandler?.pause();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _paused = true;
    });
  }

  Future<void> _stop() async {
    await labAudioHandler?.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _paused = true;
      _position = Duration.zero;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  // Подписки могут срабатывать после dispose — обновляем состояние
  // только у живого виджета
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _itemSubscription?.cancel();
    // Хендлер и плеер НЕ уничтожаем: воспроизведение продолжается
    // в фоне, управление — из шторки
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final handlerReady = labAudioHandler != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №2.6')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _trackName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Управление доступно из шторки уведомлений',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (!handlerReady) ...[
              const SizedBox(height: 4),
              Text(
                labAudioHandlerError != null
                    ? 'Ошибка плеера: $labAudioHandlerError'
                    : 'Плеер не инициализирован',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: labAudioHandlerError != null ? Colors.red : Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickTrack,
              icon: const Icon(Icons.audio_file),
              label: const Text('Выбрать трек на устройстве'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const Key('play_button'),
                  onPressed: _hasTrack && !_isPlaying ? _play : null,
                  iconSize: 48,
                  icon: const Icon(Icons.play_arrow),
                  color: color,
                ),
                IconButton(
                  key: const Key('pause_button'),
                  onPressed: _isPlaying ? _pause : null,
                  iconSize: 48,
                  icon: const Icon(Icons.pause),
                  color: color,
                ),
                IconButton(
                  key: const Key('stop_button'),
                  onPressed: _hasTrack && (_isPlaying || _isPaused)
                      ? _stop
                      : null,
                  iconSize: 48,
                  icon: const Icon(Icons.stop),
                  color: color,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Slider(
                onChanged: (value) {
                  final duration = _duration;
                  if (duration == null) return;
                  final position = value * duration.inMilliseconds;
                  labAudioHandler
                      ?.seek(Duration(milliseconds: position.round()));
                },
                value: (_position.inMilliseconds > 0 &&
                        _duration != null &&
                        _position.inMilliseconds < _duration!.inMilliseconds)
                    ? _position.inMilliseconds / _duration!.inMilliseconds
                    : 0.0,
              ),
            ),
            Text(
              _hasTrack ? '$_positionText / $_durationText' : '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
