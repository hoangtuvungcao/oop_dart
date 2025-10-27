// Màn hình khởi động và điều hướng ban đầu
import 'package:flutter/material.dart';
import '../session/session_manager.dart';
import '../screens/initial_name_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';

/// `SplashScreen` - chịu trách nhiệm kiểm tra trạng thái và điều hướng khi app khởi động
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPlayerAndRoute();
  }

  /// Kiểm tra trạng thái đăng nhập + tên người chơi để điều hướng hợp lý
  Future<void> _checkPlayerAndRoute() async {
    // Chờ 1s để người dùng thấy hiệu ứng splash
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // Bước 1: kiểm tra trạng thái đăng nhập
      final currentUser = await AuthService().getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      // Bước 2: nếu đã đăng nhập thì kiểm tra xem đã lưu tên người chơi chưa
      final hasName = await Session.instance.hasPlayerName();
      if (mounted) {
        if (hasName) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InitialNameScreen()),
          );
        }
      }
    } catch (e) {
      print('Error checking player name: $e');
      
      // Nếu có lỗi, quay lại LoginScreen làm mặc định
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const dayBorderColor = Color(0xFF003366);
    
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/tiêu đề ứng dụng
              Text(
                'Bậc Thầy Trí Tuệ',
                style: TextStyle(
                  color: dayBorderColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              
              // Vòng tròn loading trong lúc kiểm tra
              const CircularProgressIndicator(
                color: dayBorderColor,
              ),
              const SizedBox(height: 20),
              
              Text(
                'Đang khởi động...',
                style: TextStyle(
                  color: dayBorderColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
