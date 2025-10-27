// Import thư viện just_audio để phát âm thanh
import 'package:just_audio/just_audio.dart';
// Import cấu hình game
import '../config/game_config.dart';
// Import session manager
import '../session/session_manager.dart' as Sm;
// Import model sound effect
import '../models/sound_effect.dart';

/// SoundManager - Trung tâm điều phối toàn bộ âm thanh của trò chơi
/// Phân tách rõ giữa nhạc nền và hiệu ứng âm thanh để dễ kiểm soát
/// Tự động tuân theo cấu hình âm thanh mà người dùng bật/tắt trong `Session`
class SoundManager {
  // Singleton instance
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Hai bộ phát âm thanh độc lập
  final AudioPlayer _bgMusicPlayer = AudioPlayer(); // Nhạc nền
  final AudioPlayer _sfxPlayer = AudioPlayer(); // Hiệu ứng

  // Theo dõi trạng thái hiện tại
  bool _isInitialized = false; // Đã khởi tạo chưa
  bool _isPlayingNightMode = false; // Đang phát nhạc đêm
  bool _isMusicStarted = false; // Đã bắt đầu nhạc
  bool _inGameplay = false; // Đang trong gameplay

  // Giá trị âm lượng mặc định
  double _bgVolume = GameConfig.bgMusicVolume;
  double _sfxVolume = GameConfig.sfxVolume;
  double? _previousBgVolume; // Âm lượng trước đó
  bool? _previousThemeNight; // Chế độ theme trước đó

