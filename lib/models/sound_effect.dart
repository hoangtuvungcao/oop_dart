/// SoundEffect - Enum liệt kê các loại hiệu ứng âm thanh trong game
/// Dùng để quản lý tập trung các loại âm thanh cần phát
enum SoundEffect {
  /// Âm thanh khi lật thẻ bài
  cardFlip,
  
  /// Âm thanh khi ghép đúng cặp thẻ
  matchSuccess,
  
  /// Âm thanh khi ghép sai cặp thẻ
  matchFail,
  
  /// Âm thanh khi kích hoạt thẻ bom
  bombHit,
  
  /// Âm thanh khi hoàn thành level
  levelComplete,
  
  /// Âm thanh khi thua game (hết thời gian)
  gameOver,
}
