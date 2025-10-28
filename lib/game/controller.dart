// Import thư viện async của Dart để sử dụng Timer và Future cho việc đếm thời gian và xử lý bất đồng bộ
import 'dart:async';

// Import thư viện math để sử dụng Random cho việc sinh số ngẫu nhiên
import 'dart:math';

// Import các model của game với alias GM
import '../game/models.dart' as GM;
import '../models/card_model.dart' as CM;

// Import SessionManager với alias Sm để quản lý phiên người chơi
import '../session/session_manager.dart' as Sm;

// Import SoundManager để quản lý âm thanh trong game
import '../managers/sound_manager.dart';

// Import GameConfig chứa các hằng số cấu hình game
import '../config/game_config.dart';

// Import SettingsModel với alias ST
import '../models/settings_model.dart' as ST;

// Import Leaderboard với alias LB
import '../models/leaderboard_model.dart' as LB;

// Import PlayRecord với alias PR
import '../models/play_record_model.dart' as PR;



// Lớp điều khiển logic chính của game, quản lý trạng thái, thẻ bài, thời gian, điểm số, v.v.
class GameRuntimeController {
  // Constructor khởi tạo với các tham số bắt buộc: settings và leaderboard
  GameRuntimeController(
      {required this.settings,
      required this.leaderboard}); // Khởi tạo controller điều khiển phiên chơi với cấu hình và bảng xếp hạng hiện tại

  // Thuộc tính final: cài đặt game hiện tại
  final ST.SettingsModel settings;

  // Thuộc tính final: bảng xếp hạng hiện tại
  final LB.Leaderboard leaderboard;

  // Thông tin trạng thái của phiên chơi hiện tại
  // Trạng thái hiện tại của game: idle (chưa bắt đầu), playing (đang chơi), finished (đã kết thúc)
  GM.GameState state = GM.GameState
      .idle; // Giá trị mặc định: chưa chơi, đang chơi hoặc đã kết thúc

  // Level hiện tại đang chơi (được khởi tạo sau)
  late GM.LevelModel level; // Level đang được chơi

  // Danh sách các thẻ bài trên bàn chơi
  late List<CM.CardBase> cards; // Danh sách thẻ có mặt trên bàn

  // Số giây còn lại để hoàn thành level
  int secondsLeft = 0; // Số giây còn lại để hoàn thành level

  // Điểm tích lũy của người chơi
  int score = 0; // Điểm tích lũy của người chơi trong game

  // Cờ đánh dấu đang trong giai đoạn xem trước thẻ
  bool previewing = false; // Đánh dấu đang trong giai đoạn xem trước thẻ

  // Cờ đánh dấu đang chạy animation xáo bài
  bool shuffling = false; // Đánh dấu đang chạy animation xáo bài

  // Số lượt trợ giúp đã sử dụng trong level hiện tại
  int helpsUsedThisLevel = 0; // Lượt trợ giúp đã dùng trong level hiện tại

  // Số giây bị phạt cho level tiếp theo
  int pendingNextLevelTimePenalty =
      0; // Lượng thời gian bị trừ khi bắt đầu level kế tiếp

  // Kết quả thắng/thua của level vừa hoàn thành
  bool lastWon = false; // Kết quả thắng/thua của level vừa hoàn thành

  // Biến nội bộ hỗ trợ xử lý logic
  // Bộ sinh số ngẫu nhiên dùng để xáo thẻ
  final _rand = Random(); // Bộ sinh số ngẫu nhiên dùng để xáo thẻ

  // Bộ đếm thời gian theo từng giây
  Timer? _timer; // Bộ đếm thời gian theo từng giây

  // Generation của việc xáo bài, dùng để tránh conflict
  int _shuffleGeneration = 0;

  // Số cặp đã ghép đúng
  int _matchedPairs = 0; // Số cặp đã được ghép đúng

  // Danh sách chỉ số các thẻ đang mở mặt
  final List<int> _flippedIndices = []; // Lưu vị trí các thẻ đang mở mặt

  // Điểm số tại thời điểm bắt đầu level
  int _scoreAtLevelStart = 0; // Điểm số tại thời điểm mở level

  // Callback để cập nhật UI mỗi khi dữ liệu thay đổi
  void Function()? onUpdate; // Callback để cập nhật UI mỗi khi dữ liệu thay đổi

  // Callback thông báo phiên chơi đã kết thúc
  void Function()? onFinished; // Callback thông báo phiên chơi đã kết thúc

  void dispose() {
    // Khi màn chơi kết thúc, dừng mọi hoạt động và khôi phục âm thanh
    state = GM.GameState.finished;
    previewing = false; // Không còn nằm trong giai đoạn xem trước
    _flippedIndices.clear(); // Đảm bảo không còn thẻ đang mở mặt
    _timer?.cancel(); // Hủy bộ đếm thời gian
    SoundManager().exitGameplayMusic(); // Tắt nhạc gameplay và trả về nhạc nền
  }

