// Màn hình nhập tên người chơi


import 'package:flutter/material.dart';
import '../session/session.dart';
import '../screens/game_basic_screen.dart';
import '../widgets/app_background.dart';


class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Clean up controller
    super.dispose();       // Call parent dispose
  }

  void _confirm() {

    final name = _controller.text.trim();

    if (name.isEmpty) {
      // Show error message
      // ScaffoldMessenger = service hiển thị SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên!')),
      );
      return; // Dừng execution, không navigate
    }
    

    Session.I.setPlayerName(name);
    

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameBasicScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const dayFormColor = Color(0xFF22B8B1);
    const dayBorderColor = Color(0xFF003366);
    final fontSize = Session.I.settings.fontSize;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: dayBorderColor),
        title: Text('Nhập tên người chơi', style: TextStyle(color: dayBorderColor, fontWeight: FontWeight.bold, fontSize: fontSize)),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dayFormColor,
            border: Border.all(color: dayBorderColor, width: 5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Tên người chơi:', style: TextStyle(color: dayBorderColor, fontWeight: FontWeight.bold, fontSize: fontSize)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: dayBorderColor, width: 2),
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: dayBorderColor, fontWeight: FontWeight.w600, fontSize: fontSize),
                  cursorColor: dayBorderColor,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dayBorderColor,
                    foregroundColor: Color(0xFF00E5FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
                    ),
                  ),
                  onPressed: _confirm,
                  child: Text('Xác nhận', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: fontSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
