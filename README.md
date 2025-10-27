# Bậc Thầy Trí Tuệ

---

## MỤC LỤC

1. Giới thiệu dự án  
2. Tính năng nổi bật  
3. Kiến trúc & Nguyên lý OOP  
4. Mô hình lớp & luồng hoạt động  
5. Hướng dẫn cài đặt & chạy  
6. Bảng xếp hạng & cài đặt  
7. Kiểm thử & đóng góp  
8. Tài liệu tham khảo  
9. Phụ lục  
- **Nguyên lý & mẫu thiết kế OOP** đã triển khai.

### 1.1 Cấu trúc thư mục

```
assets/
├─ audio/
│  ├─ Thirteen.mp3
│  ├─ flip.mp3
│  ├─ game_play.mp3
│  ├─ lose.mp3
│  ├─ loss.mp3
│  ├─ w.mp3
│  ├─ win.mp3
│  └─ 是心动啊 - 原来是萝卜丫.mp3
├─ fonts/
│  └─ KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2
├─ icon/
├─ levels/
│  ├─ 1.jpg
│  ├─ 2.jpg
│  ├─ 3.jpg
│  ├─ 4.jpg
│  ├─ 5.jpg
│  ├─ 6.jpg
│  ├─ 7.jpg
│  ├─ 8.jpg
│  ├─ 9.jpg
│  ├─ 10.jpg
│  ├─ 11.jpg
│  ├─ 12.jpg
│  ├─ 13.jpg
│  ├─ 14.jpg
│  ├─ 15.jpg
│  ├─ 16.jpg
│  ├─ 17.jpg
│  ├─ 18.jpg
│  ├─ 19.jpg
│  ├─ 20.jpg
│  ├─ 21.jpg
│  ├─ 22.jpg
│  ├─ 23.jpg
│  ├─ back.png
│  ├─ bom.png
│  └─ c.py
└─ photo/
   ├─ icon.ico
   ├─ icon.png
   ├─ modelGIF1.gif
   ├─ nenapp1.gif
   ├─ nenapp2.gif
   └─ nenapp20.gif

lib/
├─ main.dart
├─ config/
│  └─ game_config.dart
├─ game/
│  ├─ controller.dart
│  ├─ level_builder.dart
│  └─ models.dart
├─ managers/
│  ├─ sound_manager.dart
│  ├─ storage_manager.dart
│  └─ theme_notifier.dart
├─ models/
│  ├─ card_model.dart
│  ├─ game_state.dart
│  ├─ help_type.dart
│  ├─ leaderboard_model.dart
│  ├─ level_model.dart
│  ├─ play_record_model.dart
│  ├─ player_model.dart
│  ├─ rank_item.dart
│  ├─ settings_model.dart
│  └─ sound_effect.dart
├─ repositories/
│  └─ leaderboard_repository.dart
├─ screens/
│  ├─ game_basic_screen.dart
│  ├─ initial_name_screen.dart
│  ├─ login_screen.dart
│  ├─ menu_screen.dart
│  ├─ name_input_screen.dart
│  ├─ ranking_screen.dart
│  ├─ register_screen.dart
│  ├─ settings_screen.dart
│  └─ splash_screen.dart
├─ services/
│  ├─ audio_service.dart
│  └─ auth_service.dart
├─ session/
│  ├─ session.dart
│  └─ session_manager.dart
├─ utils/
│  ├─ logger.dart
│  └─ settings_notifier.dart
└─ widgets/
   ├─ app_background.dart
   ├─ game_card.dart
   ├─ gradient_text.dart
   ├─ primary_button.dart
   └─ responsive_layout.dart
```

**Chi tiết từng thư mục:**

