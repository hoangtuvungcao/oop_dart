import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/app_background.dart';
import '../session/session_manager.dart';
import '../managers/sound_manager.dart';
import '../models/settings_model.dart';
import '../utils/settings_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsModel _settings;
  StreamSubscription<void>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _settings = Session.instance.settings;
    
    // Listen for settings changes để rebuild UI
    _settingsSubscription = SettingsNotifier().settingsChanged.listen((_) {
      if (mounted) {
        setState(() {
          _settings = Session.instance.settings; // Refresh settings
        });
      }
    });
  }
  
  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  void _updateTheme(ThemeMode? mode) async {
    if (mode == null) return;
    setState(() {
      _settings.themeMode = mode;
    });
    
    // Save settings to storage
    await Session.instance.saveSettings();
    
    // Notify other screens about settings change
    SettingsNotifier().notifySettingsChanged();
    
    // Toggle background music based on theme via SoundManager (single source of truth)
    final isNight = mode == ThemeMode.dark;
    await SoundManager().toggleThemeMusic(isNight);
  }

  void _updateSound(bool enabled) async {
    setState(() {
      _settings.soundEnabled = enabled;
    });
    
    // Save settings to storage
    await Session.instance.saveSettings();
    
    // Notify other screens about settings change
    SettingsNotifier().notifySettingsChanged();

    // Apply sound enabled/disabled to SoundManager
    await SoundManager().setSoundEnabled(
      enabled,
      isNightMode: Session.instance.settings.isDarkMode,
    );
  }

  void _updateFontSize(double size) async {
    setState(() {
      _settings.fontSize = size;
    });
    
    // Save settings to storage
    await Session.instance.saveSettings();
    
    // Notify other screens about settings change
    SettingsNotifier().notifySettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.isDarkMode;
    final fontSize = _settings.fontSize;
    
    // Theme-aware colors
    final formColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF22B8B1);
    final borderColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    final textColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: borderColor),
        title: Text('Cài đặt', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth > 640 ? 600 : maxWidth - 24),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: formColor,
                        border: Border.all(color: borderColor, width: 5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                  _section(title: 'Âm thanh', child: _toggleRow(
                    label: 'Bật/Tắt âm thanh',
                    value: _settings.soundEnabled,
                    onChanged: _updateSound,
                  )),
                  const SizedBox(height: 12),
                  _section(title: 'Giao diện', child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Chế độ hiển thị', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: fontSize)),
                      DropdownButton<ThemeMode>(
                        value: _settings.themeMode,
                        items: [
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Sáng', style: TextStyle(fontSize: _settings.fontSize))),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Tối', style: TextStyle(fontSize: _settings.fontSize))),
                          DropdownMenuItem(value: ThemeMode.system, child: Text('Theo hệ thống', style: TextStyle(fontSize: _settings.fontSize))),
                        ],
                        onChanged: _updateTheme,
                      )
                    ],
                  )),
                  const SizedBox(height: 12),
                  _section(title: 'Cỡ chữ', child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cỡ chữ', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: fontSize)),
                          Text('${fontSize.toInt()}', style: TextStyle(color: textColor, fontSize: fontSize)),
                        ],
                      ),
                      Slider(
                        min: 12,
                        max: 24,
                        divisions: 12,
                        value: _settings.fontSize,
                        onChanged: _updateFontSize,
                      ),
                    ],
                  )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    final isDark = _settings.isDarkMode;
    final sectionBg = isDark ? const Color(0xFF0D1B2A) : const Color(0xFF16A085);
    final sectionBorder = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    final sectionText = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sectionBg,
        border: Border.all(color: sectionBorder, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(
              color: sectionText, 
              fontWeight: FontWeight.w900, 
              fontSize: _settings.fontSize + 2,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _toggleRow({required String label, required bool value, required ValueChanged<bool> onChanged}) {
    final isDark = _settings.isDarkMode;
    final textColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold, 
            fontSize: _settings.fontSize,
          ),
        ),
        Switch(
          value: value, 
          onChanged: onChanged,
          activeColor: isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366),
        ),
      ],
    );
  }
}
