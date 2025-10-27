
/// Gói gọn toàn bộ thông số cố định của một level (chỉ đọc, không chỉnh sửa sau khi tạo)
class LevelModel {
  // ---------------------- THUỘC TÍNH CỐ ĐỊNH ----------------------
  /// Thứ tự màn chơi (bắt đầu từ 1, càng lớn càng khó)
  final int levelNumber;
  
  /// Tổng số thẻ thường cần ghép (luôn là số chẵn để tạo thành cặp)
  final int baseCardCount;
  
  /// Số thẻ bom xuất hiện trong bàn chơi
  final int bombsCount;
  
  /// Thời gian tối đa để hoàn thành màn (giây)
  final int timeLimit;
  
  /// Thời gian mở toàn bộ thẻ cho người chơi ghi nhớ trước khi úp lại
  final int previewSeconds;
  
  // --------------------------- KHỞI TẠO ---------------------------
  /// Sử dụng named parameters để bắt buộc truyền đủ mọi thông số ngay từ đầu
  const LevelModel({
    required this.levelNumber,
    required this.baseCardCount,
    required this.bombsCount,
    required this.timeLimit,
    this.previewSeconds = 5, // Default value
  });
  
  // --------------------- THUỘC TÍNH TÍNH TOÁN ---------------------
  /// Tổng số thẻ xuất hiện trong màn (thẻ thường + bom)
  int get totalCards => baseCardCount + bombsCount;
  
  /// Số cặp thẻ thường cần ghép
  int get pairCount => baseCardCount ~/ 2; // ~/ = integer division
  
  /// Chuỗi mô tả độ khó dựa trên `levelNumber`
  String get difficulty {
    if (levelNumber <= 2) return 'Dễ';
    if (levelNumber <= 5) return 'Trung bình';
    if (levelNumber <= 8) return 'Khó';
    return 'Cực khó';
  }
  
  /// Ước lượng thời gian cần thiết để hoàn thành level (giây)
  int get estimatedCompletionTime => (pairCount * 2) + previewSeconds;
  
  // --------------------------- HỖ TRỢ KHÁC ---------------------------
  /// Tạo bản sao với một vài thông số thay đổi (phần còn lại giữ nguyên)
  LevelModel copyWith({
    int? levelNumber,
    int? baseCardCount,
    int? bombsCount,
    int? timeLimit,
    int? previewSeconds,
  }) {
    return LevelModel(
      levelNumber: levelNumber ?? this.levelNumber,
      baseCardCount: baseCardCount ?? this.baseCardCount,
      bombsCount: bombsCount ?? this.bombsCount,
      timeLimit: timeLimit ?? this.timeLimit,
      previewSeconds: previewSeconds ?? this.previewSeconds,
    );
  }
  
  /// Chuyển cấu hình level thành `Map` để lưu trữ hoặc gửi đi
  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'baseCardCount': baseCardCount,
      'bombsCount': bombsCount,
      'timeLimit': timeLimit,
      'previewSeconds': previewSeconds,
    };
  }
  
  /// Khởi tạo lại `LevelModel` từ dữ liệu JSON đã lưu
  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      levelNumber: json['levelNumber'] as int,
      baseCardCount: json['baseCardCount'] as int,
      bombsCount: json['bombsCount'] as int,
      timeLimit: json['timeLimit'] as int,
      previewSeconds: json['previewSeconds'] as int? ?? 5,
    );
  }
  
  /// Chuỗi mô tả súc tích, hữu ích khi debug/log
  @override
  String toString() {
    return 'Level $levelNumber ($baseCardCount cards, $bombsCount bomb${bombsCount != 1 ? 's' : ''}, ${timeLimit}s) - $difficulty';
  }
  
  /// Hai `LevelModel` được xem là bằng nhau nếu có cùng `levelNumber`
  @override
  bool operator ==(Object other) {
    if (other is! LevelModel) return false;
    return levelNumber == other.levelNumber;
  }
  
  @override
  int get hashCode => levelNumber.hashCode;
}

