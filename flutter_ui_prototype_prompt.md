# PROMPT: Xây dựng Flutter UI Prototype cho ứng dụng HVP Boxing (Học viên)

## 0. Vai trò & mục tiêu

Bạn là một Flutter engineer. Nhiệm vụ: xây dựng một **UI-only prototype** (không backend, không API thật) cho app di động **HVP Boxing** — ứng dụng quản lý học viên phòng tập boxing với hệ thống Discipline Points (DP) / HVP Marks, streak, challenge, đổi thưởng.

Bạn được cung cấp 2 tài liệu tham khảo, hãy đọc kỹ cả hai trước khi code:
- `SRS.docx` — Software Requirements Specification: mô tả đầy đủ use case, business rules, message codes (MSG1–MSG35) cho toàn hệ thống (Học viên / Coach / Admin).
- `app.html` — mockup UI tĩnh (HTML/CSS/JS) mô phỏng 4 màn hình chính của app Học viên (Trang chủ, Lịch tập, Bài tập hôm nay, Check-in). Đây là **nguồn tham chiếu chính xác về design system, layout, copy tiếng Việt và hành vi tương tác** — hãy dịch 1:1 sang widget Flutter, không tự sáng tạo lại bố cục.

**Phạm vi:** chỉ build app phía **Học viên (Member)**, không cần build Coach app / Admin web trong lần này.

---

## 1. Ràng buộc kỹ thuật (UI-only prototype)

- **Không gọi API thật, không backend.** Toàn bộ dữ liệu là mock/dummy, định nghĩa sẵn trong code (giống cách `app.html` dùng biến JS `EXERCISES`, `CHALLENGES`... ở cuối file).
- State quản lý bằng `StatefulWidget` + `setState`, hoặc `provider`/`riverpod` nếu cần chia sẻ state giữa nhiều màn hình (ví dụ điểm DP hiển thị ở cả Home lẫn Profile) — chọn 1 cách, giữ nhất quán toàn app.
- Camera QR: **không cần tích hợp camera/QR scanner thật.** Dựng UI scan-frame tĩnh + animation (scan line chạy, khung góc) giống mockup, nút "Xác nhận Check-in" chỉ giả lập kết quả thành công/thất bại bằng `Future.delayed` giống JS `simulateCheckin()`.
- Không cần lưu trữ local (SharedPreferences/DB) — reset về trạng thái mặc định mỗi lần mở app là chấp nhận được.
- Target: Flutter mới nhất (stable), Material 3 (`useMaterial3: true`), chạy được cả Android/iOS/Web (`flutter run -d chrome` để preview nhanh).
- Ngôn ngữ hiển thị: **tiếng Việt**, giữ nguyên văn phong/câu chữ từ `app.html` và các MSG code trong SRS khi hiển thị thông báo.

---

## 2. Design system (trích xuất từ `app.html`)

Đọc phần `<style>` của `app.html` để lấy chính xác, nhưng tóm tắt:

**Theme:** Dark mode, phong cách "gym / thể thao mạnh mẽ".

| Token | Giá trị | Dùng cho |
|---|---|---|
| Background chính | `#05060D` | nền ngoài khung app |
| Ink (nền card lớn) | `#12162A` | nền màn hình |
| Ink-2 | `#1B2140` | nền phụ |
| Card | `#1F2647` | card thường |
| Card-hi | `#262E54` | card nổi bật |
| Line/border | `rgba(236,237,243,0.08)` | viền mờ |
| Text chính | `#ECEDF3` | |
| Text dim | `#9298B8` | text phụ |
| Text faint | `#6A6F94` | eyebrow/label nhỏ |
| Accent (cam) | `#FF6A3D` | CTA chính, điểm nhấn |
| Teal | `#2ED1B0` | trạng thái tích cực/streak |
| Amber | `#FFC352` | cảnh báo nhẹ/điểm thưởng |
| Radius lớn | `20px` | card |
| Radius nhỏ | `12px` | chip, button nhỏ |

**Font:** `Oswald` (tiêu đề/số liệu lớn, in đậm, letter-spacing rộng), `Inter` (nội dung), `JetBrains Mono` (label kiểu "eyebrow" viết hoa, letter-spacing). Dùng `google_fonts` package trong Flutter để load 3 font này.