- `assets/audio/`:
  - `Thirteen.mp3`: Nhạc nền menu chính.
  - `game_play.mp3`: Nhạc nền trong màn chơi.
  - `是心动啊 - 原来是萝卜丫.mp3`: Nhạc nền phụ bản quyền tự do.
  - `flip.mp3`: Hiệu ứng lật thẻ.
  - `win.mp3`: Hiệu ứng hoàn thành level.
  - `loss.mp3`: Hiệu ứng thua/thời gian hết.
  - `lose.mp3`: Biến thể âm thanh thất bại ngắn.
  - `w.mp3`: Âm chúc mừng nhanh khi ghép đúng.
- `assets/fonts/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2`: Font Roboto Medium dùng cho tiêu đề.
- `assets/icon/app_icon.png`: Icon 1024×1024 cho build đa nền tảng.
- `assets/levels/`:
  - `1.jpg` – `23.jpg`: Bộ ảnh cặp dùng cho các level tương ứng.
  - `back.png`: Mặt sau chung cho thẻ chưa lật.
  - `bom.png`: Ảnh hiển thị khi là thẻ bom.
  - `c.py`: Script hỗ trợ xử lý/resize asset khi cần.
- `assets/photo/`:
  - `icon.png`, `icon.ico`: Icon hiển thị trong hệ điều hành.
  - `modelGIF1.gif`, `nenapp1.gif`, `nenapp2.gif`, `nenapp20.gif`: GIF nền động cho splash/menu.

- `lib/main.dart`: Khởi tạo widget gốc, theme, route và inject `Session`.
- `lib/config/game_config.dart`: Hằng số gameplay (điểm thưởng/phạt, thời gian, màu sắc, asset path, âm lượng mặc định).
- `lib/game/controller.dart`: `GameRuntimeController`–quản lý vòng đời level, timer, logic flip, trợ giúp, đồng bộ điểm.
- `lib/game/level_builder.dart`: Factory sinh `LevelModel` dựa trên cấp độ, tính toán số cặp, số bom, thời gian giới hạn.
- `lib/game/models.dart`: Barrel export gom toàn bộ domain model gameplay để các module import ngắn gọn.
- `lib/managers/`:
  - `sound_manager.dart`: Singleton điều khiển nhạc nền/hiệu ứng, bảo đảm đồng bộ giữa mobile & desktop.
  - `storage_manager.dart`: Singleton bọc `SharedPreferences`, phụ trách lưu/đọc tài khoản, leaderboard, settings.
  - `theme_notifier.dart`: `ChangeNotifier` đồng bộ chế độ sáng/tối với UI.
- `lib/models/`:
  - `card_model.dart`: Định nghĩa `CardBase`, `NormalCard`, `BombCard` và thuộc tính đi kèm.
  - `game_state.dart`: Enum trạng thái game (`idle`, `playing`, `paused`, `finished`).
  - `help_type.dart`: Enum loại trợ giúp (`extraTime`, `showAll`, `removeBomb`).
  - `leaderboard_model.dart`: Lớp `Leaderboard` quản lý người chơi & lịch sử.
  - `level_model.dart`: Cấu trúc dữ liệu bất biến cho từng level.
  - `play_record_model.dart`: Ghi nhận mỗi lần chơi với thời gian, điểm, level.
  - `player_model.dart`: Hồ sơ người chơi hiện tại (tên, điểm, level cao nhất).
  - `rank_item.dart`: Model hiển thị từng dòng bảng xếp hạng.
  - `settings_model.dart`: Giữ theme, âm thanh, font size của người dùng.
  - `sound_effect.dart`: Mô tả meta của từng hiệu ứng âm thanh (id, asset path, volume).
- `lib/repositories/leaderboard_repository.dart`: Gateway giữa UI/controller và `StorageManager` để đọc/ghi leaderboard.
- `lib/screens/`:
  - `splash_screen.dart`: Kiểm tra trạng thái đăng nhập & chuyển tiếp.
  - `login_screen.dart`, `register_screen.dart`: Flow xác thực người dùng.
  - `initial_name_screen.dart`, `name_input_screen.dart`: Thu thập tên người chơi mới.
  - `menu_screen.dart`: Trung tâm điều hướng, hiển thị thông tin người chơi hiện tại.
  - `game_basic_screen.dart`: UI chính của gameplay, render lưới thẻ & timer.
  - `settings_screen.dart`: Điều chỉnh theme, âm thanh, font size.
  - `ranking_screen.dart`: Hiển thị bảng xếp hạng và lịch sử chơi.
