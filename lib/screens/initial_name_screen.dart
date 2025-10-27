 ///Màn hình nhập tên người chơi lần đầu

import 'package:flutter/material.dart';
import '../session/session_manager.dart';
import '../screens/menu_screen.dart';
import '../widgets/app_background.dart';

/// `InitialNameScreen` - màn hình yêu cầu nhập tên trước khi vào menu chính
class InitialNameScreen extends StatefulWidget {
  const InitialNameScreen({super.key});

  @override
  State<InitialNameScreen> createState() => _InitialNameScreenState();
}

class _InitialNameScreenState extends State<InitialNameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Kiểm tra tính hợp lệ của tên và lưu lại vào storage
  Future<void> _confirm() async {
    final name = _controller.text.trim();
    
    // Kiểm tra tên không được để trống
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bạn!')),
      );
      return;
    }
    
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên phải có ít nhất 2 ký tự!')),
      );
      return;
    }
    
    try {
      // Kiểm tra xem tên đã có người dùng chưa
      final isTaken = await Session.instance.isPlayerNameTaken(name);
      if (isTaken) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tên "$name" đã được sử dụng! Vui lòng chọn tên khác.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Lưu tên mới vào `Session` và storage
      await Session.instance.setInitialPlayerName(name);
      
      // Chuyển sang `MenuScreen`
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu tên: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Session.instance.settings.fontSize;
    const dayFormColor = Color(0xFF22B8B1);
    const dayBorderColor = Color(0xFF003366);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chào mừng!',
          style: TextStyle(
            color: dayBorderColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize + 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Ẩn nút back để buộc phải nhập tên
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: dayFormColor,
              border: Border.all(color: dayBorderColor, width: 5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề chào mừng
                Text(
                  'Chào mừng đến với\nBậc Thầy Trí Tuệ!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dayBorderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize + 4,
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Vui lòng nhập tên của bạn:',
                  style: TextStyle(
                    color: dayBorderColor,
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Ô nhập tên người chơi
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: dayBorderColor, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dayBorderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize + 2,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nhập tên của bạn...',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    onSubmitted: (_) => _confirm(),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Nút xác nhận tên
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dayBorderColor,
                      foregroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
                      ),
                    ),
                    onPressed: _confirm,
                    child: Text(
                      'Bắt đầu chơi!',
                      style: TextStyle(
                        color: const Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize + 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Thông tin nhắc nhở thêm cho người chơi
                Text(
                  'Tên này sẽ được lưu và hiển thị trong bảng xếp hạng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dayBorderColor.withOpacity(0.7),
                    fontSize: fontSize - 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
