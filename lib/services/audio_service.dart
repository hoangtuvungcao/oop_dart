import 'package:just_audio/just_audio.dart';
import '../session/session.dart';

class AudioService {
  // Áp dụng singleton để toàn app dùng chung một bộ phát âm thanh
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _player = AudioPlayer();
  final _sfxPlayer = AudioPlayer(); // Bộ phát riêng cho hiệu ứng âm thanh
  bool _initialized = false;
  bool _isPlayingNight = false;
  bool _isStarted = false; // Trên web cần có thao tác của người dùng mới autoplay được
  double _bgVolume = 0.25; // Âm lượng nhạc nền mặc định
  double _sfxVolume = 0.5; // Âm lượng hiệu ứng mặc định

  Future<void> init() async {
    if (_initialized) return;
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(_bgVolume);
    _initialized = true;
  }

  /// Đảm bảo nhạc nền đã được khởi chạy (đặc biệt trên web cần gọi sau khi có tương tác)
  Future<void> startIfNeeded({required bool isNightMode}) async {
    await init();
    if (!_isStarted) {
      try {
        await _setTrack(isNightMode);
        await _player.play();
        _isStarted = true;
      } catch (_) {
        // Bỏ qua lỗi để không chặn UI khởi tạo
      }
    }
  }

  /// Chuyển đổi giữa nhạc ngày/đêm và phát liên tục
  Future<void> toggle(bool isNightMode) async {
    await startIfNeeded(isNightMode: isNightMode);
    if (_isPlayingNight != isNightMode) {
      try {
        final pos = _player.position;
        await _setTrack(isNightMode);
        // Cố gắng phát tiếp tại vị trí tương tự để không bị hụt đoạn
        try { await _player.seek(pos); } catch (_) {}
        await _player.play();
      } catch (_) {}
    }
  }

  Future<void> _setTrack(bool night) async {
    final asset = night
        ? 'assets/audio/Thirteen.mp3'
        : 'assets/audio/是心动啊 - 原来是萝卜丫.mp3';
    if (!_initialized) await init();
    if (_isPlayingNight == night && _player.playing) return;
    await _player.setAsset(asset);
    await _player.setVolume(_bgVolume);
    _isPlayingNight = night;
  }

  void stopAll() {
    _player.stop();
    _isStarted = false;
  }

  void dispose() {
    _player.dispose();
    _sfxPlayer.dispose();
    _initialized = false;
    _isStarted = false;
  }

  Future<void> setBackgroundVolume(double volume) async {
    _bgVolume = volume.clamp(0.0, 1.0);
    if (_initialized) {
      try { await _player.setVolume(_bgVolume); } catch (_) {}
    }
  }

  /// Phát hiệu ứng âm thanh nếu người dùng đang bật âm
  Future<void> playSfx(String assetPath) async {
    try {
      if (!Session.I.settings.soundEnabled) return;
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play();
    } catch (_) {
      // Bỏ qua lỗi để không gián đoạn trải nghiệm chơi
    }
  }

  // Các hàm tiện lợi cho từng hiệu ứng cụ thể
  Future<void> playFlip() => playSfx('assets/audio/flip.mp3');
  Future<void> playWin() => playSfx('assets/audio/win.mp3');
  Future<void> playLose() => playSfx('assets/audio/lose.mp3');
}
