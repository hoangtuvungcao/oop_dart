import '../game/models.dart';

/// `Session` - bộ nhớ phiên in-memory cho giai đoạn 1
/// - Ghi nhận player hiện tại, leaderboard và settings của ứng dụng
/// - Có thể mở rộng thêm lưu trữ persistent nếu bước sau cần
class Session {
  Session._();
  static final Session I = Session._();

  /// Bảng xếp hạng dùng chung trong suốt vòng đời ứng dụng
  final Leaderboard leaderboard = Leaderboard();

  /// Cấu hình toàn app (theme, âm thanh, kích thước chữ)
  final SettingsModel settings = SettingsModel();

  /// Người chơi đang hoạt động (được set sau khi nhập tên hoặc đăng nhập)
  Player? currentPlayer;

  void setPlayerName(String name) {
    currentPlayer = Player(name: name, score: 0, highestLevel: 1);
  }

  void reset() {
    currentPlayer = null;
  }
}
