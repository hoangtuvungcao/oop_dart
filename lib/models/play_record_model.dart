/// Ghi lại kết quả của một phiên chơi

/// Lớp dữ liệu bất biến mô tả một lần chơi cụ thể (không chỉnh sửa sau khi tạo)
class PlayRecord {
  // ---------------------- THUỘC TÍNH CỐ ĐỊNH ----------------------
  /// Tên người chơi (dùng để liên kết với `Player` tương ứng)
  final String name;
  
  /// Điểm số đạt được trong phiên chơi này (khác với tổng điểm của Player)
  final int score;
  
  /// Level cao nhất mà phiên chơi này đạt được
  final int level;
  
  /// Mốc thời gian ghi nhận phiên chơi (theo giờ trên thiết bị)
  final DateTime playedAt;
  
  // --------------------------- KHỞI TẠO ---------------------------
  /// Nhận đầy đủ thông tin ngay khi tạo để đảm bảo tính bất biến
  const PlayRecord({
    required this.name,
    required this.score,
    required this.level,
    required this.playedAt,
  });
  
  // --------------------- THUỘC TÍNH TÍNH TOÁN ---------------------
  /// Điểm trung bình trên mỗi level (đánh giá hiệu suất)
  double get scorePerLevel => level > 0 ? score / level : 0.0;
  
  /// Khoảng thời gian đã trôi qua kể từ khi chơi phiên này
  Duration get timeSincePlay => DateTime.now().difference(playedAt);
  
  /// Đánh dấu các record diễn ra trong vòng 24 giờ qua
  bool get isRecent => timeSincePlay.inHours < 24;
  
  /// Chấm điểm hiệu suất theo các mốc `scorePerLevel`
  String get performanceGrade {
    final spl = scorePerLevel;
    if (spl >= 40) return 'A';
    if (spl >= 30) return 'B';
    if (spl >= 20) return 'C';
    if (spl >= 10) return 'D';
    return 'F';
  }
  
  // ----------------------- SO SÁNH RECORDS -----------------------
  /// So sánh điểm số của hai phiên chơi
  int compareByScore(PlayRecord other) {
    return score.compareTo(other.score);
  }
  
  /// So sánh level của hai phiên chơi
  int compareByLevel(PlayRecord other) {
    return level.compareTo(other.level);
  }
  
  /// So sánh thời gian chơi của hai phiên chơi (mới nhất trước)
  int compareByDate(PlayRecord other) {
    return other.playedAt.compareTo(playedAt); // Reverse order
  }
  
  /// So sánh hiệu suất của hai phiên chơi
  int compareByPerformance(PlayRecord other) {
    return scorePerLevel.compareTo(other.scorePerLevel);
  }
  
  // ------------------------- CHUYỂN ĐỔI JSON -------------------------
  /// Chuyển đổi record sang JSON để lưu trữ hoặc đồng bộ
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'level': level,
      // DateTime → ISO8601 String
      // VD: "2025-10-02T15:30:00.123456"
      'playedAt': playedAt.toIso8601String(),
    };
  }
  
  /// Tạo record từ JSON đã lưu (có xử lý thiếu/sai định dạng)
  factory PlayRecord.fromJson(Map<String, dynamic> json) {
    return PlayRecord(
      name: json['name'] as String? ?? 'Unknown',
      score: json['score'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      // Parse ISO8601 String → DateTime
      // Nếu fail → dùng DateTime.now()
      playedAt: _parseDateTime(json['playedAt'] as String?),
    );
  }
  
  /// Hàm hỗ trợ parse thời gian từ chuỗi ISO8601, trả về `DateTime.now()` nếu lỗi
  static DateTime _parseDateTime(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      // Parse failed → return current time
      return DateTime.now();
    }
  }
  
  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================
  
  /// Tạo bản sao với các trường tùy chọn cập nhật (vẫn giữ nguyên record gốc)
  PlayRecord copyWith({
    String? name,
    int? score,
    int? level,
    DateTime? playedAt,
  }) {
    return PlayRecord(
      name: name ?? this.name,
      score: score ?? this.score,
      level: level ?? this.level,
      playedAt: playedAt ?? this.playedAt,
    );
  }
  
  /// Chuỗi ngày giờ kiểu `dd/MM/yyyy HH:mm`, dễ đọc trên giao diện
  String get formattedDate {
    // Simple format - có thể dùng intl package cho format phức tạp
    final day = playedAt.day.toString().padLeft(2, '0');
    final month = playedAt.month.toString().padLeft(2, '0');
    final year = playedAt.year;
    final hour = playedAt.hour.toString().padLeft(2, '0');
    final minute = playedAt.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
  }
  
  /// Chuỗi “bao lâu trước” để hiển thị kiểu `2 phút trước`, `3 giờ trước`, ...
  String get relativeTime {
    final duration = timeSincePlay;
    
    if (duration.inDays > 0) {
      return '${duration.inDays} ngày trước';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} giờ trước';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  

  @override
  String toString() {
    return 'PlayRecord($name: $score pts, Level $level, $formattedDate)';
  }
  

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlayRecord) return false;
    
    return name == other.name &&
           score == other.score &&
           level == other.level &&
           playedAt == other.playedAt;
  }
  
  @override
  int get hashCode {
    return Object.hash(name, score, level, playedAt);
  }
}

