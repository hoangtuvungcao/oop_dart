// GameBasicScreen
// Stage 1 placeholder for gameplay screen with pixel UI.
// Shows a top bar (player/level/score/timer) and a static grid of cards.
// Stage 2 will add: card flip logic, timer, scoring, helps, bombs, animations.
// Import thư viện Flutter Material Design
import 'package:flutter/material.dart';
// Import controller điều khiển game
import '../game/controller.dart';
// Import widget background
import '../widgets/app_background.dart';
// Import widget game card
import '../widgets/game_card.dart';
// Import các model của game
import '../game/models.dart';
// Import builder level
import '../game/level_builder.dart';
// Import session manager
import '../session/session_manager.dart' as SessionManager;
// Import sound manager
import '../managers/sound_manager.dart';

// Class screen chính cho gameplay
class GameBasicScreen extends StatefulWidget {
  const GameBasicScreen({super.key, this.startLevel = 1});

  final int startLevel; // Level bắt đầu chơi

  @override
  State<GameBasicScreen> createState() => _GameBasicScreenState();
}

class _GameBasicScreenState extends State<GameBasicScreen> {
  late final GameRuntimeController _controller; // Controller điều khiển game
  late LevelModel _level; // Model level hiện tại

  /// Top bar color
  static const Color dayFormColor = Color(0xFF22B8B1);

  /// Top bar border color
  static const Color dayBorderColor = Color(0xFF003366);

  /// Đồng bộ không còn cần thiết khi dùng SessionManager duy nhất
  void _syncPlayerToOldSession() {}

