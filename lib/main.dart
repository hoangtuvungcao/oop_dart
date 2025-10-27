// Import thư viện Flutter cơ bản
import 'package:flutter/material.dart';
// Import để cấu hình cache ảnh
import 'package:flutter/painting.dart';
// Import các màn hình
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/name_input_screen.dart';
import 'screens/game_basic_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/register_screen.dart';
import 'screens/initial_name_screen.dart';
// Import managers
import 'managers/sound_manager.dart';
import 'managers/storage_manager.dart';
// Import session manager
import 'session/session_manager.dart';

// Hàm main: điểm vào của ứng dụng
Future<void> main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Khởi tạo storage và nạp dữ liệu session trước khi dựng widget
    await StorageManager().init();
    print('StorageManager initialized');
    await Session.instance.loadAll();
    print('Session data loaded');
    await SoundManager().init();
    print('SoundManager initialized');
  } catch (e) {
    print('Init error: $e');
  }
  // Chạy ứng dụng
  runApp(const MyApp());
}

// Class chính của ứng dụng
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Giới hạn số ảnh cache
    PaintingBinding.instance.imageCache.maximumSize = 50;
    // Giới hạn dung lượng cache (~50MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Tiêu đề ứng dụng
      title: 'Bậc thầy trí tuệ',
      // Ẩn banner debug
      debugShowCheckedModeBanner: false,
      // Sử dụng Material3
      theme: ThemeData(useMaterial3: true),
      // Route ban đầu
      initialRoute: '/',
      routes: {
        // Routes màn hình chào
        '/': (context) => const SplashScreen(),
        // Routes đăng nhập
        '/login': (context) => const LoginScreen(),
        // Routes menu
        '/menu': (context) => const MenuScreen(),
        // Routes tên ban đầu
        '/initial-name': (context) => const InitialNameScreen(),
        // Routes nhập tên
        '/name': (context) => const NameInputScreen(),
        // Routes trò chơi
        '/game': (context) => const GameBasicScreen(),
        // Routes xếp hạng
        '/ranking': (context) => const RankingScreen(),
        // Routes cài đặt
        '/settings': (context) => const SettingsScreen(),
        // Routes đăng ký
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}