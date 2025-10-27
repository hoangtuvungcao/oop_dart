import 'package:flutter/material.dart'; // Import thư viện Flutter cơ bản

import 'dart:math' as math; // Import thư viện math với alias để sử dụng các hàm toán học như pi
import '../models/card_model.dart'; // Import model thẻ riêng biệt
import '../config/game_config.dart'; // Import cấu hình game

/// GameCard - widget thẻ bài tái sử dụng với hiệu ứng lật 3D
/// Hiển thị nội dung thẻ (ảnh, bom hoặc mặt sau) với animation mượt mà
class GameCard extends StatelessWidget {
  final CardBase card; // Thẻ bài cần hiển thị
  final bool isFaceUp; // Có đang lật mặt trước không
  final bool isPreviewing; // Có đang trong giai đoạn xem trước không
  final VoidCallback onTap; // Callback khi nhấn vào thẻ
  final bool enabled; // Có cho phép tương tác không
  
  const GameCard({
    super.key,
    required this.card,
    required this.isFaceUp,
    required this.isPreviewing,
    required this.onTap,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final shouldShowFace = isFaceUp || card.isMatched || isPreviewing; // Quyết định hiển thị mặt trước hay sau
    final isBomb = card is BombCard; // Kiểm tra có phải bom không
    
    // Xác định màu nền dựa trên trạng thái thẻ hiện tại
    final backgroundColor = _getBackgroundColor(isBomb);
    
    return GestureDetector(
      onTap: enabled ? onTap : null, // Xử lý nhấn
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: GameConfig.cardFlipDuration), // Thời gian lật
        tween: Tween<double>(begin: 0, end: shouldShowFace ? 1 : 0), // Animation tween
        curve: Curves.easeInOut, // Đường cong animation
        builder: (context, value, child) {
          // Tính góc xoay (0 đến π rad ~ 180°)
          final angle = value * math.pi;
          
          // Quyết định hiển thị mặt trước hay mặt sau dựa trên góc xoay
          final showFront = value > 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Tạo cảm giác chiều sâu
              ..rotateY(angle), // Xoay theo trục Y
            child: Transform(
              alignment: Alignment.center,
              transform: _buildInnerTransform(angle),
              child: _buildCardContent(
                showFront: showFront,
                backgroundColor: backgroundColor,
                isBomb: isBomb,
              ),
            ),
          );
        },
      ),
    );
  }

  Matrix4 _buildInnerTransform(double angle) {
    if (angle > math.pi / 2) {
      return Matrix4.identity()..rotateY(math.pi);
    }
    return Matrix4.identity();
  }
  
  /// Get background color based on card state
  Color _getBackgroundColor(bool isBomb) {
    if (card.isMatched) {
      return Color(GameConfig.cardMatchedColorValue); // Màu khi đã ghép
    }
    if (isBomb) {
      return Color(GameConfig.cardBombColorValue); // Màu bom
    }
    return Color(GameConfig.cardNormalColorValue); // Màu bình thường
  }
  
  /// Build card content (front or back)
  Widget _buildCardContent({
    required bool showFront,
    required Color backgroundColor,
    required bool isBomb,
  }) {
    const borderColor = Color(GameConfig.dayBorderColorValue);
    
    return Container(
      decoration: BoxDecoration(
        color: showFront ? backgroundColor : Color(GameConfig.cardBackColorValue),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: showFront ? _buildFrontFace(isBomb) : _buildBackFace(),
    );
  }
  
  /// Build front face (image or bomb)
  Widget _buildFrontFace(bool isBomb) {
    if (isBomb) {
      return _buildBombFace(); // Hiển thị bom
    }
    
    if (card is NormalCard) {
      final normalCard = card as NormalCard;
      if (normalCard.imagePath != null) {
        return Image.asset(
          normalCard.imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorPlaceholder(normalCard.pairId),
        ); // Hiển thị ảnh
      }
      return Center(
        child: Text(
          normalCard.pairId,
          style: const TextStyle(
            color: Color(GameConfig.dayBorderColorValue),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ); // Hiển thị text nếu không có ảnh
    }
    
    return const SizedBox.shrink(); // Trả về widget rỗng nếu không hợp lệ
  }
  
  /// Build bomb face
  Widget _buildBombFace() {
    if (card is BombCard && (card as BombCard).isDefused) {
      // Show defused bomb with different visual
      return Stack(
        children: [
          Image.asset(
            GameConfig.cardBombPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildBombPlaceholder(),
          ),
          // Add "DEFUSED" overlay
          Container(
            color: Colors.green.withOpacity(0.5),
            child: const Center(
              child: Text(
                'ĐÃ VÔ HIỆU',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ); // Hiển thị bom đã gỡ với overlay
    }
    
    return Image.asset(
      GameConfig.cardBombPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildBombPlaceholder(),
    ); // Hiển thị bom bình thường
  }
  
  /// Build back face
  Widget _buildBackFace() {
    return Image.asset(
      GameConfig.cardBackPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Color(GameConfig.cardBackColorValue),
        child: const Center(
          child: Icon(
            Icons.help_outline,
            color: Color(GameConfig.dayBorderColorValue),
            size: 32,
          ),
        ),
      ),
    ); // Hiển thị mặt sau thẻ
  }
  
  /// Build error placeholder for missing images
  Widget _buildErrorPlaceholder(String label) {
    return Container(
      color: Color(GameConfig.cardNormalColorValue),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(GameConfig.dayBorderColorValue),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ); // Placeholder khi lỗi ảnh
  }
  
  /// Build bomb placeholder
  Widget _buildBombPlaceholder() {
    return Container(
      color: Color(GameConfig.cardBombColorValue),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Color(GameConfig.dayBorderColorValue),
              size: 40,
            ),
            SizedBox(height: 4),
            Text(
              'BOMB',
              style: TextStyle(
                color: Color(GameConfig.dayBorderColorValue),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ); // Placeholder cho bom
  }
}