Hãy tạo file `lib/theme/app_theme.dart` chứa `ThemeData` + các `Color`/`TextStyle` constants tương ứng bảng trên, để tái sử dụng nhất quán trên mọi màn hình.

---

## 3. Cấu trúc điều hướng

- Bottom navigation bar 4 tab (copy đúng icon/label từ `app.html`):
  1. 🏠 Trang chủ (`home`)
  2. 📅 Lịch tập (`schedule`)
  3. 💪 Bài tập (`workout`)
  4. 📷 Check-in (`checkin`)
- Trước đó, thêm luồng auth đơn giản dựa theo UC1/UC2/UC3 trong SRS (xem mục 4) — dùng `Navigator` push/pop hoặc named routes, không cần lưu session thật.
- Cấu trúc route đề xuất:
  ```
  /splash → /login → /signup → /forgot-password → /home (bottom nav: home, schedule, workout, checkin)
  ```

---

## 4. Danh sách màn hình cần dựng

### Nhóm A — Có sẵn 1:1 trong `app.html` (ưu tiên cao nhất, độ chính xác pixel-level)

Với 4 màn này, hãy mở `app.html`, đọc từng phần HTML + JS tương ứng, và chuyển đổi trực tiếp:

1. **Trang chủ (`screen-home`)**
   - Header chào (theo giờ trong ngày) + avatar chữ cái đầu tên.
   - Package card: tên gói, tag "ĐANG HOẠT ĐỘNG", lịch tập (số buổi/tuần, ngày, giờ), ngày hết hạn, progress bar số buổi đã tập/còn lại.
   - 2 nút CTA: "QR CHECK-IN" (điều hướng sang tab Check-in) và "XEM BÀI TẬP HÔM NAY" (điều hướng sang tab Bài tập).
   - Stat row: Điểm tích lũy (⭐) + Chuỗi buổi tập (🔥 streak).
   - Card "Buổi tập tiếp theo" (ngày, HLV, giờ, chip "SẮP TỚI"), link "Xem lịch →" sang tab Lịch tập.

2. **Lịch tập (`screen-schedule`)**
   - Banner cảnh báo gói tập sắp hết hạn.
   - Week strip 7 ngày (T2–CN) đánh dấu ngày đã tập / hôm nay.
   - Danh sách buổi trong tuần: icon trạng thái (✓ đã tập / ⏱ chưa tập / — sắp tới), tiêu đề ngày, giờ + HLV, badge trạng thái.

3. **Bài tập hôm nay (`screen-workout`)**
   - Ring progress (SVG circle → dùng `CustomPainter` hoặc package `percent_indicator`) hiển thị % hoàn thành.
   - Danh sách bài tập (checklist, tap để toggle hoàn thành) — dữ liệu mock `EXERCISES` (8 bài, có icon/tên/số hiệp).
   - Milestone chips (50%/80%/100%) hiển thị điểm thưởng đạt mốc, cập nhật trạng thái "reached" khi đủ %.
   - Danh sách challenge (radio-select, chỉ chọn 1) — dữ liệu mock `CHALLENGES` (3 challenge, có mô tả + điểm thưởng).
   - Thanh tổng kết cố định dưới cùng: tổng điểm dự kiến + nút "HOÀN TẤT BUỔI TẬP" (disable khi chưa tick bài nào).
   - Kết quả sau khi hoàn tất: panel hiện icon 🏆, tóm tắt số bài đã hoàn thành, mốc đạt được, challenge đã chọn, tổng điểm — **cộng dồn điểm này vào "Điểm tích lũy" ở Trang chủ** (dùng shared state).
   - Logic tính điểm (copy đúng công thức JS): `điểm bài tập = số bài đã tick × 5` + `bonus mốc (50%→+10, 80%→+30, 100%→+50, cộng dồn)` + `điểm challenge đã chọn`.

4. **Check-in (`screen-checkin`)**
   - Khung "scan frame" giả lập QR (vẽ pattern QR giả bằng `CustomPainter`, không cần đọc thật), có scan-line animation chạy lên xuống, 4 góc khung.
   - Đồng hồ đếm ngược 30s "Mã tự làm mới sau Ns" — khi về 0 thì regenerate QR giả + reset về 30.
   - Nút "XÁC NHẬN CHECK-IN" → loading state "ĐANG XÁC THỰC..." (giả lập delay ~900ms) → panel kết quả "✅ Check-in thành công", giờ ghi nhận, "+20 điểm thưởng" → nút đổi thành "ĐÃ CHECK-IN".

