/// Định nghĩa các loại thẻ trong game.
abstract class CardBase {
  /// Mã định danh duy nhất của thẻ.
  final String id;

  /// Trạng thái mặt của thẻ.
  bool isFaceUp;

  /// Thẻ đã ghép cặp thành công hay chưa.
  bool isMatched;

  CardBase({required this.id, this.isFaceUp = false, this.isMatched = false});
}

/// Thẻ thường dùng để ghép cặp hình ảnh.
class NormalCard extends CardBase {
  /// Mã cặp để nhận diện hai thẻ giống nhau.
  final String pairId;

  /// Đường dẫn hình ảnh hiển thị (có thể null để fallback sang text).
  final String? imagePath;

  NormalCard({required super.id, required this.pairId, this.imagePath});
}

/// Thẻ bom gây phạt thời gian khi lật trúng.
class BombCard extends CardBase {
  /// Thời gian bị trừ khi kích hoạt (giây).
  final int penaltyTime;

  /// Bom đã bị vô hiệu hóa hay chưa.
  bool isDefused;

  BombCard({required super.id, this.penaltyTime = 5, this.isDefused = false});
}
