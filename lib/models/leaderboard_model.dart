/// `Leaderboard` - Quản lý danh sách người chơi và lịch sử ván chơi.
///
/// Nhiệm vụ chính:
/// - Lưu trữ danh sách `Player` với điểm và level cao nhất.
/// - Ghi lại từng `PlayRecord` để thống kê chi tiết.
/// - Cung cấp các hàm tiện ích để thêm/xóa/tìm kiếm và sắp xếp dữ liệu.
import 'player_model.dart';
import 'play_record_model.dart';

class Leaderboard {
  /// Danh sách người chơi hiện có trên bảng xếp hạng.
  final List<Player> players = [];

  /// Nhật ký các ván chơi đã ghi nhận.
  final List<PlayRecord> records = [];

  /// Thêm mới hoặc cập nhật thông tin người chơi dựa trên tên (unique).
  /// Nếu người chơi đã tồn tại thì ghi đè bằng dữ liệu mới nhất.
  void addOrUpdate(Player player) {
    final existingIndex = players.indexWhere((p) => p.name == player.name);

    if (existingIndex != -1) {
      players[existingIndex] = player;
    } else {
      players.add(player);
    }
  }

  /// Alias tiện dụng cho `addOrUpdate()`.
  void addPlayer(Player player) {
    addOrUpdate(player);
  }

  /// Xóa người chơi theo tên. Trả về `true` nếu xóa được ít nhất một người.
  bool removePlayer(String name) {
    final removed = players.where((p) => p.name == name).length;
    players.removeWhere((p) => p.name == name);
    return removed > 0;
  }

  /// Tìm người chơi theo tên. Không ném exception mà trả về `null` nếu không có.
  Player? findPlayer(String name) {
    try {
      return players.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Trả về danh sách mới đã sắp xếp theo điểm giảm dần.
  List<Player> sortByScore() {
    final copy = List<Player>.from(players);
    copy.sort((a, b) => b.score.compareTo(a.score));
    return copy;
  }

  /// Trả về danh sách mới đã sắp xếp theo level cao nhất.
  List<Player> sortByLevel() {
    final copy = List<Player>.from(players);
    copy.sort((a, b) => b.highestLevel.compareTo(a.highestLevel));
    return copy;
  }

  /// Lấy `n` người chơi có điểm cao nhất.
  List<Player> getTopPlayers(int n) {
    final sorted = sortByScore();
    return sorted.take(n).toList();
  }

  /// Thêm một bản ghi ván chơi mới.
  void addRecord(PlayRecord record) {
    records.add(record);
  }

  /// Trả về danh sách bản ghi sắp xếp theo điểm giảm dần.
  List<PlayRecord> sortRecordsByScore() {
    final copy = List<PlayRecord>.from(records);
    copy.sort((a, b) => b.score.compareTo(a.score));
    return copy;
  }

  /// Trả về danh sách bản ghi sắp xếp theo level đạt được.
  List<PlayRecord> sortRecordsByLevel() {
    final copy = List<PlayRecord>.from(records);
    copy.sort((a, b) => b.level.compareTo(a.level));
    return copy;
  }

  /// Trả về danh sách bản ghi theo thứ tự thời gian (mới nhất trước).
  List<PlayRecord> sortRecordsByDate() {
    final copy = List<PlayRecord>.from(records);
    copy.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return copy;
  }

  /// Lọc các bản ghi tương ứng với một người chơi cụ thể.
  List<PlayRecord> getPlayerRecords(String name) {
    return records.where((r) => r.name == name).toList();
  }

  /// Tổng số người chơi đang có trong bảng.
  int get totalPlayers => players.length;

  /// Tổng số ván chơi đã được ghi nhận.
  int get totalGames => records.length;

  /// Điểm cao nhất đạt được trong toàn bộ bảng.
  int get highestScore {
    if (players.isEmpty) return 0;
    return players.reduce((a, b) => a.score > b.score ? a : b).score;
  }

  /// Level cao nhất đạt được trong toàn bộ bảng.
  int get highestLevel {
    if (players.isEmpty) return 0;
    return players.reduce((a, b) => a.highestLevel > b.highestLevel ? a : b).highestLevel;
  }

  /// Convert toàn bộ dữ liệu sang JSON để lưu trữ.
  Map<String, dynamic> toJson() {
    return {
      'players': players.map((p) => p.toJson()).toList(),
      'records': records.map((r) => r.toJson()).toList(),
    };
  }

  /// Khởi tạo `Leaderboard` từ JSON.
  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    final board = Leaderboard._internal();

    if (json['players'] != null) {
      final playersList = json['players'] as List;
      board.players.addAll(
        playersList.map((p) => Player.fromJson(p as Map<String, dynamic>)),
      );
    }

    if (json['records'] != null) {
      final recordsList = json['records'] as List;
      board.records.addAll(
        recordsList.map((r) => PlayRecord.fromJson(r as Map<String, dynamic>)),
      );
    }

    return board;
  }

  /// Constructor mặc định.
  Leaderboard();

  /// Constructor dùng riêng cho `fromJson()` để bỏ qua việc khởi tạo lại list.
  Leaderboard._internal();

  /// Xóa toàn bộ dữ liệu (players + records).
  void clear() {
    players.clear();
    records.clear();
  }
}