### Nhóm B — Không có trong mockup, phải tự thiết kế UI mới dựa trên use case SRS, **nhưng bắt buộc dùng chung design system ở mục 2** (không tự bịa theme khác)

Xây dựng thêm các màn sau, mỗi màn ghi rõ nguồn use case để bám sát nghiệp vụ + copy các MSG tương ứng:

5. **Splash / Onboarding** — logo app, chuyển sang Login sau ~1.5s.
6. **Đăng nhập (UC2 – Login)** — input email/username + password, nút "Đăng nhập", link "Quên mật khẩu?" và "Chưa có tài khoản? Đăng ký". Validate rỗng → hiện MSG5; sai thông tin (giả lập) → MSG6; thành công → MSG7, chuyển sang Home.
7. **Đăng ký (UC1 – SignUp)** — form: họ tên, email, số điện thoại, địa chỉ, mật khẩu, xác nhận mật khẩu. Submit rỗng/sai định dạng → MSG1; email trùng (giả lập) → MSG2; thành công → MSG3 rồi MSG4, chuyển về Login.
8. **Quên mật khẩu (UC3 – Forgot Password)** — nhập số điện thoại → giả lập gửi mã PIN (MSG10) hoặc báo số chưa đăng ký (MSG9) → màn nhập PIN + mật khẩu mới → sai/hết hạn PIN (MSG11) hoặc thành công (MSG12/MSG13/MSG14).
9. **Thông báo (dựa trên "Use case Gửi Push Notification theo sự kiện")** — danh sách notification dạng card/list-tile (icon theo loại: check-in thành công, DP cập nhật, rank mới, streak nhắc nhở...), mock ~6–8 item với timestamp tương đối ("2 giờ trước"...). Tham khảo 8 mẫu thông báo nêu trong SRS (WORK DONE, 120 DP REMAIN, RANK EARNED, ĐỪNG ĐỂ CHUỖI DỪNG LẠI, THE STREAK ENDS, YOU'VE BEEN GONE FOR 7 DAYS, YOUR MARKS ARE WAITING, EARNED. NOT GIVEN.) làm nội dung mẫu.
10. **Fighter Record / Hồ sơ hạng** (dựa trên UC7 – Rank Trial, UC8 – Tính DP & xét lên hạng) — hiển thị: hạng hiện tại trong hệ 7 hạng (THE UNKNOWN → THE LEGACY), thanh tiến trình DP balance so với ngưỡng hạng kế tiếp, trạng thái đề xuất (IN PROGRESS / DP COMPLETED / TRIAL REQUIRED / APPROVAL REQUIRED / RANK EARNED) dạng badge màu khác nhau, danh sách điều kiện còn thiếu (time-gate/course-gate/trial-gate), nút "Yêu cầu Rank Trial" khi đủ điều kiện (disable + tooltip lý do khi chưa đủ, dùng nội dung MSG27/MSG28/MSG34).
11. **Streak** (dựa trên "Use case Tính Streak cuối tuần & áp dụng Streak Freeze") — hiển thị số streak hiện tại, lịch 7 ngày gần nhất dạng chấm tròn (có tập/nghỉ/freeze), trạng thái "Streak Freeze" còn khả dụng hay không, cảnh báo sắp mất streak.
12. **Challenges** (dựa trên "Use case Vòng đời Challenge: Mở → Tham gia → Hoàn thành → Nhận thưởng") — danh sách challenge đang mở (card: tên, mô tả, điểm thưởng, deadline, trạng thái Chưa tham gia/Đang tham gia/Đã hoàn thành/Đã nhận thưởng), nút hành động tương ứng theo trạng thái.
13. **The Armory — Đổi thưởng** (dựa trên "Use case Luồng đổi quà The Armory & Lễ tân xác nhận giao quà") — grid/list phần thưởng (tên, ảnh placeholder, số điểm cần đổi), số dư điểm hiện tại ở top, nút "Đổi ngay" (disable nếu không đủ điểm), dialog xác nhận đổi quà, màn trạng thái đơn đổi quà (Chờ nhận tại quầy / Đã nhận).
14. **Hồ sơ / Thông tin cá nhân** (UC12 – Change Buyer/Member Information, điều chỉnh theo ngữ cảnh gym) — avatar, tên, email, số điện thoại, địa chỉ, nút chỉnh sửa, nút đăng xuất.

> Ưu tiên implement: **Nhóm A → 6,7,8 (auth) → 10 (Fighter Record) → 9,11,12,13,14**. Nếu giới hạn thời gian, có thể chỉ làm Nhóm A + auth trước, các màn còn lại làm placeholder có điều hướng nhưng nội dung tối giản, miễn giữ đúng structure/navigation.

---

## 5. Mock data cần chuẩn bị (`lib/data/mock_data.dart`)

- `mockMember`: tên "Minh", gói "GÓI A", 3 buổi/tuần (T2/T4/T6, 16:30), hết hạn 20/09/2026, đã tập 6/12 buổi, điểm tích lũy 350, streak 4.
- `mockExercises` (8 item), `mockChallenges` (3 item) — copy y nguyên dữ liệu từ JS `EXERCISES`/`CHALLENGES` trong `app.html`.
- `mockWeekSchedule` (7 ngày, trạng thái done/pending/today).
- `mockRanks`: 7 hạng theo tên trong tài liệu DP V2 (THE UNKNOWN → THE LEGACY) kèm ngưỡng DP giả định tăng dần.
- `mockNotifications`, `mockChallengesOpen`, `mockArmoryRewards`: tự tạo 4–8 item mỗi loại, đủ để UI không bị trống.

---

## 6. Cấu trúc thư mục đề xuất

```
lib/
  main.dart
  theme/
    app_theme.dart
  data/
    mock_data.dart
    models.dart          // Member, Exercise, Challenge, Session, Rank, Notification, Reward...
  screens/
    splash_screen.dart
    auth/
      login_screen.dart
      signup_screen.dart
      forgot_password_screen.dart
    home/
      home_shell.dart      // chứa Scaffold + BottomNavigationBar
      home_screen.dart
      schedule_screen.dart
      workout_screen.dart
      checkin_screen.dart
    notifications_screen.dart
    fighter_record_screen.dart
    streak_screen.dart
    challenges_screen.dart
    armory_screen.dart
    profile_screen.dart
  widgets/
    package_card.dart
    stat_card.dart
    exercise_tile.dart
    challenge_card.dart
    ...
```

---

## 7. Checklist chấp nhận (Definition of Done)

- [ ] Chạy được bằng `flutter run -d chrome` không lỗi.
- [ ] 4 màn hình Nhóm A khớp bố cục/nội dung/copy với `app.html` (màu sắc, font, spacing, thứ tự thành phần).
- [ ] Logic tính điểm bài tập + milestone + challenge trong màn "Bài tập" hoạt động đúng như JS gốc, và điểm cộng dồn phản ánh ở "Điểm tích lũy" Trang chủ.
- [ ] Check-in có countdown 30s + trạng thái loading/success như mockup.
- [ ] Luồng auth (Login/SignUp/Forgot Password) điều hướng đúng, hiện đúng MSG tương ứng ở các trường hợp lỗi/thành công.
- [ ] Các màn Nhóm B dùng chung theme (màu/font/radius) với Nhóm A, không lệch phong cách.
- [ ] Không có lời gọi network/API thật nào trong code — toàn bộ dữ liệu từ `mock_data.dart`.
- [ ] Code chia nhỏ theo widget hợp lý, không dồn hết vào 1 file như `app.html`.

---

## 8. Lưu ý cho agent

- Nếu một chi tiết trong SRS mâu thuẫn với `app.html` (ví dụ công thức điểm khác nhau), **ưu tiên `app.html`** cho các màn Nhóm A vì đây là UI đã được duyệt; dùng SRS chỉ để hiểu ngữ cảnh nghiệp vụ và đặt tên biến/trạng thái hợp lý.
- Đây là bản UI prototype — không cần implement chính xác 100% mọi business rule/edge case trong SRS (idempotency key, audit log, RBAC...), chỉ cần UI thể hiện đúng các trạng thái/kết quả mà business rule đó tạo ra.
- Giữ toàn bộ text hiển thị bằng tiếng Việt, đúng chính tả như trong 2 tài liệu nguồn.
