/// RankItem - Cấu trúc dữ liệu nhẹ dùng hiển thị bảng xếp hạng
/// Dùng để truyền dữ liệu giữa các widget trong màn hình xếp hạng
class RankItem {
  /// Tên người chơi
  final String name;
  
  /// Tổng điểm tích lũy của người chơi
  final int score;
  
  /// Level cao nhất mà người chơi đạt được
  final int highestLevel;

  /// Constructor với các tham số bắt buộc
  const RankItem({
    required this.name, 
    required this.score, 
    required this.highestLevel
  });
}