  /// Chuẩn bị bộ phát âm thanh
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _bgMusicPlayer.setLoopMode(LoopMode.one);
      await _bgMusicPlayer.setVolume(_bgVolume);
      _isInitialized = true;
    } catch (e) {
      print('SoundManager init error: $e');
    }
  }

  /// Bắt đầu phát nhạc nền
  Future<void> startBackgroundMusic({required bool isNightMode}) async {
    await init();
    if (!_isMusicStarted) {
      try {
        await _setBackgroundTrack(isNightMode);
        if (Sm.Session.instance.settings.soundEnabled) {
          await _bgMusicPlayer.play();
        }
        _isMusicStarted = true;
      } catch (e) {
        print('Failed to start background music: $e');
      }
    }
  }

  /// Chuyển đổi nhạc nền giữa chế độ ngày và đêm
  Future<void> toggleThemeMusic(bool isNightMode) async {
    print('[SoundManager] toggleThemeMusic -> isNightMode=$isNightMode');
    // Đang chơi game thì không chuyển nhạc
    if (_inGameplay) {
      print('[SoundManager] toggleThemeMusic skipped (in gameplay)');
      return;
    }
    await startBackgroundMusic(isNightMode: isNightMode);

    if (_isPlayingNightMode != isNightMode) {
      try {
        final currentPosition = _bgMusicPlayer.position;
        // Dừng hẳn track hiện tại
        await _bgMusicPlayer.stop();
        await _setBackgroundTrack(isNightMode);
        print('[SoundManager] toggled track. nightMode=$_isPlayingNightMode position=${currentPosition.inMilliseconds}ms');

        // Cố gắng phát tiếp ở vị trí tương đương
        try {
          await _bgMusicPlayer.seek(currentPosition);
        } catch (_) {}

        if (Sm.Session.instance.settings.soundEnabled) {
          await _bgMusicPlayer.play();
        }
      } catch (e) {
        print('Failed to toggle theme music: $e');
      }
    }
  }

  /// Bật/Tắt toàn bộ âm thanh dựa trên cấu hình người dùng
  Future<void> setSoundEnabled(bool enabled, {required bool isNightMode}) async {
    if (!enabled) {
      stopAll();
      return;
    }
    // Nếu bật lại, phát nhạc nền tương ứng với chế độ hiện tại
    await startBackgroundMusic(isNightMode: isNightMode);
  }
  
  /// Chọn bài nhạc nền phù hợp với chế độ ngày/đêm
  Future<void> _setBackgroundTrack(bool isNightMode) async {
    final assetPath = isNightMode 
        ? GameConfig.audioBgNightPath 
        : GameConfig.audioBgDayPath;
    print('[SoundManager] _setBackgroundTrack -> isNightMode=$isNightMode asset=$assetPath');
    
    if (!_isInitialized) await init();
    
    if (_isPlayingNightMode == isNightMode && _bgMusicPlayer.playing) {
      return; // Đang phát đúng bài rồi thì không cần đổi nữa
    }
    
    await _bgMusicPlayer.setAsset(assetPath);
    await _bgMusicPlayer.setVolume(_bgVolume);
    _isPlayingNightMode = isNightMode;
  }
  
  /// Phát một hiệu ứng âm thanh, có kiểm tra xem người chơi đã tắt âm hay chưa
  Future<void> playSoundEffect(SoundEffect effect) async {
    try {
      if (!Sm.Session.instance.settings.soundEnabled) return;
      
      final assetPath = _getSoundEffectPath(effect);
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play();
    } catch (e) {
      // Nếu phát sinh lỗi cũng bỏ qua để không làm gián đoạn game
      print('SFX error: $e');
    }
  }
  
  /// Xác định file âm thanh tương ứng với từng loại hiệu ứng
  String _getSoundEffectPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.cardFlip:
        return GameConfig.audioFlipPath;
      case SoundEffect.matchSuccess:
        return GameConfig.audioPairMatchPath; // w.mp3 dành cho ghép đúng
      case SoundEffect.matchFail:
        return GameConfig.audioMismatchPath;
      case SoundEffect.bombHit:
      case SoundEffect.gameOver:
        return GameConfig.audioLosePath;
      case SoundEffect.levelComplete:
        return GameConfig.audioWinPath;
    }
  }
  
  /// Dừng toàn bộ âm thanh đang phát
  void stopAll() {
    _bgMusicPlayer.stop();
    _isMusicStarted = false;
  }
  
  /// Tạm dừng nhạc nền (khi cần giữ trạng thái)
  void pauseBackgroundMusic() {
    _bgMusicPlayer.pause();
  }
  
  /// Tiếp tục phát nhạc nền nếu người dùng vẫn bật âm
  Future<void> resumeBackgroundMusic() async {
    if (Sm.Session.instance.settings.soundEnabled && _isMusicStarted) {
      await _bgMusicPlayer.play();
    }
  }
  
  /// Điều chỉnh âm lượng nhạc nền
  Future<void> setBackgroundVolume(double volume) async {
    _bgVolume = volume.clamp(0.0, 1.0);
    if (_isInitialized) {
      try {
        await _bgMusicPlayer.setVolume(_bgVolume);
      } catch (_) {}
    }
  }
  
  /// Điều chỉnh âm lượng hiệu ứng âm thanh
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }
  
  /// Giải phóng tài nguyên khi không cần dùng nữa
  void dispose() {
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
    _isInitialized = false;
    _isMusicStarted = false;
  }
  
  // ===== Gameplay music control =====
  /// Chuyển sang track nhạc dành riêng cho gameplay (êm hơn để tập trung)
  Future<void> enterGameplayMusic({double volume = 0.4}) async {
    // Nếu đã ở chế độ gameplay thì không phát lại từ đầu
    if (_inGameplay) {
      return;
    }
    await init();
    _previousBgVolume ??= _bgVolume;
    _previousThemeNight ??= _isPlayingNightMode;
    try {
      // Tắt nhạc nền hiện tại để tránh chồng âm
      await _bgMusicPlayer.stop();
      try {
        await _bgMusicPlayer.setAsset(GameConfig.audioBgPlayPath);
      } catch (e) {
        // Nếu thiếu file gameplay, dùng tạm nhạc đêm
        print('gameplay asset missing, fallback to night: $e');
        await _bgMusicPlayer.setAsset(GameConfig.audioBgNightPath);
      }
      _isPlayingNightMode = true; // Ghi nhận trạng thái giả lập ban đêm khi đang chơi
      _inGameplay = true;
      await setBackgroundVolume(volume);
      if (Sm.Session.instance.settings.soundEnabled) {
        await _bgMusicPlayer.play();
      }
    } catch (e) {
      print('enterGameplayMusic error: $e');
    }
  }

  /// Khôi phục track nhạc nền trước khi vào gameplay
  Future<void> exitGameplayMusic() async {
    try {
      _inGameplay = false;
      // Cố gắng về lại đúng chế độ trước đó, nếu không thì dựa theo cài đặt hiện tại
      final restoreNight = _previousThemeNight ?? Sm.Session.instance.settings.isDarkMode;
      await _setBackgroundTrack(restoreNight);
      if (_previousBgVolume != null) {
        await setBackgroundVolume(_previousBgVolume!);
      }
      _previousThemeNight = null;
      _previousBgVolume = null;
      if (Sm.Session.instance.settings.soundEnabled) {
        await _bgMusicPlayer.play();
      } else {
        _bgMusicPlayer.stop();
      }
    } catch (e) {
      print('exitGameplayMusic error: $e');
    }
  }
  
  // Convenient shorthand methods
  Future<void> playFlip() => playSoundEffect(SoundEffect.cardFlip);
  Future<void> playMatchSuccess() => playSoundEffect(SoundEffect.matchSuccess);
  Future<void> playMatchFail() => playSoundEffect(SoundEffect.matchFail);
  Future<void> playBombHit() => playSoundEffect(SoundEffect.bombHit);
  Future<void> playLevelComplete() => playSoundEffect(SoundEffect.levelComplete);
  Future<void> playGameOver() => playSoundEffect(SoundEffect.gameOver);
}