  // Khởi động một level mới
  void start(GM.LevelModel lvl) {
    // Lấy người chơi hiện tại từ session
    final player =
        Sm.Session.I.currentPlayer; // Lấy người chơi hiện tại nếu đã đăng nhập

    // Nếu chưa có người chơi, tạo một hồ sơ mặc định
    if (player == null) {
      // Nếu chưa có tên, tạo một hồ sơ mặc định để lưu tiến trình
      Sm.Session.I.setInitialPlayerName('Player');
    }

    // Gán level mới
    level = lvl;

    // Lưu điểm số hiện tại để tính phần thưởng sau level
    _scoreAtLevelStart = score; // Lưu lại điểm để tính phần thưởng sau level

    // Reset các biến cho level mới
    _matchedPairs = 0; // Reset số cặp đã ghép
    _flippedIndices.clear(); // Không có thẻ nào đang mở khi bắt đầu

    // Áp dụng thời gian còn lại, trừ đi hình phạt nếu có
    secondsLeft = max(
        0,
        level.timeLimit -
            pendingNextLevelTimePenalty); // Áp dụng hình phạt thời gian nếu có

    // Reset hình phạt sau khi áp dụng
    pendingNextLevelTimePenalty = 0; // Hình phạt được sử dụng xong

    // Reset số lượt trợ giúp
    helpsUsedThisLevel = 0; // Chưa dùng trợ giúp nào trong level mới

    // Chuẩn bị bộ ảnh để tạo thẻ cho level
    final images = _imagesForLevel(level.levelNumber);

    // Sinh các cặp thẻ thường
    final pairCount = (level.baseCardCount / 2).floor();
    final normals = <CM.NormalCard>[];
    for (int i = 0; i < pairCount; i++) {
      // Tạo mã định danh cho cặp
      final pairId = 'P$i'; // Mã định danh cho cặp thẻ

      // Chọn ảnh cho cặp
      final img = images[i % images.length]; // Ảnh sử dụng cho cặp

      // Thêm hai thẻ cùng cặp
      normals.add(CM.NormalCard(id: 'N${i}a', pairId: pairId, imagePath: img));
      normals.add(CM.NormalCard(id: 'N${i}b', pairId: pairId, imagePath: img));
    }

    // Sinh các thẻ bom theo cấu hình level
    final bombs = <CM.BombCard>[];
    for (int i = 0; i < level.bombsCount; i++) {
      bombs.add(CM.BombCard(id: 'B$i', penaltyTime: 10));
    }

    // Hợp nhất thẻ thường và thẻ bom
    cards = [...normals, ...bombs]; // Hợp nhất thẻ thường và thẻ bom

    // Cập nhật generation cho xáo bài
    _shuffleGeneration++;
    shuffling = false;

    // Chuyển trạng thái sang playing
    state = GM.GameState.playing; // Bắt đầu trạng thái chơi

    // Bắt đầu preview
    _preview(level.previewSeconds); // Hiển thị toàn bộ thẻ trong vài giây đầu

    // Bắt đầu timer
    _startTimer(); // Bắt đầu đếm thời gian

    // Thông báo UI cập nhật
    _notify(); // Thông báo UI cập nhật giao diện mới

    // Chờ một chút rồi chuyển nhạc
    Future.delayed(const Duration(milliseconds: 500), () {
      // Chờ UI ổn định trước khi chuyển nhạc nền sang gameplay
      if (state == GM.GameState.playing) {
        SoundManager().enterGameplayMusic(volume: 0.25);
      }
    });
  }

  // Hàm preview: hiển thị tất cả thẻ trong thời gian ngắn
  void _preview(int seconds) async {
    // Đánh dấu đang preview
    previewing = true; // Đánh dấu đang cho người chơi xem trước toàn bộ thẻ

    // Clear flipped indices để không tính vào logic ghép cặp
    _flippedIndices
        .clear(); // Không coi những thẻ này là đã mở để tính logic ghép cặp

    // Lật tất cả thẻ lên
    for (final c in cards) {
      c.isFaceUp = true; // Lật toàn bộ thẻ lên
    }
    _notify();

    // Chờ thời gian preview
    await Future.delayed(Duration(
        seconds: seconds)); // Giữ trạng thái này trong thời gian cấu hình

    // Kết thúc preview
    previewing = false; // Kết thúc giai đoạn xem trước

    // Úp lại những thẻ chưa matched
    for (final c in cards) {
      if (!c.isMatched) c.isFaceUp = false; // Úp lại những thẻ chưa ghép đúng
    }
    _notify();

    // Chờ animation úp thẻ hoàn thành
    await Future.delayed(Duration(
        milliseconds:
            GameConfig.cardFlipDuration)); // Chờ animation úp thẻ hoàn thành

    // Tiến hành xáo bài nhẹ
    await _animatedShuffle(
        steps: 3,
        stepDelay: const Duration(
            milliseconds:
                2500)); // Tiến hành xáo bài nhẹ sau khi preview kết thúc
  }

