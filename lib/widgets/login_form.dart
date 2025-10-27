import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isNightMode;
  final VoidCallback onLogin;
  final VoidCallback? onRegister;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isNightMode,
    required this.onLogin,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    // Bảng màu sử dụng khi đang ở chế độ ngày
    const dayFormColor = Color(0xFF22B8B1);
    const dayBorderColor = Color(0xFF003366);
    const dayLabelColor = Color(0xFF003366);
    const dayInputColor = Color(0xFF000000);
    const dayLinkColor = Color(0xFF000000);
    // Bảng màu sử dụng khi chuyển sang chế độ đêm
    const nightFormColor = Color(0xFF003366);
    const nightBorderColor = Color(0xFF00E5FF);
    const nightLabelColor = Color(0xFF00E5FF);
    const nightInputColor = Color(0xFFFFFFFF);
    const nightLinkColor = Color(0xFF00E5FF);

    // Chọn bộ màu phù hợp theo trạng thái hiện tại
    final formColor = isNightMode ? nightFormColor : dayFormColor;
    final borderColor = isNightMode ? nightBorderColor : dayBorderColor;
    final labelColor = isNightMode ? nightLabelColor : dayLabelColor;
    final inputColor = isNightMode ? nightInputColor : dayInputColor;
    final linkColor = isNightMode ? nightLinkColor : dayLinkColor;
    // Màu chữ hiển thị trên nút đăng nhập
    final buttonTextColor = const Color(0xFF00E5FF);
    // Màu viền bên ngoài nút đăng nhập
    final buttonBorderColor = isNightMode ? dayBorderColor : nightBorderColor;
    // Màu nền của nút đăng nhập để tạo độ tương phản tốt
    final buttonBgColor = isNightMode ? nightFormColor : dayBorderColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: formColor,
            border: Border.all(color: borderColor, width: 5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField('Tài khoản:',
                  controller: usernameController,
                  labelColor: labelColor,
                  inputColor: inputColor,
                  autofocus: true),
              const SizedBox(height: 16),
              _buildTextField('Mật khẩu:',
                  controller: passwordController,
                  isPassword: true,
                  labelColor: labelColor,
                  inputColor: inputColor),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
           width: 150, // Chiều rộng mong muốn
          child: ElevatedButton(
          onPressed: onLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBgColor,
            foregroundColor: buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: buttonBorderColor,
                width: 3.0,
              ),
            ),
            minimumSize: const Size(double.infinity, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            'Đăng nhập',
            style: TextStyle(
              color: buttonTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ),
        ),
        const SizedBox(height: 8),
        if (onRegister != null)
          SizedBox(
            width: 200, // Chiều rộng mong muốn
            child: OutlinedButton(
              onPressed: onRegister,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonBorderColor, width: 2.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                foregroundColor: linkColor,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Đăng ký tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(String label,
      {bool isPassword = false,
      bool autofocus = false,
      required TextEditingController controller,
      required Color labelColor,
      required Color inputColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: labelColor, fontWeight: FontWeight.bold)),
        Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: labelColor, width: 1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            autofocus: autofocus,
            style: TextStyle(color: inputColor),
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
