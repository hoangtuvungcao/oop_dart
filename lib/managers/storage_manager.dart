

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Hỗ trợ chuyển đổi qua lại giữa Object và chuỗi JSON
import '../utils/logger.dart';

/// `StorageManager` - Quản lý toàn bộ thao tác lưu trữ bằng `SharedPreferences`.
class StorageManager {
  /// Constructor private nhằm bảo vệ singleton.
  StorageManager._internal();

  /// Instance duy nhất dùng chung toàn app.
  static final StorageManager _instance = StorageManager._internal();

  /// Factory trả về instance hiện hữu (singleton pattern).
  factory StorageManager() => _instance;

  /// Đối tượng `SharedPreferences` thực hiện ghi/đọc key-value.
  SharedPreferences? _prefs;

  /// Cờ đánh dấu đã khởi tạo hay chưa để tránh init nhiều lần.
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // KHOÁ (KEY) SỬ DỤNG CHUNG
  // ---------------------------------------------------------------------------

  static const String _keyUsernames = 'usernames';
  static const String _keyPasswordPrefix = 'password_';
  static const String _keyCurrentUser = 'current_user';

  static const String _keyPlayerName = 'player_name';
  static const String _keyPlayerScore = 'player_score';
  static const String _keyPlayerLevel = 'player_level';

  static const String _keyLeaderboard = 'leaderboard';
  static const String _keyPlayRecords = 'play_records';
  static const String _keySettings = 'settings';

  // ---------------------------------------------------------------------------
  // KHỞI TẠO & ĐẢM BẢO SẴN SÀNG
  // ---------------------------------------------------------------------------

