import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/game_basic_screen.dart';
import '../screens/ranking_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/app_background.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../session/session_manager.dart';
import '../utils/settings_notifier.dart';
import '../widgets/app_brand.dart';
import '../managers/sound_manager.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  StreamSubscription<void>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for settings changes
    _settingsSubscription = SettingsNotifier().settingsChanged.listen((_) {
      // Rebuild UI when settings change
      if (mounted) {
        setState(() {});
      }
    });
    // Ensure theme music is playing when entering menu
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isDark = Session.instance.settings.isDarkMode;
      await SoundManager().startBackgroundMusic(isNightMode: isDark);
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Session.instance.settings;
    final fontSize = settings.fontSize;
    final playerName = Session.instance.playerName;
    final isDark = settings.isDarkMode;
    
    // Theme-aware colors
    final formColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF22B8B1);
    final borderColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    final textColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: formColor,
                    border: Border.all(color: borderColor, width: 6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const AppBrand(size: 26),
                  const SizedBox(height: 12),
                  
                  // Hiển thị tên player
                  Text(
                    'Chào $playerName!',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize + 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _menuButton(
                    context,
                    label: 'Chơi ngay',
                    onPressed: () {
                      // Dùng tên từ Session, không cần nhập lại
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameBasicScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _menuButton(
                    context,
                    label: 'Bảng xếp hạng',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RankingScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _menuButton(
                    context,
                    label: 'Cài đặt',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _menuButton(
                    context,
                    label: 'Thoát game',
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Center(
                            child: Text(
                              'Thoát game',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                fontSize: fontSize + 2,
                              ),
                            ),
                          ),
                          content: Text(
                            'Bạn có chắc muốn thoát game và đăng xuất không?',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor, fontSize: fontSize),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Hủy', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: fontSize)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Thoát', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: fontSize)),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        // Xóa hoàn toàn trạng thái đăng nhập
                        await AuthService().logout();
                        
                        // Clear session data
                        Session.instance.reset();
                        
                        // Giữ player name để không phải nhập lại sau khi đăng nhập lại
                        
                        // Navigate to LoginScreen
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    final settings = Session.instance.settings;
    final fontSize = settings.fontSize;
    final isDark = settings.isDarkMode;
    
    // Theme-aware button colors
    final buttonBg = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    final buttonText = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF00E5FF);
    final buttonBorder = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF00E5FF);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: buttonBorder, width: 2),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: buttonText,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