- `lib/services/`:
  - `auth_service.dart`: Logic đăng ký/đăng nhập (giả lập) và xác thực dữ liệu đầu vào.
  - `audio_service.dart`: Gói gọn player low-level để `SoundManager` tái sử dụng.
- `lib/session/`:
  - `session.dart`: Định nghĩa đối tượng `Session` (singleton) chứa player, settings, leaderboard.
  - `session_manager.dart`: API cấp cao load/save session, kết nối `StorageManager`.
- `lib/utils/`:
  - `logger.dart`: Helper log nhiều cấp độ dành cho debugging.
  - `settings_notifier.dart`: Bọc `SettingsModel` thành notifier riêng cho UI listeners.
- `lib/widgets/`:
  - `app_background.dart`: Nền gradient động tái sử dụng.
  - `game_card.dart`: Widget hiện thẻ với hiệu ứng lật 3D.
  - `gradient_text.dart`: Text gradient cho tiêu đề/điểm số.
  - `primary_button.dart`: Button tuỳ chỉnh phong cách game.
  - `responsive_layout.dart`: Helper layout responsive cho mobile/tablet/desktop.

## 2. Kiến trúc OOP tổng quan

- **Singleton**: `Session`, `StorageManager`, `SoundManager`, `GameConfig` đảm bảo chỉ tạo một instance duy nhất quản lý trạng thái, lưu trữ và cấu hình.
- **Factory**: `LevelBuilder` xây dựng màn chơi dựa trên cấp độ, che giấu công thức bên trong.
- **Observer (ChangeNotifier)**: `ThemeNotifier`, `SettingsNotifier` thông báo UI tự cập nhật khi trạng thái thay đổi.
- **Composition**: Các controller (ví dụ `GameRuntimeController`) chứa `SettingsModel`, `Leaderboard` thay vì kế thừa, giúp tái sử dụng rõ ràng.
- **Encapsulation**: Thuộc tính private (`_prefs`, `_isInitialized`, `_cards`) bảo vệ dữ liệu, chỉ truy cập qua method công khai.

## 3. Đối tượng & Thuộc tính chính

### 3.1 `Player` (`lib/models/player_model.dart`)

- **Thuộc tính**: `name`, `score`, `highestLevel`.
- **Hành vi**: `addScore()`, `updateHighestLevel()`, `resetScore()`, `toJson()`.
- **Vai trò**: Lưu hồ sơ người chơi hiện tại và cập nhật sau mỗi ván.

### 3.2 `PlayRecord` (`lib/models/play_record_model.dart`)

- **Thuộc tính**: `name`, `score`, `level`, `playedAt`.
- **Hành vi**: Các hàm so sánh (`compareByScore`, `compareByLevel`, `compareByDate`), `toJson()`/`fromJson()`.
- **Vai trò**: Ghi lịch sử từng lần chơi để thống kê và hiển thị bảng thành tích chi tiết.

### 3.3 `Leaderboard` (`lib/models/leaderboard_model.dart`)

- **Thuộc tính**: `players`, `records`.
- **Hành vi**: `addOrUpdate()`, `removePlayer()`, `findPlayer()`, `sortByScore()`, `getTopPlayers()`, `toJson()`.
- **Vai trò**: Trung tâm quản lý bảng xếp hạng và nhật ký ván chơi.

### 3.4 `SettingsModel` (`lib/models/settings_model.dart`)

