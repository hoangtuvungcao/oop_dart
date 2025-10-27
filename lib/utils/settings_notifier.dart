// ==============================================================================
// SETTINGS NOTIFIER - Thông báo khi settings thay đổi
// ==============================================================================
//
// **MỤC ĐÍCH:**
// - Notify tất cả screens khi settings thay đổi
// - Trigger rebuild UI khi theme/font thay đổi
//
// **PATTERN:** Observer Pattern
// ==============================================================================

import 'dart:async';

/// SettingsNotifier - Singleton để notify settings changes
class SettingsNotifier {
  static final SettingsNotifier _instance = SettingsNotifier._internal();
  factory SettingsNotifier() => _instance;
  SettingsNotifier._internal();
  
  // Stream controller để broadcast settings changes
  final StreamController<void> _controller = StreamController<void>.broadcast();
  
  /// Stream để listen settings changes
  Stream<void> get settingsChanged => _controller.stream;
  
  /// Notify tất cả listeners rằng settings đã thay đổi
  void notifySettingsChanged() {
    _controller.add(null);
  }
  
  /// Dispose stream controller
  void dispose() {
    _controller.close();
  }
}
