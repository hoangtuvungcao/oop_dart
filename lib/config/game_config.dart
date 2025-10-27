class GameConfig {
  // Constructor riêng tư để tạo singleton
  GameConfig._(); // Ngăn tạo instance từ bên ngoài
  // Instance duy nhất của GameConfig
  static final GameConfig instance =
      GameConfig._(); // Truy cập qua GameConfig.instance

  // Phương thức tính số thẻ cơ bản cho level
  int getBaseCardCount(int level) =>
      4 + (level - 1) * 2; // Mỗi level tăng 2 thẻ

  // Phương thức tính số bom cho level
  int getBombsCount(int level) {
    // Bom xuất hiện từ level 4
    if (level < 4) return 0;
    // Mỗi 2 level thêm 1 bom
    return 1 + ((level - 4) ~/ 2);
  }

  // Phương thức tính thời gian giới hạn cho level
  int getTimeLimit(int level) => 30 + (level - 1) * 8; // Mỗi level thêm 8 giây

  // Thời gian xem trước thẻ
  static const int previewSeconds = 5;

  // Số lượt trợ giúp tối đa mỗi level
  static const int maxHelpsPerLevel = 3;

  // Điểm thưởng khi ghép đúng cặp
  static const int pointsPerMatch = 10;

  // Điểm phạt khi ghép sai
  static const int penaltyPerMismatch = 3;

  // Giây phạt khi kích hoạt bom
  static const int bombPenaltySeconds = 10;

  // Giây thưởng khi dùng trợ giúp thêm thời gian
  static const int helpExtraTimeBonus = 10;
  // Giây phạt ở level tiếp theo khi dùng trợ giúp này
  static const int helpExtraTimePenalty = 15;

  // Thời gian hiển thị tất cả thẻ khi dùng trợ giúp
  static const int helpShowAllDuration = 3;
  // Giây phạt khi dùng trợ giúp hiển thị tất cả
  static const int helpShowAllCost = 5;

  // Màu sắc giao diện ngày
  static const int dayFormColorValue = 0xFF22B8B1; // Màu nền chính
  static const int dayBorderColorValue = 0xFF003366; // Màu viền
  static const int dayAccentColorValue = 0xFF00E5FF; // Màu nhấn

  // Màu sắc giao diện đêm
  static const int nightFormColorValue = 0xFF003366; // Màu nền đêm
  static const int nightBorderColorValue = 0xFF00E5FF; // Màu viền đêm

  // Màu sắc thẻ
  static const int cardBackColorValue = 0xFF22B8B1; // Mặt sau thẻ
  static const int cardMatchedColorValue = 0xFF9EF7F4; // Thẻ đã ghép
  static const int cardNormalColorValue = 0xFF45F5EF; // Thẻ bình thường
  static const int cardBombColorValue = 0xFFFFCDD2; // Thẻ bom

  // Thời gian animation
  static const int cardFlipDuration = 300; // Lật thẻ (ms)
  static const int mismatchFlipBackDelay = 700; // Úp lại thẻ sai (ms)
  static const int themeTransitionDuration = 300; // Chuyển theme (ms)

  // Bộ nhớ đệm GIF
  static const int gifCacheWidth = 1280; // Độ rộng cache
  static const int gifCacheHeight = 720; // Độ cao cache

  // Đường dẫn ảnh
  static const String bgLightPath = 'assets/photo/nenapp20.gif'; // Nền ngày
  static const String bgDarkPath = 'assets/photo/nenapp2.gif'; // Nền đêm
  static const String modelGifPath = 'assets/photo/modelGIF1.gif'; // GIF trang trí
  static const String cardBackPath = 'assets/levels/back.png'; // Mặt sau thẻ
  static const String cardBombPath = 'assets/levels/bom.png'; // Ảnh bom
  // Phương thức lấy đường dẫn ảnh level
  String getLevelImagePath(int index) => 'assets/levels/${index + 1}.jpg'; // Ảnh thẻ

  // Đường dẫn âm thanh
  static const String audioFlipPath = 'assets/audio/flip.mp3'; // Lật thẻ
  static const String audioWinPath = 'assets/audio/win.mp3'; // Thắng level
  static const String audioPairMatchPath = 'assets/audio/w.mp3'; // Ghép đúng
  static const String audioMismatchPath = 'assets/audio/loss.mp3'; // Ghép sai
  static const String audioLosePath = 'assets/audio/lose.mp3'; // Thua
  static const String audioBgDayPath = 'assets/audio/是心动啊 - 原来是萝卜丫.mp3'; // Nhạc nền ngày
  static const String audioBgNightPath = 'assets/audio/Thirteen.mp3'; // Nhạc nền đêm
  static const String audioBgPlayPath = 'assets/audio/game_play.mp3'; // Nhạc chơi game

  // Âm lượng
  static const double bgMusicVolume = 0.25; // Nhạc nền
  static const double sfxVolume = 0.5; // Hiệu ứng

  // Kích thước giao diện
  static const double maxContentWidth = 700; // Nội dung tối đa
  static const double maxMenuWidth = 400; // Menu tối đa
  static const double maxSettingsWidth = 600; // Cài đặt tối đa

  // Cỡ chữ
  static const double minFontSize = 12; // Tối thiểu
  static const double maxFontSize = 24; // Tối đa
  static const double defaultFontSize = 16; // Mặc định

  // Lưới thẻ
  static const double cardGridPadding = 12; // Khoảng cách viền
  static const double cardGridSpacing = 12; // Khoảng cách thẻ
  static const double minCardSize = 72; // Kích thước tối thiểu thẻ

  // Chuỗi văn bản
  static const String appTitle = 'Bậc thầy trí tuệ'; // Tiêu đề app
  static const String gameOverTitle = 'Game Over'; // Tiêu đề thua
  static const String levelCompletePrefix = 'Hoàn thành Level'; // Tiêu đề thắng
  static const String nextLevelMessage = 'Đang chuyển sang level tiếp theo...'; // Thông báo chuyển level

  // Thông báo lỗi
  static const String errorEmptyName = 'Vui lòng nhập tên!'; // Lỗi tên trống
  static const String errorInvalidCredentials = 'Tài khoản hoặc mật khẩu không đúng!'; // Lỗi đăng nhập
}
