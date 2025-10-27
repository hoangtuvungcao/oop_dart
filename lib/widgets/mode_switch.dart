import 'package:flutter/material.dart';

class ModeSwitch extends StatelessWidget {
  final bool isNightMode;
  final VoidCallback onToggle;
  const ModeSwitch({super.key, required this.isNightMode, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    // Bộ màu sử dụng cho chế độ ngày và chế độ đêm
    const dayFormColor = Color(0xFF22B8B1);
    const dayBorderColor = Color(0xFF003366);
    const nightFormColor = Color(0xFF003366);
    const nightBorderColor = Color(0xFF00E5FF);

    // Chọn màu hiển thị theo trạng thái hiện tại
    final formColor = isNightMode ? nightFormColor : dayFormColor;
    final borderColor = isNightMode ? nightBorderColor : dayBorderColor;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut, // Thêm hiệu ứng chuyển động mượt mà
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: formColor,
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: Row(
          children: [
            // Vùng hiển thị biểu tượng mặt trời (chế độ ngày)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2.0),
                  color: !isNightMode ? dayFormColor : nightFormColor,
                ),
                child: Center(
                  child: Icon(Icons.wb_sunny,
                      color: !isNightMode ? Colors.amber : Colors.grey,
                      size: 24),
                ),
              ),
            ),
            // Vùng hiển thị biểu tượng mặt trăng (chế độ đêm)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2.0),
                  color: isNightMode ? nightFormColor : dayFormColor,
                ),
                child: Center(
                  child: Icon(Icons.nights_stay,
                      color: isNightMode ? Colors.blueAccent : Colors.grey,
                      size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
