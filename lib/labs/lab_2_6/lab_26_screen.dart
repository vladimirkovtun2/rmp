import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

/// Лабораторная работа №2.6 — воспроизведение аудио (audioplayers).
///
/// Плеер по методичке: play/pause/stop, ползунок позиции, подписки на
/// события плеера. Плюс выбор трека с устройства (file_selector).
class Lab26Screen extends StatefulWidget {
  const Lab26Screen({super.key});

  @override
  State<Lab26Screen> createState() => _Lab26ScreenState();
}

class _Lab26ScreenState extends State<Lab26Screen> {
  late final AudioPlayer _player;

  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;
  String _trackName = 'Трек не выбран';

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  StreamSubscription<PlayerState>? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;

  bool get _hasTrack => _duration != null;

  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _playerState = _player.state;
    _player.getDuration().then((value) => setState(() => _duration = value));
    _player
        .getCurrentPosition()
        .then((value) => setState(() => _position = value));
    _initStreams();
  }

  void _initStreams() {
    _durationSubscription = _player.onDurationChanged.listen(
      (duration) => setState(() => _duration = duration),
    );
    _positionSubscription = _player.onPositionChanged.listen(
      (position) => setState(() => _position = position),
    );
    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });
    _playerStateChangeSubscription = _player.onPlayerStateChanged.listen(
      (state) => setState(() => _playerState = state),
    );
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

    await _player.setSource(DeviceFileSource(file.path));
    final duration = await _player.getDuration();
    setState(() {
      _trackName = file.name;
      _duration = duration;
      _position = Duration.zero;
      _playerState = PlayerState.stopped;
    });
  }

  // ====== Управление воспроизведением ======

  Future<void> _play() async {
    await _player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await _player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    // НЕ player.stop(): в audioplayers он освобождает источник, и после
    // него resume() уже нечего играть — трек пришлось бы выбирать заново.
    // Пауза + сброс позиции даёт «стоп» без потери источника.
    await _player.pause();
    await _player.seek(Duration.zero);
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
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
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
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
                  onPressed: _isPlaying || _isPaused ? _stop : null,
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
                  _player.seek(Duration(milliseconds: position.round()));
                },
                value: (_position != null &&
                        _duration != null &&
                        _position!.inMilliseconds > 0 &&
                        _position!.inMilliseconds < _duration!.inMilliseconds)
                    ? _position!.inMilliseconds / _duration!.inMilliseconds
                    : 0.0,
              ),
            ),
            Text(
              _position != null
                  ? '$_positionText / $_durationText'
                  : _duration != null
                      ? _durationText
                      : '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
