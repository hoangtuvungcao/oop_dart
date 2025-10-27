// Bảng xếp hạng top 5 players

import 'package:flutter/material.dart';
import 'dart:async';
import '../session/session_manager.dart';
import '../widgets/app_background.dart';
import '../utils/settings_notifier.dart';
import '../repositories/leaderboard_repository.dart';
import '../widgets/app_brand.dart';

// Use RankItem from repository

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription<void>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen for settings changes
    _settingsSubscription = SettingsNotifier().settingsChanged.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Session.instance.settings;
    final fontSize = settings.fontSize;
    final isDark = settings.isDarkMode;
    
    // Theme-aware colors
    final formColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF22B8B1);
    final borderColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);
    final textColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF003366);

    // Get lists from repository (encapsulates merge + sort)
    final repo = const LeaderboardRepository();
    final byScoreTop5 = repo.topByScore(limit: 5);
    final byLevelTop5 = repo.topByLevel(limit: 5);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: borderColor),
        title: BrandTitle(color: textColor),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: textColor,
          unselectedLabelColor: textColor.withOpacity(0.6),
          indicatorColor: borderColor,
          tabs: [
            Tab(
              child: Text(
                'Top 5 Điểm',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            Tab(
              child: Text(
                'Top 5 Level',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              margin: const EdgeInsets.only(top: 120),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: formColor,
                border: Border.all(color: borderColor, width: 5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 450,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRankingList(
                      byScoreTop5,
                      'điểm',
                      (item) => item.score,
                      textColor,
                      borderColor,
                      fontSize,
                    ),
                    _buildRankingList(
                      byLevelTop5,
                      'level',
                      (item) => item.highestLevel,
                      textColor,
                      borderColor,
                      fontSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build ranking list với top 5
  Widget _buildRankingList(
    List<RankItem> items,
    String sortType,
    int Function(RankItem) getValue,
    Color textColor,
    Color borderColor,
    double fontSize,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: textColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu xếp hạng',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: fontSize,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chơi game để xuất hiện trong bảng xếp hạng!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: fontSize - 2,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final player = items[index];
        final rank = index + 1;
        final value = getValue(player);
        
        return _buildRankingItem(
          rank: rank,
          player: player,
          value: value,
          sortType: sortType,
          textColor: textColor,
          borderColor: borderColor,
          fontSize: fontSize,
        );
      },
    );
  }

  /// Build từng item trong ranking
  Widget _buildRankingItem({
    required int rank,
    required RankItem player,
    required int value,
    required String sortType,
    required Color textColor,
    required Color borderColor,
    required double fontSize,
  }) {
    // Medal colors cho top 3
    Color? medalColor;
    IconData? medalIcon;
    
    switch (rank) {
      case 1:
        medalColor = const Color(0xFFFFD700); // Gold
        medalIcon = Icons.emoji_events;
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0); // Silver
        medalIcon = Icons.emoji_events;
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32); // Bronze
        medalIcon = Icons.emoji_events;
        break;
      default:
        medalIcon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank <= 3 
            ? borderColor.withOpacity(0.1) 
            : Colors.transparent,
        border: Border.all(
          color: borderColor,
          width: rank == 1 ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Rank number và medal
          SizedBox(
            width: 50,
            child: Row(
              children: [
                Text(
                  '$rank.',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize + (rank == 1 ? 2 : 0),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  medalIcon,
                  color: medalColor ?? textColor,
                  size: 20 + (rank == 1 ? 4 : 0),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player name
                Text(
                  player.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize + (rank == 1 ? 1 : 0),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Stats
                Row(
                  children: [
                    // Primary stat (điểm hoặc level)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$sortType: $value',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize - 1,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Secondary stats
                    Text(
                      sortType == 'điểm' 
                          ? 'Level: ${player.highestLevel}'
                          : 'Điểm: ${player.score}',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: fontSize - 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Performance indicator
          if (rank == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'TOP 1',
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize - 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
