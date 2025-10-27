import 'package:flutter/material.dart';

/// `AppBrand` - widget hiển thị thương hiệu game (icon + tên)
class AppBrand extends StatelessWidget {
  const AppBrand({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Màu thương hiệu mặc định: dark mode → vàng nhạt, light mode → hồng nhạt
    final defaultColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF4EB87)
        : const Color(0xFFFF8FA3);
    final effectiveColor = color ?? defaultColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo game: ưu tiên PNG, fallback ICO, cuối cùng là icon Material
        Image.asset(
          'assets/photo/icon.png',
          width: size + 6,
          height: size + 6,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/photo/icon.ico',
            width: size + 6,
            height: size + 6,
            errorBuilder: (_, __, ___) => Icon(Icons.videogame_asset, color: effectiveColor, size: size + 4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Bậc Thầy Trí Tuệ',
          style: TextStyle(
            color: effectiveColor,
            fontWeight: FontWeight.w900,
            fontSize: size,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// `BrandTitle` - phiên bản rút gọn dùng trong AppBar
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppBrand(size: 20, color: color);
  }
}
