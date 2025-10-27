import 'package:flutter/material.dart';
import '../session/session_manager.dart' as Sm;

/// ThemeNotifier - Quản lý theme của ứng dụng và cập nhật UI theo thời gian thực
/// Dựa trên ChangeNotifier để mọi widget đang lắng nghe được rebuild khi theme đổi
class ThemeNotifier extends ChangeNotifier {
  // Triển khai dạng singleton để toàn bộ app dùng chung một bộ điều phối theme
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();
  
  /// Lấy chế độ theme hiện tại từ Session (light/dark/system)
  ThemeMode get themeMode => Sm.Session.instance.settings.themeMode;
  
  /// Kiểm tra xem hiện tại đang ở chế độ tối hay không
  bool get isDarkMode => themeMode == ThemeMode.dark;
  
  /// Kiểm tra xem hiện tại đang ở chế độ sáng hay không
  bool get isLightMode => themeMode == ThemeMode.light;
  
  /// Thiết lập lại theme mode và thông báo cho toàn bộ listener cập nhật giao diện
  Future<void> setThemeMode(ThemeMode mode) async {
    if (Sm.Session.instance.settings.themeMode == mode) return;
    Sm.Session.instance.settings.themeMode = mode;

    // Báo cho tất cả listener biết để rebuild UI
    notifyListeners();
  }
  
  /// Đổi qua lại giữa theme sáng và tối
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Chọn ảnh nền phù hợp với theme hiện tại
  String get backgroundAssetPath {
    return isDarkMode 
        ? 'assets/photo/nenapp2.gif' 
        : 'assets/photo/nenapp20.gif';
  }
  
  /// Lấy màu nền chính của form theo theme
  Color get formColor {
    return isDarkMode 
        ? const Color(0xFF003366) 
        : const Color(0xFF22B8B1);
  }
  
  /// Lấy màu viền theo theme đang dùng
  Color get borderColor {
    return isDarkMode 
        ? const Color(0xFF00E5FF) 
        : const Color(0xFF003366);
  }
  
  /// Lấy màu chữ (text/label) theo theme hiện tại
  Color get textColor {
    return isDarkMode 
        ? const Color(0xFF00E5FF) 
        : const Color(0xFF003366);
  }
  
  /// Lấy màu nhấn (accent) dùng cho các chi tiết nổi bật
  Color get accentColor {
    return isDarkMode 
        ? const Color(0xFF00E5FF) 
        : const Color(0xFF003366);
  }
}