- **Thuộc tính**: `themeMode`, `soundEnabled`, `fontSize` cùng các getter tiện ích (`isDarkMode`, `isValidFontSize`).
- **Hành vi**: `toggleTheme()`, `toggleSound()`, `setFontSize()`, `reset()`, `copyWith()`.
- **Vai trò**: Giữ thiết lập cá nhân hóa (giao diện, âm thanh, cỡ chữ) dùng chung toàn app.

### 3.5 `StorageManager` (`lib/managers/storage_manager.dart`)

- **Thuộc tính**: `_prefs`, `_isInitialized`, bộ key (`_keyUsernames`, `_keyLeaderboard`, ...).
- **Hành vi**: `init()`, `_ensureInitialized()`, `registerUser()`, `login()`, `savePlayerData()`, `saveLeaderboard()`, `loadSettings()`, ...
- **Vai trò**: Cầu nối duy nhất làm việc với `SharedPreferences`, đảm bảo dữ liệu local được lưu/đọc nhất quán.

### 3.6 `Session` (`lib/session/session_manager.dart`)

- **Thuộc tính**: `currentPlayer`, `leaderboard`, `settings`, `_storage`.
- **Hành vi**: `setPlayerName()`, `loadAll()`, `saveAll()`, `reset()`.
- **Vai trò**: Singleton quản lý trạng thái toàn cục (player hiện tại, bảng xếp hạng, settings) cho mọi màn hình.

### 3.7 `GameRuntimeController` (`lib/game/controller.dart`)

- **Thuộc tính nổi bật**: `currentLevel`, `cards`, `revealedIndexes`, `timer`, `settings`, `leaderboard`.
- **Hành vi**: `startLevel()`, `flipCard()`, `checkMatch()`, `useHelp()`, `endLevel()`.
- **Vai trò**: Bộ điều khiển gameplay chính, phối hợp giữa model, âm thanh, UI.

### 3.8 `LevelModel` & `LevelBuilder`

- `LevelModel` (`lib/models/level_model.dart`): Lưu cấu hình bất biến cho từng màn (`baseCardCount`, `bombsCount`, `timeLimit`, `previewSeconds`).
- `LevelBuilder` (`lib/game/level_builder.dart`): Factory tính toán số thẻ/bom/thời gian theo công thức chung.

### 3.9 Widgets tái sử dụng (`lib/widgets/`)

- `AppBackground`, `GameCard`, `ModeSwitch`, `LoginForm` nhận dữ liệu từ `Session`/`SettingsModel`, áp dụng composition để tái sử dụng.

### 3.10 Nhóm thẻ bài (Card)

- **`CardBase`** (`lib/models/card_model.dart`): Lớp trừu tượng giữ thuộc tính chung `id`, `isFaceUp`, `isMatched` cho mọi loại thẻ.
- **`NormalCard`** (`lib/models/card_model.dart`): Kế thừa `CardBase`, bổ sung `pairId`, `imagePath`; dùng để ghép cặp và ghi điểm.
- **`BombCard`** (`lib/models/card_model.dart`): Kế thừa `CardBase`, thêm `penaltyTime`, `isDefused`; kích hoạt phạt thời gian khi lật nhầm.
- **`GameRuntimeController.cards`** (`lib/game/controller.dart`): Danh sách `List<CardBase>` kết hợp cả thẻ thường và bom, điều khiển logic lật/ghép.
- **`GameCard`** (`lib/widgets/game_card.dart`): Widget hiển thị thẻ, kiểm tra kiểu (`NormalCard`/`BombCard`) để render ảnh, màu sắc và hiệu ứng phù hợp.

### 3.11 Đối tượng OOP bổ sung

