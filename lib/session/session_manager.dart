// ==============================================================================
// SESSION MANAGER - Quản lý trạng thái global của ứng dụng
// ==============================================================================
//
// **MỤC ĐÍCH:**
// - Lưu trữ state chung cho toàn app: Player hiện tại, Settings, Leaderboard
// - Singleton pattern: Chỉ có 1 instance duy nhất
// - Access từ mọi nơi qua Session.instance
//
// **OOP CONCEPTS:**
// 1. SINGLETON PATTERN - Chỉ 1 instance toàn app
// 2. COMPOSITION - Session HAS-A Player, Settings, Leaderboard
// 3. STATE MANAGEMENT - Quản lý state global
// 4. PERSISTENCE INTEGRATION - Tích hợp với StorageManager
//
// **VÍ DỤ THỰC TẾ:**
// - Giống "Application State" trong Redux
// - Giống "Global Variables" nhưng có cấu trúc
// - Giống "Context" trong React
// ==============================================================================

import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../models/leaderboard_model.dart';
import '../models/settings_model.dart';
import '../models/play_record_model.dart';
import '../managers/storage_manager.dart';
import '../utils/logger.dart';

/// Session - Singleton quản lý state global
///
/// **OOP: SINGLETON PATTERN**
/// - Private constructor `Session._()` 
/// - Static instance `Session.instance`
/// - Factory constructor return instance có sẵn
///
/// **WHY SINGLETON?**
/// - State phải consistent toàn app
/// - Tránh duplicate data
/// - Easy access từ mọi nơi
///
/// **ACCESS:**
/// ```dart
/// // Cách 1: Dùng instance
/// Session.instance.currentPlayer = player;
///
/// // Cách 2: Alias ngắn gọn hơn
/// Session.I.currentPlayer = player;
/// ```
class Session {

  Session._();
  
  static final Session instance = Session._();
  
  /// Alias ngắn gọn cho instance
  ///
  /// **CONVENIENCE:**
  /// - `Session.I` ngắn hơn `Session.instance`
  /// - Dễ đọc code: `Session.I.currentPlayer`
  static Session get I => instance;
  
  // ==========================================================================
  // DEPENDENCIES - Storage Manager
  // ==========================================================================
  
  /// StorageManager để lưu/load data
  ///
  /// **OOP: COMPOSITION**
  /// - Session HAS-A StorageManager
  /// - Không kế thừa (not IS-A)
  final StorageManager _storage = StorageManager();
  
  // ==========================================================================
  // STATE PROPERTIES - Trạng thái global
  // ==========================================================================
  
  /// Leaderboard chung toàn app
  ///
  /// **DATA TYPE:** Leaderboard
  /// - Chứa danh sách players và play records
  /// - Shared giữa MenuScreen, RankingScreen, GameScreen
  ///
  /// **INITIALIZATION:**
  /// - Khởi tạo empty khi app start
  /// - Load từ storage sau đó
  ///
  /// **FINAL:**
  /// - Không thể reassign object Leaderboard
  /// - Nhưng có thể modify content (add players)
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// // Add player
  /// Session.I.leaderboard.addOrUpdate(player);
  ///
  /// // Get sorted
  /// List<Player> top = Session.I.leaderboard.sortByScore();
  /// ```
  final Leaderboard leaderboard = Leaderboard();
  
  /// Settings chung toàn app
  ///
  /// **DATA TYPE:** SettingsModel
  /// - Theme, Sound, Font size
  /// - Shared toàn app
  ///
  /// **MUTABLE:**
  /// - Properties có thể thay đổi
  /// - VD: `settings.themeMode = ThemeMode.dark`
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// // Đọc setting
  /// bool isDark = Session.I.settings.isDarkMode;
  ///
  /// // Đổi setting
  /// Session.I.settings.toggleTheme();
  ///
  /// // Access từ widget
  /// Text('Hello', style: TextStyle(
  ///   fontSize: Session.I.settings.fontSize,
  /// ))
  /// ```
  final SettingsModel settings = SettingsModel();
  
  /// Player hiện tại đang chơi
  ///
  /// **DATA TYPE:** Player? (nullable)
  /// - `null` = chưa có player (chưa nhập tên)
  /// - Non-null = đang có player
  ///
  /// **LIFECYCLE:**
  /// 1. App start: null
  /// 2. User nhập tên: create Player object
  /// 3. Chơi game: update score/level
  /// 4. Logout: set null
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// // Set player
  /// Session.I.currentPlayer = Player(name: 'Trọng', score: 0);
  ///
  /// // Get player (safe)
  /// Player? p = Session.I.currentPlayer;
  /// if (p != null) {
  ///   print('Playing as: ${p.name}');
  /// }
  ///
  /// // Update score
  /// Session.I.currentPlayer?.addScore(10);
  /// ```
  Player? currentPlayer;
  
  // ==========================================================================
  // PLAYER MANAGEMENT METHODS
  // ==========================================================================
  
