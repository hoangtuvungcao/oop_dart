// Import các model của game
import '../game/models.dart';
// Import cấu hình game
import '../config/game_config.dart';

// Class xây dựng level dựa trên số level và config
class LevelBuilder {
  // Instance config duy nhất
  final GameConfig _config = GameConfig.instance;

  // Phương thức xây dựng level
  LevelModel buildLevel(int levelNumber) {
    // Trả về LevelModel với các tham số tính từ config
    return LevelModel(
      levelNumber: levelNumber,
      baseCardCount: _config.getBaseCardCount(levelNumber),
      bombsCount: _config.getBombsCount(levelNumber),
      timeLimit: _config.getTimeLimit(levelNumber),
      previewSeconds: GameConfig.previewSeconds,
    );
  }

  // Phương thức lấy độ khó của level
  String getLevelDifficulty(int levelNumber) {
    // Dựa trên số level để phân loại độ khó
    if (levelNumber <= 2) return 'Dễ';
    if (levelNumber <= 5) return 'Trung bình';
    if (levelNumber <= 8) return 'Khó';
    return 'Cực khó';
  }

  // Phương thức ước lượng thời gian hoàn thành
  int getExpectedCompletionTime(int levelNumber) {
    // Tính dựa trên số cặp thẻ và thời gian preview
    final pairs = _config.getBaseCardCount(levelNumber) ~/ 2;
    return (pairs * 2) + GameConfig.previewSeconds;
  }

  // Phương thức kiểm tra level hợp lệ
  bool isValidLevel(int levelNumber) {
    // Kiểm tra level trong phạm vi 1-20
    return levelNumber > 0 && levelNumber <= 20;
  }
}
