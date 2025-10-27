// ignore_for_file: file_names

// Màn hình đăng nhập phong cách pixel. Dùng `AuthService` để xác thực.
// Đăng nhập thành công sẽ điều hướng về `SplashScreen` để tiếp tục luồng khởi động.
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/register_screen.dart';
import '../widgets/login_form.dart';
import '../widgets/mode_switch.dart';
import '../widgets/app_background.dart';
import '../managers/sound_manager.dart';
import '../session/session_manager.dart' as Sm;
import '../utils/settings_notifier.dart';
import '../screens/splash_screen.dart';
import '../widgets/app_brand.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isNightMode = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    // Hoãn các tác vụ nặng sau frame đầu tiên để tránh chặn UI khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final ctx = context;
      // Tiền tải ảnh nền ở nền mà không chờ đợi để tránh khựng
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        precacheImage(const AssetImage('assets/photo/nenapp20.gif'), ctx);
        precacheImage(const AssetImage('assets/photo/nenapp2.gif'), ctx);
        precacheImage(const AssetImage('assets/photo/modelGIF1.gif'), ctx);
      });
    });
    // Đồng bộ trạng thái dark mode toàn cục vào biến cục bộ cho nút chuyển chế độ
    _isNightMode = Sm.Session.instance.settings.isDarkMode;

    // Bắt đầu phát nhạc nền sau một khoảng ngắn để tránh giật
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (Sm.Session.instance.settings.soundEnabled) {
        SoundManager().startBackgroundMusic(isNightMode: _isNightMode);
      }
    });
  }

  Future<void> _handleLogin() async {
    final u = _usernameController.text.trim();
    final p = _passwordController.text;
    final ok = await _auth.login(u, p);
    if (!mounted) return;
    if (ok) {
      // Route back to Splash so it can decide InitialName vs Menu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản hoặc mật khẩu không đúng!')),
      );
    }
  }

  Future<void> _toggleMode() async {
    // Cập nhật state cục bộ để UI đổi màu ngay
    setState(() => _isNightMode = !_isNightMode);

    // Cập nhật settings toàn cục để AppBackground và màn hình khác phản ứng
    final settings = Sm.Session.instance.settings;
    settings.themeMode = _isNightMode ? ThemeMode.dark : ThemeMode.light;
    await Sm.Session.instance.saveSettings();
    SettingsNotifier().notifySettingsChanged();

    // Đồng bộ nhạc nền theo chế độ mới
    SoundManager().toggleThemeMusic(_isNightMode);
  }

  // Debug methods removed for production

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        showModel: true,
        child: Stack(
          children: [
            // Logo thương hiệu ở giữa phía trên
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: const AppBrand(size: 28, color: Colors.white),
                ),
              ),
            ),
            // Form đăng nhập (responsive, cuộn được để tránh tràn)
            Align(
              alignment: Alignment.center,
              child: SafeArea(
                minimum: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 56, bottom: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: LoginForm(
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        isNightMode: _isNightMode,
                        onLogin: _handleLogin,
                        onRegister: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Nút chuyển chế độ sáng/tối đặt ở góc trái phía dưới
            Align(
              alignment: Alignment.bottomLeft,
              child: SafeArea(
                minimum: const EdgeInsets.all(12),
                child: ModeSwitch(
                  isNightMode: _isNightMode,
                  onToggle: _toggleMode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
