//Màn hình đăng ký tài khoản mới
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';
import '../session/session.dart';
import '../screens/initial_name_screen.dart';

/// `RegisterScreen` - sử dụng state để quản lý form đăng ký
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// State điều khiển các controller và xử lý đăng ký
class _RegisterScreenState extends State<RegisterScreen> {
  // ----------------------------- CONTROLLERS -----------------------------
  /// Controller cho ô nhập tài khoản
  final _usernameController = TextEditingController();

  /// Controller cho ô nhập mật khẩu
  final _passwordController = TextEditingController();

  // ------------------------------ LIFECYCLE ------------------------------
  /// Giải phóng controller khi widget bị huỷ
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------------------- XỬ LÝ ĐĂNG KÝ ---------------------------
  /// Thực hiện đăng ký tài khoản mới với các bước kiểm tra cần thiết
  Future<void> _register() async {
    // Lấy dữ liệu và loại bỏ khoảng trắng dư thừa ở username
    final username = _usernameController.text.trim();
    final password = _passwordController.text; // Mật khẩu giữ nguyên

    // Kiểm tra xem đã nhập đủ thông tin chưa
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    // Gọi AuthService để đăng ký (đồng thời lưu vào StorageManager)
    final success = await AuthService().register(username, password);

    // Xử lý kết quả đăng ký
    if (success) {
      // Thành công → thông báo và chuyển tới màn nhập tên
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng nhập tên của bạn.')),
        );
        
        // Điều hướng sang `InitialNameScreen` thay vì quay lại login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InitialNameScreen()),
        );
      }
    } else {
      // Thất bại (username đã tồn tại hoặc không hợp lệ)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tên đăng nhập đã tồn tại hoặc không hợp lệ!')),
        );
      }
    }
  }

  // ----------------------------- XÂY DỰNG UI -----------------------------
  /// Giao diện gồm nền GIF, form đăng ký và liên kết trở lại màn đăng nhập
  @override
  Widget build(BuildContext context) {
    // Colors theo theme hiện tại
    final fontSize = Session.I.settings.fontSize;
    const dayFormColor = Color(0xFF22B8B1);
    const dayBorderColor = Color(0xFF003366);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: dayBorderColor),
        title: Text(
          'Đăng ký',
          style: TextStyle(
            color: dayBorderColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dayFormColor,
              border: Border.all(color: dayBorderColor, width: 5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trường nhập tài khoản
                _buildLabel('Tài khoản', fontSize),
                _buildInput(_usernameController, fontSize),
                const SizedBox(height: 12),

                // Trường nhập mật khẩu
                _buildLabel('Mật khẩu', fontSize),
                _buildInput(_passwordController, fontSize, obscure: true),
                const SizedBox(height: 16),

                // Nút tạo tài khoản
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dayBorderColor,
                      foregroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: Color(0xFF00E5FF), width: 2),
                      ),
                    ),
                    onPressed: _register,
                    child: Text(
                      'Tạo tài khoản',
                      style: TextStyle(
                        color: const Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Liên kết quay lại màn đăng nhập
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Đã có tài khoản? Đăng nhập',
                      style: TextStyle(
                        color: dayBorderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize - 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================

  /// Tạo label cho ô nhập liệu với font theo settings
  Widget _buildLabel(String text, double fontSize) {
    const labelColor = Color(0xFF003366);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  /// Tạo TextField với viền pixel; `obscure` quyết định hiển thị ký tự mật khẩu
  Widget _buildInput(
    TextEditingController controller,
    double fontSize, {
    bool obscure = false,
  }) {
    const dayBorderColor = Color(0xFF003366);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: dayBorderColor, width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          color: dayBorderColor,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
        cursorColor: dayBorderColor,
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