  @override
  void initState() {
    super.initState();

    // Đồng bộ player từ session mới sang session cũ
    _syncPlayerToOldSession();

    _controller = GameRuntimeController(
      settings: SessionManager.Session.I.settings,
      leaderboard: SessionManager.Session.I.leaderboard,
    );
    _controller.onUpdate = () => mounted ? setState(() {}) : null;
    _controller.onFinished = () {
      if (!mounted) return;
      if (_controller.lastWon) {
        // Thắng: tự động sang level tiếp theo sau 1000ms
        final nextLv = _level.levelNumber + 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: dayFormColor,
            content: Text(
                'Hoàn thành Level ${_level.levelNumber}!\n'
                'Đang chuyển sang level tiếp theo... $nextLv...',
                style: const TextStyle(
                    color: dayBorderColor, fontWeight: FontWeight.bold)),
            duration: const Duration(milliseconds: 700),
          ),
        );
        Future.delayed(
            const Duration(milliseconds: 1000), () => _startLevel(nextLv));
      } else {
        // Thua: hiện Game Over
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: dayFormColor,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: dayBorderColor, width: 4),
            ),
            title: Center(
              child: Text(
                'Kết thúc trò chơi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dayBorderColor,
                  fontWeight: FontWeight.w900,
                  fontSize: SessionManager.Session.I.settings.fontSize + 4,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                'Điểm: ${_controller.score}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dayBorderColor,
                  fontWeight: FontWeight.w600,
                  fontSize: SessionManager.Session.I.settings.fontSize + 0,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startLevel(_level.levelNumber); // chơi lại
                },
                child: Text(
                  'Chơi lại',
                  style: TextStyle(
                    color: dayBorderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: SessionManager.Session.I.settings.fontSize,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Ensure gameplay audio stops before leaving to menu
                  SoundManager().stopAll();
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // back to menu
                },
                child: Text(
                  'Về menu',
                  style: TextStyle(
                    color: dayBorderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: SessionManager.Session.I.settings.fontSize,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    };
    _startLevel(widget.startLevel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startLevel(int levelNumber) {
    // Use LevelBuilder for consistent level configuration
    final levelBuilder = LevelBuilder();
    _level = levelBuilder.buildLevel(levelNumber);
    _controller.start(_level);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Stop any current audio immediately before leaving gameplay
        SoundManager().stopAll();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: dayBorderColor),
          title: null,
        ),
        extendBodyBehindAppBar: true,
        body: AppBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(
                        top: 72, left: 12, right: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: dayFormColor,
                      border: Border.all(color: dayBorderColor, width: 4),
                    ),
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _pill(
                              'Người chơi: ${SessionManager.Session.I.currentPlayer?.name ?? "?"}'),
                          const SizedBox(width: 8),
                          _pill('Lv: ${_level.levelNumber}'),
                          const SizedBox(width: 8),
                          _pill('Điểm: ${_controller.score}'),
                          const SizedBox(width: 8),
                          _pill(
                              'Thời gian: ${_formatTime(_controller.secondsLeft)}'),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dayBorderColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            onPressed: () async {
                              SoundManager().stopAll();
                              if (mounted) Navigator.of(context).pop();
                            },
                            child: const Text('Về menu',
                                style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: dayFormColor,
                        border: Border.all(color: dayBorderColor, width: 5),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const padding = 12.0;
                          const spacing = 12.0;
                          final total = _controller.cards.length;
                          final baseCols = 4 + ((_level.levelNumber - 1) ~/ 2);
                          final suggestedCols = baseCols.clamp(3, 8);
                          final gridW = constraints.maxWidth - padding * 2;
                          final maxColsByWidth =
                              (gridW / 72).floor().clamp(3, 10);
                          final cols = suggestedCols.clamp(3, maxColsByWidth);
                          final rows = (total / cols).ceil();
                          final gridH = constraints.maxHeight - padding * 2;
                          // Compute sizes to honor original childAspectRatio clamp(0.6..1.2)
                          final tileW0 = (gridW - (cols - 1) * spacing) / cols;
                          final maxTileHByHeight =
                              (gridH - (rows - 1) * spacing) / rows;
                          final aspect =
                              ((tileW0 / maxTileHByHeight)).clamp(0.6, 1.2);
                          double tileW = tileW0;
                          double desiredTileH = tileW / aspect;
                          double tileH;
                          if (desiredTileH > maxTileHByHeight) {
                            tileH = maxTileHByHeight;
                            tileW = tileH * aspect;
                          } else {
                            tileH = desiredTileH;
                          }
                          final contentW = cols * tileW + (cols - 1) * spacing;
                          final contentH = rows * tileH + (rows - 1) * spacing;
                          final originLeft = (gridW - contentW) / 2;
                          final originTop = (gridH - contentH) / 2;

                          return Padding(
                            padding: const EdgeInsets.all(padding),
                            child: SizedBox(
                              width: gridW,
                              height: gridH,
                              child: Stack(
                                children: [
                                  for (int i = 0; i < total; i++)
                                    _buildAnimatedCard(
                                      index: i,
                                      cols: cols,
                                      spacing: spacing,
                                      tileW: tileW,
                                      tileH: tileH,
                                      originLeft: originLeft,
                                      originTop: originTop,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _button(' +10s ',
                            onPressed: _controller.canUseHelp
                                ? () => _controller.addExtraTimeHelp()
                                : null),
                        _button('Mở hết 3s',
                            onPressed: _controller.canUseHelp
                                ? () => _controller.showAllHelp()
                                : null),
                        _button('Xoá bomb',
                            onPressed: (_controller.canUseHelp &&
                                    _level.levelNumber >= 4)
                                ? () => _controller.removeOneBombHelp()
                                : null),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required int index,
    required int cols,
    required double spacing,
    required double tileW,
    required double tileH,
    required double originLeft,
    required double originTop,
  }) {
    final row = (index / cols).floor();
    final col = index % cols;
    final left = originLeft + col * (tileW + spacing);
    final top = originTop + row * (tileH + spacing);
    final card = _controller.cards[index];
    return AnimatedPositioned(
      key: ValueKey(card.id),
      duration: _controller.shuffling
          ? const Duration(milliseconds: 3000)
          : Duration.zero,
      curve: Curves.easeInOut,
      left: left,
      top: top,
      width: tileW,
      height: tileH,
      child: RepaintBoundary(
        child: GameCard(
          card: card,
          isFaceUp: card.isFaceUp,
          isPreviewing: _controller.previewing,
          onTap: () => _controller.flip(index),
          enabled: !_controller.previewing && !_controller.shuffling,
        ),
      ),
    );
  }

  Widget _pill(String text) {
    final fontSize = SessionManager.Session.I.settings.fontSize;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: dayBorderColor, width: 3),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: dayBorderColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize - 2),
      ),
    );
  }

  Widget _button(String text, {VoidCallback? onPressed}) {
    final fontSize = SessionManager.Session.I.settings.fontSize;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: dayBorderColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
        ),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
              color: Color(0xFF00E5FF),
              fontWeight: FontWeight.bold,
              fontSize: fontSize - 2)),
    );
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return '${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }
}