  /// Khởi tạo `SharedPreferences` (gọi 1 lần khi boot app).
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      Logger.i('Storage', 'initialized successfully');
    } catch (e) {
      Logger.e('Storage', 'init failed: $e');
      _isInitialized = false;
    }
  }

  /// Kiểm tra đã init chưa trước mỗi operation
  ///
  /// **DEFENSIVE PROGRAMMING:**
  /// - Luôn kiểm tra trạng thái trước khi thao tác
  /// - Tránh crash nếu quên gọi init()
  /// - Auto-init nếu chưa init (fallback)
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _prefs == null) {
      Logger.w('Storage', 'not initialized, auto-initializing...');
      await init(); // Auto-init nếu chưa có
      _isInitialized = true; // Đánh dấu đã init
    }
  }

  /// Đăng ký tài khoản mới, trả về `false` nếu username đã tồn tại.
  Future<bool> registerUser(String username, String password) async {
    await _ensureInitialized();

    final users = await getAllUsernames();
    if (users.contains(username)) {
      Logger.w('Storage', 'username "$username" already exists');
      return false;
    }

    users.add(username);
    await _prefs!.setStringList(_keyUsernames, users);
    await _prefs!.setString('$_keyPasswordPrefix$username', password);

    Logger.i('Storage', 'registered user: $username');
    return true;
  }

  /// Đăng nhập (kiểm tra username + password)
  ///
  /// LOGIC:
  /// 1. Lấy password đã lưu từ storage
  /// 2. So sánh với password user nhập
  /// 3. Nếu khớp → lưu current session
  /// Kiểm tra thông tin đăng nhập và đặt user hiện tại nếu thành công.
  Future<bool> login(String username, String password) async {
    await _ensureInitialized();

    final savedPassword = _prefs!.getString('$_keyPasswordPrefix$username');
    if (savedPassword == null) {
      Logger.w('Storage', 'username "$username" not found');
      return false;
    }

    if (savedPassword != password) {
      Logger.w('Storage', 'wrong password for "$username"');
      return false;
    }

    await _prefs!.setString(_keyCurrentUser, username);
    Logger.i('Storage', 'login success: $username');
    return true;
  }

  /// Lấy username đang login (current session)
  ///
  /// **RETURN:** Username hoặc `null` nếu chưa login
  Future<String?> getCurrentUser() async {
    await _ensureInitialized();
    return _prefs!.getString(_keyCurrentUser);
  }

  /// Đăng xuất (xóa session)
  Future<void> logout() async {
    await _ensureInitialized();
    await _prefs!.remove(_keyCurrentUser);
    Logger.i('Storage', 'logout success');
  }

  /// Lấy tất cả usernames đã đăng ký
  Future<List<String>> getAllUsernames() async {
    await _ensureInitialized();
    return _prefs!.getStringList(_keyUsernames) ??
        []; // ?? = default value nếu null
  }


  Future<void> savePlayerData({
    required String name,
    required int score,
    required int level,
  }) async {
    await _ensureInitialized();

    // Lưu từng field riêng biệt
    await _prefs!.setString(_keyPlayerName, name);
    await _prefs!.setInt(_keyPlayerScore, score);
    await _prefs!.setInt(_keyPlayerLevel, level);

    Logger.i('Storage', 'saved player data: $name (score=$score, level=$level)');
  }

  /// Load thông tin player
  ///
  /// **RETURN:** Map với keys: 'name', 'score', 'level'
  /// Hoặc `null` nếu chưa có data
  Future<Map<String, dynamic>?> loadPlayerData() async {
    await _ensureInitialized();

    final name = _prefs!.getString(_keyPlayerName);
    if (name == null) return null; // Chưa có data

    // Lấy score và level (default 0 nếu null)
    final score = _prefs!.getInt(_keyPlayerScore) ?? 0;
    final level = _prefs!.getInt(_keyPlayerLevel) ?? 1;

    return {
      'name': name,
      'score': score,
      'level': level,
    };
  }


  Future<void> savePlayRecords(List<Map<String, dynamic>> records) async {
    await _ensureInitialized();

    // Convert list of maps → JSON string
    // `jsonEncode()` = serialize object sang string
    final jsonString = jsonEncode(records);

    await _prefs!.setString(_keyPlayRecords, jsonString);
    Logger.i('Storage', 'saved play records (${records.length})');
  }

  /// Load bảng xếp hạng
  ///
  /// **RETURN:** List of player records
  Future<List<Map<String, dynamic>>> loadPlayRecords() async {
    await _ensureInitialized();

    final jsonString = _prefs!.getString(_keyPlayRecords);
    if (jsonString == null) return []; // Chưa có data

    try {
      // Parse JSON string → Dart list
      // `jsonDecode()` = deserialize string sang object
      final List<dynamic> decoded = jsonDecode(jsonString);

      // Convert mỗi item sang Map<String, dynamic>
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      Logger.e('Storage', 'parse play records JSON failed: $e');
      return [];
    }
  }

  /// Lưu danh sách players của leaderboard
  Future<void> saveLeaderboard(List<Map<String, dynamic>> players) async {
    await _ensureInitialized();
    final jsonString = jsonEncode(players);
    await _prefs!.setString(_keyLeaderboard, jsonString);
    Logger.i('Storage', 'saved leaderboard players (${players.length})');
  }

  /// Load danh sách players của leaderboard
  Future<List<Map<String, dynamic>>> loadLeaderboard() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_keyLeaderboard);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      Logger.e('Storage', 'parse leaderboard players JSON failed: $e');
      return [];
    }
  }

  Future<void> saveSettings({
    required String theme, // 'light', 'dark', 'system'
    required bool soundEnabled,
    required double fontSize,
  }) async {
    await _ensureInitialized();

    // Tạo Map để lưu
    final settingsMap = {
      'theme': theme,
      'soundEnabled': soundEnabled,
      'fontSize': fontSize,
    };

    // Convert sang JSON string
    final jsonString = jsonEncode(settingsMap);
    await _prefs!.setString(_keySettings, jsonString);
    Logger.i('Storage', 'saved settings');
  }

  /// Load settings
  Future<Map<String, dynamic>?> loadSettings() async {
    await _ensureInitialized();

    final jsonString = _prefs!.getString(_keySettings);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      Logger.e('Storage', 'parse settings JSON failed: $e');
      return null;
    }
  }



  /// Xóa tất cả data (reset app)
  ///
  /// **USE CASE:** Testing, reset game, clear cache
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs!.clear();
    Logger.w('Storage', 'cleared all local data');
  }

  /// Xóa data của 1 key cụ thể
  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  /// Kiểm tra key có tồn tại không
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }
}