- **`SoundManager`** (`lib/managers/sound_manager.dart`): Singleton điều khiển nhạc nền và hiệu ứng (`playFlip()`, `enterGameplayMusic()`).
- **`GameConfig`** (`lib/config/game_config.dart`): Tập trung hằng số trò chơi (điểm, thời gian, màu sắc, asset) truy cập qua getter tĩnh.
- **`ThemeNotifier`** (`lib/managers/theme_notifier.dart`): Kế thừa `ChangeNotifier`, bọc `SettingsModel` để thông báo UI khi đổi theme/font.
- **`AuthService`** (`lib/services/auth_service.dart`): Xử lý đăng ký/đăng nhập, ủy quyền lưu trữ cho `StorageManager` và kiểm tra hợp lệ.
- **`StorageManager`** (`lib/managers/storage_manager.dart`): Singleton bọc `SharedPreferences`, cung cấp API lưu/đọc tài khoản, player, leaderboard, settings.
- **`Session`** (`lib/session/session_manager.dart`): Trung tâm trạng thái toàn app, quản lý `currentPlayer`, `settings`, `leaderboard`, đồng bộ với storage.
- **`LevelBuilder`** (`lib/game/level_builder.dart`): Factory tạo `LevelModel` theo công thức (số thẻ, bom, thời gian, preview) dựa trên level.
- **`GameRuntimeController`** (`lib/game/controller.dart`): Điều khiển gameplay, lật thẻ, kiểm tra ghép, cập nhật điểm và đồng bộ leaderboard.

## 4. Dòng chảy OOP của gameplay

1. **`SplashScreen`** kiểm tra trạng thái đăng nhập → gọi `Session.loadAll()`.
2. **`LoginScreen`/`RegisterScreen`** dùng `AuthService` (bao `StorageManager`) để xác thực.
3. **`InitialNameScreen`** tạo `Player` mới và set vào `Session.currentPlayer`.
4. **`MenuScreen`** hiển thị bảng xếp hạng qua `Session.leaderboard`.
5. **`GameBasicScreen`**:
   - `GameRuntimeController` xây level bằng `LevelBuilder` + `GameConfig`.
   - `GameCard` render từ `CardModel`; sự kiện lật card gọi controller xử lý.
   - Kết thúc level → cập nhật `Player`, thêm `PlayRecord` vào `Leaderboard`.
6. **`SettingsScreen`** thay đổi `SettingsModel`; `ThemeNotifier` thông báo tới các widget (`AppBackground`, `GameCard`).
7. **`RankingScreen`** đọc dữ liệu `Leaderboard` để hiển thị top theo điểm/level.

## 5. Nguyên lý OOP tiêu biểu

- **Encapsulation**: Giấu chi tiết triển khai bên trong class, chỉ exposing API cần thiết.
- **Inheritance**: `CardBase` → `NormalCard`/`BombCard`, cho phép mở rộng loại thẻ.
- **Polymorphism**: Danh sách `List<CardBase>` chứa nhiều loại card nhưng xử lý chung.
- **Abstraction**: Hàm `LevelBuilder().buildLevel(n)` che giấu công thức phức tạp.
- **Composition**: Controller chứa nhiều model (settings, leaderboard) để phối hợp linh hoạt.

## 6. Gợi ý trình bày khi thuyết trình

- **Giới thiệu model**: Trình bày `Player`, `PlayRecord`, `SettingsModel`, `LevelModel` cùng thuộc tính.
- **Minh họa hành vi**: Nêu ví dụ thực tế (ví dụ `sortByScore()` để lấy top bảng xếp hạng).
- **Mẫu thiết kế**: Giải thích vì sao dùng Singleton cho `Session`, Factory cho `LevelBuilder`, Observer cho thông báo UI.
- **Flow tổng thể**: Dùng sơ đồ hoặc mô tả 7 bước ở trên để chứng minh sự phối hợp giữa các đối tượng.

## 7. Kết luận

Dự án áp dụng đầy đủ nguyên lý OOP: tách biệt trách nhiệm, mô-đun hóa, dễ mở rộng/bảo trì. Các lớp, thuộc tính và hành vi được đặt tên rõ nghĩa, thuận tiện cho báo cáo và trình bày trước nhóm hoặc giảng viên.