  /// Set player name (tạo Player object mới)
  ///
  /// **FLOW:**
  /// 1. Tạo Player object với name
  /// 2. Score = 0, Level = 1 (default)
  /// 3. Assign vào currentPlayer
  ///
  /// **USE CASE:**
  /// - NameInputScreen: User nhập tên → gọi method này
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// // User nhập "Trọng"
  /// Session.I.setPlayerName('Trọng');
  ///
  /// // Giờ currentPlayer = Player(name: 'Trọng', score: 0, level: 1)
  /// ```
  void setPlayerName(String name) {
    currentPlayer = Player(
      name: name,
      score: 0,         // Bắt đầu từ 0 điểm
      highestLevel: 1,  // Bắt đầu từ level 1
    );
  }
  
  /// Reset currentPlayer (logout/quit)
  ///
  /// **EFFECT:**
  /// - currentPlayer = null
  /// - User phải nhập tên lại
  ///
  /// **USE CASE:**
  /// - MenuScreen: Button "Thoát game"
  /// - LoginScreen: Logout
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// Session.I.reset();
  /// // currentPlayer = null
  /// ```
  void reset() {
    currentPlayer = null;
  }
  
  // ==========================================================================
  // PERSISTENCE METHODS - Lưu/Load từ Storage
  // ==========================================================================
  
  /// Lưu tất cả data vào Storage
  ///
  /// **WHAT TO SAVE:**
  /// 1. Player data (name, score, level)
  /// 2. Leaderboard (danh sách players + records)
  /// 3. Settings (theme, sound, font)
  ///
  /// **WHEN TO CALL:**
  /// - Khi finish level
  /// - Khi đổi settings
  /// - Khi logout
  /// - Periodically (auto-save)
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// // Sau khi thắng level
  /// await Session.I.saveAll();
  /// ```
  Future<void> saveAll() async {
    // Save player data nếu có
    if (currentPlayer != null) {
      await _storage.savePlayerData(
        name: currentPlayer!.name,
        score: currentPlayer!.score,
        level: currentPlayer!.highestLevel,
      );
    }
    
    // Lưu leaderboard (danh sách người chơi)
    // Chuyển đối tượng Leaderboard → JSON
    final leaderboardJson = leaderboard.toJson();
    final playersList = leaderboardJson['players'] as List;
    // Ghi chú: recordsList hiện chưa dùng vì StorageManager chỉ lưu danh sách người chơi

    // Storage mong đợi danh sách Map
    await _storage.saveLeaderboard([
      ...playersList.cast<Map<String, dynamic>>(),
    ]);
    
    // Lưu lịch sử chơi riêng để theo dõi lâu dài
    final recordsList = leaderboard.records.map((r) => r.toJson()).toList();
    await _storage.savePlayRecords(recordsList);
    
    // Lưu thiết lập hiện tại
    await _storage.saveSettings(
      theme: settings.themeMode == ThemeMode.dark ? 'dark' : 
             settings.themeMode == ThemeMode.light ? 'light' : 'system',
      soundEnabled: settings.soundEnabled,
      fontSize: settings.fontSize,
    );
  }
  
  /// Load tất cả data từ Storage
  ///
  /// **WHAT TO LOAD:**
  /// 1. Player data → currentPlayer
  /// 2. Leaderboard → leaderboard  
  /// 3. Settings → settings
  ///
  /// **WHEN TO CALL:**
  /// - App start (main.dart initState)
  /// - After login
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// // Trong main.dart
  /// await StorageManager().init();
  /// await Session.I.loadAll();
  /// ```
  Future<void> loadAll() async {
    Logger.i('Session', 'Đang tải tất cả dữ liệu từ storage...');
    
    // Tải dữ liệu người chơi
    final playerData = await _storage.loadPlayerData();
    if (playerData != null) {
      currentPlayer = Player(
        name: playerData['name'] as String,
        score: playerData['score'] as int,
        highestLevel: playerData['level'] as int,
      );
      Logger.i('Session', 'Loaded player: ${currentPlayer!.name}');
    } else {
      Logger.i('Session', 'Không tìm thấy dữ liệu người chơi đã lưu');
    }
    
    // Tải danh sách người chơi trong leaderboard
    final leaderboardData = await _storage.loadLeaderboard();
    leaderboard.clear(); // Xoá dữ liệu cũ trước khi nạp mới
    
    for (final item in leaderboardData) {
      final player = Player.fromJson(item);
      leaderboard.addOrUpdate(player);
    }
    
    // Tải lịch sử lượt chơi
    final recordsData = await _storage.loadPlayRecords();
    for (final rec in recordsData) {
      try {
        leaderboard.addRecord(PlayRecord.fromJson(rec));
      } catch (_) {}
    }
    Logger.i('Session', 'Đã tải leaderboard: ${leaderboard.totalPlayers} người chơi, lượt chơi: ${leaderboard.totalGames}');
    
    // Tải thiết lập và áp dụng cho toàn app
    final settingsData = await _storage.loadSettings();
    if (settingsData != null) {
      // Phân tích giá trị theme từ chuỗi lưu trữ
      final themeStr = settingsData['theme'] as String? ?? 'light';
      settings.themeMode = themeStr == 'dark' ? ThemeMode.dark :
                           themeStr == 'system' ? ThemeMode.system :
                           ThemeMode.light;
      
      settings.soundEnabled = settingsData['soundEnabled'] as bool? ?? true;
      settings.fontSize = (settingsData['fontSize'] as num?)?.toDouble() ?? 16.0;
      
      Logger.i('Session', 'Đã tải settings: theme=$themeStr, sound=${settings.soundEnabled}, font=${settings.fontSize}');
    } else {
      Logger.i('Session', 'Không có settings lưu sẵn, sử dụng mặc định');
    }
  }
  
