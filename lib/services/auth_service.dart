import 'package:flutter/foundation.dart';
import '../managers/storage_manager.dart';
import '../session/session_manager.dart' as Sm;

/// `AuthService` - Chịu trách nhiệm đăng ký/đăng nhập bằng `StorageManager`
/// - Lưu thông tin người dùng vào storage cục bộ
/// - Kiểm tra hợp lệ và đồng bộ `Session`
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final StorageManager _storage = StorageManager();

  // Removed _users field - now using StorageManager instead

  String? _currentUser;

  /// Trả về tài khoản đang đăng nhập (hoặc `null` nếu chưa có)
  String? get currentUser => _currentUser;

  /// Đăng nhập bằng cách kiểm tra thông tin lưu trong `StorageManager`
  Future<bool> login(String username, String password) async {
    final cleanUsername = username.trim();
    
    // Kiểm tra username/password không được rỗng
    if (cleanUsername.isEmpty || password.isEmpty) {
      print('❌ Login failed: Empty username or password');
      return false;
    }
    
    try {
      // Thêm delay nhẹ để cảm giác đăng nhập tự nhiên hơn
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Kiểm tra thông tin đăng nhập với storage
      final success = await _storage.login(cleanUsername, password);
      
      if (success) {
        _currentUser = cleanUsername;
        print('✅ Login successful: $cleanUsername');
        // Nếu chưa có tên người chơi, đặt mặc định theo username và lưu lại
        final hasName = await Sm.Session.instance.hasPlayerName();
        if (!hasName) {
          await Sm.Session.instance.setInitialPlayerName(cleanUsername);
        }
        // Tải lại toàn bộ dữ liệu để `Session` đồng bộ với storage
        await Sm.Session.instance.loadAll();
      } else {
        print('❌ Login failed: Invalid credentials for $cleanUsername');
      }
      
      return success;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }
  
  /// Đăng ký tài khoản mới vào storage
  Future<bool> register(String username, String password) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) return false;
    if (cleanUsername.length < 3 || password.length < 3) return false;
    
    await Future.delayed(const Duration(milliseconds: 300));
    final success = await _storage.registerUser(cleanUsername, password);
    
    if (success) {
      _currentUser = cleanUsername;
      // Đăng nhập tự động sau khi đăng ký thành công
      await _storage.login(cleanUsername, password);
      if (kDebugMode) print('✅ Registered: $cleanUsername');
      // Lần đầu: đặt tên người chơi trùng với username và lưu lại
      await Sm.Session.instance.setInitialPlayerName(cleanUsername);
      // Đồng bộ lại toàn bộ dữ liệu vào `Session`
      await Sm.Session.instance.loadAll();
    }
    return success;
  }
  /// Đăng xuất và xoá thông tin phiên hiện tại
  Future<void> logout() async {
    await _storage.logout();
    _currentUser = null;
  }
  
  /// Get current logged user từ Storage
  Future<String?> getCurrentUser() async {
    return await _storage.getCurrentUser();
  }
  
  /// Check đã login chưa
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null && user.isNotEmpty;
  }
}