## 8. Thiết lập & chạy dự án

### 8.1 Yêu cầu hệ thống

- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- IDE khuyến nghị: VS Code (Flutter extension) hoặc Android Studio/IntelliJ với Flutter plugin.

### 8.2 Cài đặt phụ thuộc

```bash
flutter pub get
```

### 8.3 Chạy ứng dụng

```bash
# Thiết bị/simulator đã được khởi động
flutter run

# Hoặc build web
flutter run -d chrome
```

### 8.4 Kiểm thử

```bash
flutter test
```

## 9. Tính năng nổi bật

1. **Gameplay ghi nhớ thẻ**: Lật các cặp thẻ, tránh bom, chạy đua với thời gian.
2. **Hệ thống âm thanh đa nền tảng**: `SoundManager` đồng bộ âm lượng, nhạc nền và hiệu ứng giữa mobile & desktop.
3. **Bảng xếp hạng & lịch sử chơi**: `Leaderboard` và `PlayRecord` lưu lại kết quả, hiển thị top.
4. **Trợ giúp trong game**: Thêm thời gian, mở toàn bộ thẻ ngắn hạn, vô hiệu hóa bom.
5. **Thiết lập cá nhân hóa**: Đổi theme sáng/tối, chỉnh âm thanh, cỡ chữ theo sở thích.
6. **Lưu trữ local**: `StorageManager` (SharedPreferences) đảm bảo dữ liệu người chơi được giữ lại giữa các lần mở app.

---

---

###  Giao diện cơ bản

| ![Đăng nhập](img/dangnhap.png) | ![Đăng ký](img/dangky.png) | ![Nhập tên](img/nhapten.png) |
|:--:|:--:|:--:|
| **Đăng nhập** | **Đăng ký tài khoản mới** | **Nhập tên người chơi** |

---

###  Màn hình chính & chơi game

| ![Menu chính](img/menu.png) | ![Giao diện chơi](img/choi_1.png) |
|:--:|:--:|
| **Menu chính** – chọn chế độ chơi, cài đặt, bảng xếp hạng,... | **Màn chơi chính** – lưới thẻ, đồng hồ, điểm số và trợ giúp |

| ![Sai thẻ](img/saithe.png) | ![Đúng thẻ](img/dungthe.png) | ![Tráo thẻ](img/traothe.png) |
|:--:|:--:|:--:|
| **Chọn 2 thẻ sai** | **Chọn 2 thẻ đúng** | **Hiệu ứng tráo thẻ bài** |

---

###  Chuyển level & kết quả

| ![Qua level](img/qua_level.png) | ![Thua level](img/thua_level.png) |
|:--:|:--:|
| **Qua level thành công** | **Màn hình thua – hết lượt hoặc hết thời gian** |

---

###  Cài đặt & bảng xếp hạng

| ![Cài đặt](img/cai_dat.png) | ![Top 5 điểm](img/top5_diem.png) | ![Top 5 level](img/top5_level.png) |
|:--:|:--:|:--:|
| **Tùy chỉnh theme, âm lượng, font chữ,...** | **Bảng xếp hạng theo điểm số** | **Bảng xếp hạng theo level cao nhất** |

---

###  Thoát game

| ![Thoát](img/exit.png) |
|:--:|
| **Màn hình thoát game** – xác nhận trước khi rời trò chơi |

---
## 10. Đóng góp & mở rộng

- Fork dự án, tạo branch mới cho tính năng/bug fix.
- Giữ style code nhất quán, thêm comment tiếng Việt ngắn gọn cho khối logic quan trọng.
- Viết thêm test khi sửa logic gameplay hoặc storage.
- Tạo Pull Request mô tả rõ ràng thay đổi và ảnh chụp màn hình (nếu là UI).

## 11. Giấy phép

Dự án phục vụ mục đích học tập. Nếu muốn tái sử dụng thương mại, vui lòng liên hệ tác giả để trao đổi chi tiết.
