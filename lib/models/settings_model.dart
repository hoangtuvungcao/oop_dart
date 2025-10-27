/// `SettingsModel` - Nắm giữ toàn bộ thiết lập cá nhân của người chơi.
///
/// Bao gồm chế độ giao diện (`ThemeMode`), trạng thái âm thanh và cỡ chữ.
/// Được dùng chung cho toàn ứng dụng thông qua `Session`. Toàn bộ comment
/// mô tả chi tiết để dễ bảo trì và đồng bộ khi thao tác với UI.
import 'package:flutter/material.dart';

class SettingsModel {
  // ---------------------------------------------------------------------------
  // THUỘC TÍNH
  // ---------------------------------------------------------------------------

  /// Chế độ giao diện hiện tại (sáng/tối/theo hệ thống).
  ThemeMode themeMode;

  /// Trạng thái âm thanh: `true` = bật, `false` = tắt toàn bộ hiệu ứng.
  bool soundEnabled;

  /// Cỡ chữ mặc định cho toàn app (đơn vị point).
  double fontSize;

  // ---------------------------------------------------------------------------
  // KHỞI TẠO
  // ---------------------------------------------------------------------------

  /// Khởi tạo với giá trị mặc định thân thiện: sáng, bật âm thanh, font 16pt.
  SettingsModel({
    this.themeMode = ThemeMode.light,
    this.soundEnabled = true,
    this.fontSize = 16,
  });

  // ---------------------------------------------------------------------------
  // GETTER TIỆN ÍCH
  // ---------------------------------------------------------------------------

  /// Kiểm tra đang ở chế độ Dark.
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Kiểm tra đang ở chế độ Light.
  bool get isLightMode => themeMode == ThemeMode.light;

  /// Kiểm tra đang theo hệ thống.
  bool get isSystemMode => themeMode == ThemeMode.system;

  /// Đảm bảo cỡ chữ nằm trong khoảng cho phép (12 → 24pt).
  bool get isValidFontSize => fontSize >= 12 && fontSize <= 24;

  // ---------------------------------------------------------------------------
  // HÀNH VI CẬP NHẬT
  // ---------------------------------------------------------------------------

  /// Đặt mode mới (dùng khi user chọn cụ thể trong menu).
  void setTheme(ThemeMode mode) {
    themeMode = mode;
  }

  /// Chuyển đổi nhanh giữa Light và Dark.
  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  /// Bật/tắt âm thanh.
  void setSound(bool enabled) {
    soundEnabled = enabled;
  }

  /// Đảo trạng thái âm thanh.
  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  /// Đổi cỡ chữ và tự động giới hạn trong khoảng 12-24pt.
  void setFontSize(double size) {
    fontSize = size.clamp(12.0, 24.0);
  }

  /// Đưa tất cả thiết lập về mặc định ban đầu.
  void reset() {
    themeMode = ThemeMode.light;
    soundEnabled = true;
    fontSize = 16;
  }

  // ---------------------------------------------------------------------------
  // CHUYỂN ĐỔI JSON
  // ---------------------------------------------------------------------------

  /// Biến đối tượng thành JSON để lưu xuống storage.
  Map<String, dynamic> toJson() {
    return {
      'themeMode': _themeModeToString(themeMode),
      'soundEnabled': soundEnabled,
      'fontSize': fontSize,
    };
  }

  /// Tạo `SettingsModel` từ JSON đã lưu.
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: _stringToThemeMode(json['themeMode'] as String? ?? 'light'),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
    );
  }

  /// Tạo bản sao với một số trường thay đổi.
  SettingsModel copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    double? fontSize,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  // ---------------------------------------------------------------------------
  // HÀM HỖ TRỢ CHUYỂN ĐỔI THEMEMODE
  // ---------------------------------------------------------------------------

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _stringToThemeMode(String str) {
    switch (str.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  // ---------------------------------------------------------------------------
  // DEBUG
  // ---------------------------------------------------------------------------

  /// Chuỗi mô tả gọn để log nhanh trạng thái hiện tại.
  @override
  String toString() {
    return 'Settings(theme: ${_themeModeToString(themeMode)}, sound: $soundEnabled, font: $fontSize)';
  }
}