  // Hàm xáo bài với animation
  Future<void> _animatedShuffle(
      {int steps = 5,
      Duration stepDelay = const Duration(milliseconds: 100)}) async {
    // Kiểm tra trạng thái game
    if (state != GM.GameState.playing) return; // Không xáo khi game đã kết thúc

    // Tránh chạy song song nhiều animation xáo
    if (shuffling) return; // Tránh chạy song song nhiều animation xáo

    // Lưu generation hiện tại để tránh conflict
    final generation = _shuffleGeneration;

    // Đánh dấu đang xáo
    shuffling = true;
    _notify();

    // Thực hiện xáo bài theo số bước
    for (int i = 0; i < steps; i++) {
      // Kiểm tra lại trạng thái
      if (state != GM.GameState.playing)
        break; // Nếu đã kết thúc level thì ngừng xáo
      if (generation != _shuffleGeneration) break;

      // Xáo bài
      cards.shuffle(_rand); // Hoán đổi vị trí thẻ để tăng độ khó ghi nhớ
      _notify();

      // Chờ giữa các bước
      await Future.delayed(stepDelay);

      // Kiểm tra lại generation
      if (generation != _shuffleGeneration) break;
    }

    // Kết thúc xáo bài
    shuffling = false;
    _notify();
  }

  // Khởi động bộ đếm thời gian
  void _startTimer() {
    // Bộ đếm thời gian chạy mỗi giây, dừng khi game đã kết thúc
    _timer?.cancel();

    // Tạo timer mới
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      // Kiểm tra trạng thái game
      if (state != GM.GameState.playing) return;

      // Không trừ thời gian trong lúc đang preview hoặc xáo bài để tránh bất lợi cho người chơi
      if (!previewing && !shuffling) {
        secondsLeft -= 1; // Giảm thời gian còn lại
      }

      // Kiểm tra hết giờ
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        finish(false); // Hết giờ nghĩa là thua level
      }

