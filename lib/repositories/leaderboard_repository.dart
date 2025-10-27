import '../session/session_manager.dart' as NewSession;
import '../session/session.dart' as OldSession;

/// `RankItem` - DTO dùng để hiển thị dữ liệu xếp hạng (tên, điểm, level)
class RankItem {
  final String name;
  final int score;
  final int highestLevel;

  const RankItem({required this.name, required this.score, required this.highestLevel});
}

/// `LeaderboardRepository` - gom dữ liệu bảng xếp hạng từ session cũ và session mới
class LeaderboardRepository {
  const LeaderboardRepository();

  /// Gộp danh sách người chơi từ cả hai hệ thống session thành một list duy nhất
  List<RankItem> _merged() {
    final items = <RankItem>[];

    // Lấy dữ liệu từ session mới (NewSession)
    final newBoard = NewSession.Session.instance.leaderboard;
    for (final p in newBoard.players) {
      items.add(RankItem(name: p.name, score: p.score, highestLevel: p.highestLevel));
    }

    // Thêm dữ liệu từ session cũ (OldSession - runtime)
    final oldBoard = OldSession.Session.I.leaderboard;
    for (final p in oldBoard.players) {
      items.add(RankItem(name: p.name, score: p.score, highestLevel: p.highestLevel));
    }

    return items;
  }

  /// Lấy top `limit` người chơi có điểm cao nhất (mặc định 5)
  List<RankItem> topByScore({int limit = 5}) {
    final merged = _merged();
    merged.sort((a, b) => b.score.compareTo(a.score));
    return merged.take(limit).toList();
  }

  /// Lấy top `limit` người chơi có level cao nhất (mặc định 5)
  List<RankItem> topByLevel({int limit = 5}) {
    final merged = _merged();
    merged.sort((a, b) => b.highestLevel.compareTo(a.highestLevel));
    return merged.take(limit).toList();
  }
}