  /// Check xem có player name đã lưu không
  ///
  /// **RETURN:** `true` nếu có player name đã lưu
  ///
  /// **USE CASE:**
  /// - App start: check có cần nhập tên không
  /// - Skip NameInputScreen nếu đã có tên
  Future<bool> hasPlayerName() async {
    final playerData = await _storage.loadPlayerData();
    return playerData != null && playerData['name'] != null;
  }
  
  /// Check xem tên player có bị trùng không (toàn app)
  ///
  /// **LOGIC:**
  /// - Load tất cả players từ leaderboard
  /// - Check xem tên đã tồn tại chưa
  /// - Return true nếu trùng
  ///
  /// **USE CASE:**
  /// - InitialNameScreen validation
  /// - Đảm bảo tên unique toàn app
  Future<bool> isPlayerNameTaken(String name) async {
    // Load leaderboard data
    final leaderboardData = await _storage.loadLeaderboard();
    
    // Check xem có player nào cùng tên không
    for (final playerData in leaderboardData) {
      if (playerData['name'] == name) {
        return true; // Tên đã được dùng
      }
    }
    
    return false; // Tên chưa được dùng
  }
  
  /// Lưu tên player lần đầu
  ///
  /// **PARAMETERS:**
  /// - `name`: Tên player
  ///
  /// **EFFECT:**
  /// - Tạo Player object mới
  /// - Lưu vào storage
  /// - Set làm currentPlayer
  Future<void> setInitialPlayerName(String name) async {
    // Tạo player mới với tên
    currentPlayer = Player(
      name: name,
      score: 0,
      highestLevel: 1,
    );
    
    // Lưu vào storage ngay
    await savePlayer();
    Logger.i('Session', 'Set initial player name: $name');
  }
  
  /// Xóa tên player (để logout hoàn toàn)
  ///
  /// **USE CASE:**
  /// - Khi user bấm "Thoát game"
  /// - Xóa player name khỏi storage
  /// - Lần sau mở app phải nhập tên lại
  Future<void> clearPlayerName() async {
    // Clear current player
    currentPlayer = null;
    
    // Clear từ storage
    await _storage.remove('player_name');
    await _storage.remove('player_score');
    await _storage.remove('player_level');
    
    Logger.i('Session', 'Cleared player name - will need to re-enter on next launch');
  }
  
  /// Lưu chỉ player data
  ///
  /// **QUICK SAVE:**
  /// - Chỉ lưu player hiện tại
  /// - Nhanh hơn saveAll()
  ///
  /// **USE CASE:**
  /// - Sau mỗi level
  /// - Khi update score
  Future<void> savePlayer() async {
    if (currentPlayer != null) {
      await _storage.savePlayerData(
        name: currentPlayer!.name,
        score: currentPlayer!.score,
        level: currentPlayer!.highestLevel,
      );
    }
  }
  
  /// Lưu chỉ settings
  Future<void> saveSettings() async {
    await _storage.saveSettings(
      theme: settings.themeMode == ThemeMode.dark ? 'dark' : 
             settings.themeMode == ThemeMode.light ? 'light' : 'system',
      soundEnabled: settings.soundEnabled,
      fontSize: settings.fontSize,
    );
  }
  
  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================
  
  /// Check xem có player đang chơi không
  ///
  /// **RETURN:** `true` nếu currentPlayer != null
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// if (Session.I.hasPlayer) {
  ///   // Có player → show game
  /// } else {
  ///   // Chưa có → show name input
  /// }
  /// ```
  bool get hasPlayer => currentPlayer != null;
  
  /// Get player name (safe)
  ///
  /// **RETURN:** 
  /// - Player name nếu có
  /// - "Guest" nếu null
  ///
  /// **VÍ DỤ:**
  /// ```dart
  /// Text('Hello ${Session.I.playerName}');
  /// // "Hello Trọng" hoặc "Hello Guest"
  /// ```
  String get playerName => currentPlayer?.name ?? 'Guest';
  
  /// Get player score (safe)
  int get playerScore => currentPlayer?.score ?? 0;
  
  /// Get player level (safe)
  int get playerLevel => currentPlayer?.highestLevel ?? 1;
  
  /// Debug info
  @override
  String toString() {
    return 'Session(player: ${currentPlayer?.name ?? 'none'}, '
           'leaderboard: ${leaderboard.totalPlayers} players, '
           'settings: ${settings.themeMode})';
  }
}