      // Cập nhật UI
      _notify();
    });
  }

  // Getter kiểm tra xem có đang bận hay không (dùng để khóa thao tác)
  bool get isBusyTurn =>
      previewing ||
      shuffling ||
      _flippedIndices.isNotEmpty; // Dùng để khóa thao tác khi đang xử lý

  void flip(int index) {
    // Kiểm tra trạng thái game
    if (state != GM.GameState.playing) return;
    // Kiểm tra chỉ số hợp lệ
    if (index < 0 || index >= cards.length) return;
    // Không lật trong lúc preview
    if (previewing) return;
    // Không lật trong lúc xáo bài
    if (shuffling) return;
    // Chỉ cho phép mở tối đa 2 thẻ cùng lúc
    if (_flippedIndices.length >= 2) return;
    // Lấy thẻ tại vị trí
    final card = cards[index];
    // Bỏ qua thẻ đã ghép hoặc đang mở
    if (card.isMatched || card.isFaceUp) return;
    // Bỏ qua nếu đã có trong danh sách
    if (_flippedIndices.contains(index)) return;

    // Lật thẻ lên
    card.isFaceUp = true;
    // Thêm vào danh sách đã lật
    _flippedIndices.add(index);
    // Phát âm thanh lật thẻ
    SoundManager().playFlip();
    // Thông báo UI cập nhật
    _notify();

    if (card is CM.BombCard && card.isDefused) {
      card.isFaceUp = false;
      _flippedIndices.remove(index);
      _notify();
      return;
    }

    if (_flippedIndices.length == 2) {
      _resolveFlippedPair();
    }
  }

  void _resolveFlippedPair() {
    if (_flippedIndices.length < 2) return;

    final firstIndex = _flippedIndices[0];
    final secondIndex = _flippedIndices[1];
    final first = cards[firstIndex];
    final second = cards[secondIndex];

    final firstBomb = first is CM.BombCard && !first.isDefused;
    final secondBomb = second is CM.BombCard && !second.isDefused;

    if (firstBomb || secondBomb) {
      secondsLeft = max(0, secondsLeft - GameConfig.bombPenaltySeconds);
      SoundManager().playBombHit();
      Future.delayed(
          Duration(milliseconds: GameConfig.mismatchFlipBackDelay), () {
        if (state != GM.GameState.playing) return;
        if (!first.isMatched) first.isFaceUp = false;
        if (!second.isMatched) second.isFaceUp = false;
        _flippedIndices.clear();
        _notify();
      });
      _notify();
      return;
    }

    if (first is CM.NormalCard &&
        second is CM.NormalCard &&
        first.pairId == second.pairId) {
      first.isMatched = true;
      second.isMatched = true;
      score += GameConfig.pointsPerMatch;
      _matchedPairs += 1;
      SoundManager().playMatchSuccess();
      _flippedIndices.clear();
      _notify();
      _checkWin();
      return;
    }

    Future.delayed(
        Duration(milliseconds: GameConfig.mismatchFlipBackDelay), () {
      if (state != GM.GameState.playing) return;
      if (!first.isMatched) first.isFaceUp = false;
      if (!second.isMatched) second.isFaceUp = false;
      _flippedIndices.clear();
      score = max(0, score - GameConfig.penaltyPerMismatch);
      SoundManager().playMatchFail();
      _notify();
    });
  }

  void _checkWin() {
    // Tính số cặp cần thiết
    final needPairs = (level.baseCardCount / 2).floor();
    // Nếu đủ cặp, thắng level
    if (_matchedPairs >= needPairs) {
      finish(true);
    }
  }

  void finish(bool won) {
    // Đặt trạng thái kết thúc
    state = GM.GameState.finished;
    lastWon = won;
    _timer?.cancel();

    // Tắt nhạc nếu thua
    if (!won) {
      SoundManager().exitGameplayMusic();
    }

    // Phát nhạc thắng/thua
    if (won) {
      SoundManager().playLevelComplete();
    } else {
      SoundManager().playGameOver();
    }
    // Lấy người chơi
    final player = Sm.Session.I.currentPlayer;
    if (player != null) {
      // Tính điểm tăng
      int gained = max(0, score - _scoreAtLevelStart);
      if (won) {
        score += secondsLeft;
        gained += secondsLeft;
        player.highestLevel = max(player.highestLevel, level.levelNumber);
      }
      player.score += gained;
      leaderboard.addRecord(PR.PlayRecord(
        name: player.name,
        score: gained,
        level: level.levelNumber,
        playedAt: DateTime.now(),
      ));
      leaderboard.addOrUpdate(player);
    }
    // Lưu session
    Sm.Session.I.saveAll();
    _notify();
    // Gọi callback kết thúc
    if (onFinished != null) onFinished!();
  }

  // Getter kiểm tra có thể dùng trợ giúp không
  bool get canUseHelp => helpsUsedThisLevel < 3 && state == GM.GameState.playing && !isBusyTurn;

  // Thêm thời gian trợ giúp
  void addExtraTimeHelp() {
    if (!canUseHelp) return;
    secondsLeft += GameConfig.helpExtraTimeBonus;
    pendingNextLevelTimePenalty += GameConfig.helpExtraTimePenalty;
    helpsUsedThisLevel++;
    _notify();
  }

  // Hiển thị tất cả thẻ trợ giúp
  Future<void> showAllHelp() async {
    if (!canUseHelp) return;
    if (previewing) return;
    previewing = true;
    for (final c in cards) {
      if (!c.isMatched) c.isFaceUp = true;
    }
    _notify();
    await Future.delayed(Duration(seconds: GameConfig.helpShowAllDuration));
    previewing = false;
    for (final c in cards) {
      if (c is CM.BombCard && c.isDefused) {
        c.isFaceUp = true;
        continue;
      }
      if (!c.isMatched) {
        c.isFaceUp = false;
      }
    }
    secondsLeft = max(0, secondsLeft - GameConfig.helpShowAllCost);
    helpsUsedThisLevel++;
    _notify();
  }

  // Xóa một bom trợ giúp
  void removeOneBombHelp() {
    if (!canUseHelp) return;
    if (level.levelNumber < 4) return;
    // Tìm danh sách bom chưa gỡ
    final candidates = <int>[];
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      if (card is CM.BombCard && !card.isMatched && !card.isDefused) {
        candidates.add(i);
      }
    }
    if (candidates.isEmpty) return;
    // Chọn bom ngẫu nhiên
    final idx = candidates[_rand.nextInt(candidates.length)];
    final bomb = cards[idx] as CM.BombCard;
    // Vô hiệu hóa bom
    bomb.isDefused = true;
    // Lật thẻ bom để người chơi nhận biết
    bomb.isFaceUp = true;
    helpsUsedThisLevel++;
    _notify();
  }

  // Thông báo UI cập nhật
  void _notify() {
    if (onUpdate != null) onUpdate!();
  }

  // Tạo danh sách ảnh cho level
  List<String> _imagesForLevel(int levelNumber) {
    final list = List<String>.generate(23, (i) => 'assets/levels/${i + 1}.jpg');
    list.shuffle(_rand);
    return list;
  }
}