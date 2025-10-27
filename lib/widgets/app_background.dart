import 'package:flutter/material.dart';
import 'dart:async';
import '../session/session_manager.dart';
import '../utils/settings_notifier.dart';

/// Widget nền tái sử dụng để đồng bộ giao diện toàn app (giống màn đăng nhập)
/// - Hiển thị GIF theo theme (ngày/đêm), có thể phủ lớp tối và hình nhân vật
/// - Đặt nội dung màn hình trong tham số `child`
/// - Tự động cập nhật khi người dùng đổi theme
class AppBackground extends StatefulWidget {
  const AppBackground({super.key, required this.child, this.showModel = true});

  final Widget child;
  final bool showModel;

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> {
  StreamSubscription<void>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi settings để cập nhật nền kịp thời
    _settingsSubscription = SettingsNotifier().settingsChanged.listen((_) {
      if (mounted) {
        setState(() {}); // Rebuild khi settings thay đổi
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNight = Session.instance.settings.isDarkMode;
    final size = MediaQuery.of(context).size;
    // Tính kích thước decode mục tiêu nhằm giảm tải bộ nhớ/CPU cho GIF lớn
    final targetW = size.width.isFinite ? size.width.clamp(320, 1920).toInt() : 1280;
    final targetH = size.height.isFinite ? size.height.clamp(320, 1080).toInt() : 720;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Màu nền dự phòng nếu GIF không decode được
        Positioned.fill(child: Container(color: Colors.black)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Image.asset(
            isNight ? 'assets/photo/nenapp2.gif' : 'assets/photo/nenapp20.gif',
            key: ValueKey(isNight),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            cacheWidth: targetW,
            cacheHeight: targetH,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isNight ? 0.6 : 0.0,
          child: Container(color: Colors.black),
        ),
        if (widget.showModel && size.width > 600)
          Positioned(
            top: 80,
            left: -100,
            child: Image.asset(
              'assets/photo/modelGIF1.gif',
              width: 360,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
            ),
          ),
        Center(child: widget.child),
      ],
    );
  }
}
