/// `Player` - Đại diện cho hồ sơ người chơi trong game.
///
/// Chứa các thông tin quan trọng như tên, điểm tích lũy và level cao nhất.
/// Các hàm đi kèm hỗ trợ cập nhật điểm, level và chuyển đổi dữ liệu JSON.
class Player {
  // ----------------------------- THUỘC TÍNH -----------------------------
  /// Tên hiển thị của người chơi (có thể đổi nên không dùng `final`).
  String name;
  
  /// Tổng điểm tích lũy xuyên suốt các level.
  int score;
  
  /// Level cao nhất mà người chơi từng vượt qua.
  int highestLevel;
  
  // ------------------------------ KHỞI TẠO ------------------------------
  /// Dùng named parameters để dễ đọc; score/level có giá trị mặc định 0 và 1.
  Player({
    required this.name,
    this.score = 0,
    this.highestLevel = 1,
  });
  
  // ---------------------------- HÀNH VI CHÍNH ----------------------------
  /// Cộng thêm hoặc trừ đi một lượng điểm (không cho âm dưới 0).
  void addScore(int points) {
    score += points;
    if (score < 0) score = 0;
  }
  
  /// Nâng cấp level cao nhất nếu người chơi đạt mốc mới.
  void updateHighestLevel(int newLevel) {
    if (newLevel > highestLevel) {
      highestLevel = newLevel;
    }
  }
  
  /// Đặt lại điểm số về 0 khi bắt đầu lại từ đầu.
  void resetScore() {
    score = 0;
  }
  
  // -------------------------- CHUYỂN ĐỔI JSON --------------------------
  /// Trả về `Map` để lưu trữ hoặc đồng bộ dữ liệu người chơi.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'highestLevel': highestLevel,
    };
  }
  
  /// Khởi tạo người chơi từ dữ liệu JSON đã lưu.
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String? ?? 'Unknown',
      score: json['score'] as int? ?? 0,
      highestLevel: json['highestLevel'] as int? ?? 1,
    );
  }
  
  /// Chuỗi mô tả súc tích phục vụ cho việc log/debug.
  @override
  String toString() {
    return 'Player(name: $name, score: $score, level: $highestLevel)';
  }
  
  /// Hai `Player` được xem là giống nhau khi trùng tên (score/level có thể khác).
  @override
  bool operator ==(Object other) {
    if (other is! Player) return false;
    return name == other.name;
  }
  
  /// Hash code tương ứng (phải thống nhất với logic `==` ở trên).
  @override
  int get hashCode => name.hashCode;
}

