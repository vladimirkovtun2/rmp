import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

/// Глобальный хендлер плеера лабораторной 2.6.
/// audio_service требует создать его ОДИН РАЗ при старте приложения —
/// иначе не будет работать холодный старт по кнопке из уведомления.
LabAudioHandler? labAudioHandler;
String? labAudioHandlerError;

Future<LabAudioHandler?> initLabAudioHandler() async {
  if (labAudioHandler != null) return labAudioHandler;
  try {
    labAudioHandler = await AudioService.init(
      builder: () => LabAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.rmp_9plus.audio',
        androidNotificationChannelName: 'Воспроизведение музыки',
        androidNotificationOngoing: true,
      ),
    );
  } catch (e) {
    labAudioHandlerError = e.toString();
    labAudioHandler = null;
  }
  return labAudioHandler;
}

/// Медиахендлер лабораторной 2.6.
///
/// Оборачивает AudioPlayer в MediaSession: система сама рисует плеер
/// в шторке уведомлений, на экране блокировки и реагирует на кнопки
/// гарнитуры — UI для этого писать не нужно, только публиковать
/// медиаэлемент и состояние воспроизведения.
class LabAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  bool _completed = false;

  LabAudioHandler() {
    _player.onPlayerStateChanged.listen((_) => _broadcast());
    _player.onPositionChanged.listen((position) {
      _position = position;
      _broadcast();
    });
    _player.onDurationChanged.listen((duration) {
      final item = mediaItem.value;
      if (item != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
      _broadcast();
    });
    _player.onPlayerComplete.listen((_) {
      _completed = true;
      _position = Duration.zero;
      _broadcast();
    });
    _broadcast();
  }

  bool get _playing => _player.state == PlayerState.playing;

  /// Подключить трек после выбора файла на устройстве.
  Future<void> setTrack(String path, String title) async {
    _completed = false;
    _position = Duration.zero;
    mediaItem.add(MediaItem(id: path, title: title, artist: 'rmp_9plus'));
    await _player.setSource(DeviceFileSource(path));
    _broadcast();
  }

  Future<Duration?> getTrackDuration() => _player.getDuration();

  /// Публикация состояния в медиасессию (шторка обновляется отсюда).
  void _broadcast() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (_playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0],
        processingState: _completed
            ? AudioProcessingState.completed
            : AudioProcessingState.ready,
        playing: _playing,
        updatePosition: _position,
      ),
    );
  }

  @override
  Future<void> play() async {
    _completed = false;
    await _player.resume();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
    _broadcast();
  }

  @override
  Future<void> stop() async {
    // «Стоп» без потери источника (та же логика, что и в UI лабораторной):
    // в audioplayers stop() освобождает источник, поэтому пауза + ноль.
    await _player.pause();
    await _player.seek(Duration.zero);
    _completed = false;
    _position = Duration.zero;
    _broadcast();
  }

  Future<void> disposeHandler() async {
    await _player.dispose();
  }
}
