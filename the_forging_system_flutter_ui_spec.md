# PROMPT: Xây dựng Flutter UI Prototype theo SRS --- The Forging System

## 0. Vai trò và nguyên tắc quan trọng

Bạn là một **Senior Flutter Engineer + UI/UX Engineer**.

Nhiệm vụ: đọc kỹ `SRS.docx` và xây dựng một **Flutter UI Prototype** cho
**The Forging System / HVP Boxing**.

Đây là prototype: - Không backend. - Không API thật. - Không database. -
Không authentication thật. - Dữ liệu sử dụng mock data. - Các thao tác
Create/Update/Approve/Check-in được giả lập bằng local state. - Phải
chạy được bằng `flutter pub get` và `flutter run -d chrome`.

### Quy tắc quan trọng nhất

**SRS.docx là nguồn nghiệp vụ chính xác chính.**

Không tự tạo business rule khác với SRS. Không biến hệ thống thành
generic fitness/workout app.

Đặc biệt: **Học viên không được tự tick exercise để tự cộng DP.**

Core flow phải phản ánh nghiệp vụ trong SRS:

``` text
Check-in
  ↓
Coach xác nhận Attendance
  ↓
Coach nhập % hoàn thành
  ↓
completionPercent >= threshold
  ↓
System tính DP
  ↓
PointTransaction
  ↓
Rank Engine kiểm tra điều kiện lên hạng
```

Check-in chỉ ghi nhận sự hiện diện/cập nhật membership. DP/Marks phát
sinh theo các nghiệp vụ được SRS quy định.

------------------------------------------------------------------------

## 1. Phân chia ứng dụng theo Role

Prototype phải có **2 giao diện riêng biệt**:

-   **STUDENT / MEMBER**
-   **ADMIN**

Không sử dụng cùng một Dashboard rồi chỉ ẩn/hiện vài button.

Mỗi role phải có: - Navigation riêng. - Dashboard riêng. - Các màn hình
nghiệp vụ riêng. - Layout phù hợp với role.

------------------------------------------------------------------------

## 2. Login và Role Selection

Dựa trên: - UC1 --- SignUp - UC2 --- Login - UC3 --- Forgot Password

Prototype:

``` text
Splash
  ↓
Login
  ↓
Mock Role Selection
  ├── Student
  └── Admin
```

Role Selection chỉ phục vụ demo UI, không phải business rule thật.

Có thể dùng tài khoản mock:

``` text
student@hvp.demo
admin@hvp.demo
```

------------------------------------------------------------------------

# PHẦN A --- STUDENT / MEMBER

## 3. Student Navigation

Student là giao diện mobile-first.

``` text
StudentShell

BottomNavigationBar
├── Home
├── Check-in
├── Fighter Record
├── Activity
└── Profile
```

Các feature phụ mở từ Home/Activity: - DP History - Training History -
Streak - Challenges - The Armory - Notifications

Không đưa chức năng Admin vào Student navigation.

------------------------------------------------------------------------

## 4. Student --- Home Dashboard

### Header

Hiển thị: - Xin chào, Minh - Current Rank - DP Balance - Notification -
Avatar

### Membership Card

Hiển thị: - Tên gói - Trạng thái - Ngày hết hạn - Số buổi còn lại - Chi
nhánh

### Quick Actions

-   QR Check-in
-   Fighter Record
-   Streak
-   Challenges
-   The Armory

### Current Progress

-   DP Balance
-   Current Rank
-   Next Rank
-   DP progress
-   Current Streak
-   Sessions this week

------------------------------------------------------------------------

## 5. Student --- QR Check-in

Implement theo **UC4 --- Checkin buổi tập**.

``` text
Open Check-in
  ↓
QR Scanner
  ↓
Validate QR
  ↓
Validate location
  ↓
Validate membership
  ↓
Success / Error
```

Prototype không cần camera thật.

Dựng QR scanner giả lập: - QR frame. - Scan animation. - Countdown
30s. - Mock QR. - Button scan/confirm.

Mock được các trường hợp: - Success - QR expired - QR already used -
Invalid location - Membership expired - No sessions remaining

Sử dụng đúng message code tương ứng trong SRS, gồm
MSG15/MSG17/MSG18/MSG19 và các message liên quan nếu có.

Khi thành công hiển thị: - Check-in thành công - Time - Branch -
Membership remaining sessions

### Quan trọng

**Không cộng DP ngay khi Check-in.**

------------------------------------------------------------------------

## 6. Student --- Training History

Tạo màn hình `My Training`.

Mỗi session hiển thị: - Date - Session Type - Coach - Check-in -
Attendance - Completion % - DP earned - Status

Các trạng thái: - Checked-in - Waiting for coach confirmation -
Completed - Below threshold - Absent

Student không được tự chỉnh: - Attendance - Completion % - DP

------------------------------------------------------------------------

## 7. Student --- DP / Marks

Tạo màn `My DP`.

Hiển thị: - Current DP Balance - Current Rank - DP to next rank -
Transaction History

PointTransaction mock có thể thể hiện các source được SRS hỗ trợ, ví
dụ: - Session - Attitude - Academy - Rank Trial - Challenge (nếu SRS quy
định) - Manual Adjustment / Reversal

DP được biểu diễn theo transaction ledger. Không sửa trực tiếp history
cũ.

------------------------------------------------------------------------

## 8. Student --- Fighter Record

Hiển thị: - Current Rank - Rank progression - DP progress - Next Rank -
Eligibility gates - Rank Trial state

Các trạng thái nghiệp vụ: - IN PROGRESS - DP COMPLETED - TRIAL
REQUIRED - APPROVAL REQUIRED - RANK EARNED

### Eligibility

Hiển thị riêng: - DP Gate - Time Gate - Course Gate - Trial Gate

Ví dụ:

``` text
✓ DP requirement
✓ Minimum training time
✕ Required Academy course
— Rank Trial
```

Nếu SRS không cung cấp threshold cụ thể, mock value chỉ phục vụ UI và
phải được đánh dấu:

``` dart
// MOCK VALUE FOR UI PROTOTYPE ONLY.
// Replace with configured value from backend.
```

------------------------------------------------------------------------

## 9. Student --- Request Rank Trial

Chỉ cho phép request khi trạng thái nghiệp vụ phù hợp, ví dụ
`TRIAL_REQUIRED`.

``` text
Fighter Record
  ↓
Request Rank Trial
  ↓
Eligibility Check
  ↓
Pending Approval
```

Kiểm tra các gate theo SRS: - DP threshold - Time gate - Course gate

Student chỉ được: - Request - View status - View result

Student không được: - Approve - Reject - Enter trial result - Upgrade
rank manually

------------------------------------------------------------------------

## 10. Student --- Streak

Implement theo use case Streak trong SRS.

Hiển thị: - Current Streak - Sessions this week - Weekly requirement -
Available Freeze - Freeze usage - Weekly history

Các kết quả nghiệp vụ cần thể hiện: - INCREASED - FROZEN - RESET

Student không tự chỉnh kết quả Streak/Freeze nếu SRS quy định System xử
lý.

------------------------------------------------------------------------

## 11. Student --- Challenges

UI phải phản ánh lifecycle trong SRS, không biến Challenge thành cơ chế
tự cộng điểm tùy ý.

Các trạng thái: - OPEN - JOINED - COMPLETED - REWARDED - EXPIRED

Challenge card: - Name - Description - Progress - Start Date - End
Date - Reward - Status

Action tùy trạng thái: - Join - View Progress - Claim Reward

Chỉ sử dụng reward/business rule mà SRS hỗ trợ.

------------------------------------------------------------------------

## 12. Student --- The Armory

Header:

``` text
THE ARMORY
Available Marks
350 DP
```

Reward card: - Reward - Required DP - Availability

Lifecycle:

``` text
Select reward
  ↓
Confirm redemption
  ↓
Pending pickup
  ↓
Ready for pickup
  ↓
Received
```

Không cho Student tự xác nhận `Received` nếu SRS yêu cầu nhân sự khác
xác nhận giao quà.

------------------------------------------------------------------------

## 13. Student --- Notifications

Notification Center dựa trên event trong SRS.

Có thể gồm: - Session completed - DP updated - Near rank - Rank earned -
Streak warning - Streak lost - Inactive reminder - Membership - Armory
reward

Notification card: - Icon - Title - Content - Timestamp - Read / Unread

------------------------------------------------------------------------

## 14. Student --- Profile

Hiển thị: - Avatar - Full name - Email - Phone - Address - Membership -
Current Rank - Join date

Actions: - Edit Profile - Change Password - Logout

------------------------------------------------------------------------

# PHẦN B --- ADMIN

## 15. Admin Layout

Admin là **desktop/tablet-first dashboard**.

Không dùng BottomNavigationBar giống Student.

Dùng `NavigationRail`, Sidebar hoặc Drawer responsive.

``` text
┌──────────────┬─────────────────────────────────┐
│ Dashboard    │ Header                          │
│ Members      ├─────────────────────────────────┤
│ DP           │                                 │
│ Rank Trials  │          Main Content           │
│ Challenges   │                                 │
│ Armory       │                                 │
│ Config       │                                 │
│ RBAC         │                                 │
│ Audit Logs   │                                 │
└──────────────┴─────────────────────────────────┘
```

------------------------------------------------------------------------

## 16. Admin --- Dashboard

Hiển thị overview: - Active Members - Today's Check-ins - Pending Rank
Trials - DP Transactions - Active Challenges - Pending Armory Pickups

Thêm: - Recent Activity - Recent DP Adjustments - Pending Approvals

Tất cả số liệu là mock data nhưng phải nhất quán với shared state.

------------------------------------------------------------------------

## 17. Admin --- Member Management

Table: - Member - Email - Membership - Rank - DP - Streak - Status -
Action

Search/filter: - Name - Rank - Membership - Status

Member Detail: - Personal Information - Membership - Training History -
DP Transactions - Fighter Record - Streak - Rank Trial History - Audit
History

------------------------------------------------------------------------

## 18. Admin --- DP Management

Tạo màn `DP Transactions`.

Table: - Transaction ID - Member - Source - Amount - Session - Created
At - Actor - Status

Các source phải bám SRS. Có thể gồm: - SESSION - ATTITUDE - ACADEMY -
RANK_TRIAL - CHALLENGE (nếu SRS hỗ trợ) - MANUAL_ADJUSTMENT - REVERSAL

------------------------------------------------------------------------

## 19. Admin --- Manual DP Adjustment

Admin chọn: - Member - Original transaction (optional) - Adjustment
type - Amount - Reason

Không sửa/xóa transaction gốc.

Adjustment phải tạo transaction mới.

``` text
Original Transaction
  ↓
Adjustment / Reversal Transaction
```

Confirmation dialog: - Member - Current Balance - Adjustment - New
Balance - Reason

Sau confirm: - Create PointTransaction - Create AuditLog - Update
displayed balance

------------------------------------------------------------------------

## 20. Admin --- Rank Trial Management

Table: - Member - Current Rank - Target Rank - Requested At - Approver -
Status

Statuses: - PENDING - PASSED - FAILED

Detail: - Member - DP - Time Gate - Course Gate - Target Rank - Request
Date - Trial Result - Note

Không giả định Admin duyệt mọi Rank Trial.

Nếu SRS quy định Rank V--VI thuộc Coach/Head Coach và Rank VII thuộc
Admin thì phải giữ đúng phân quyền đó.

Rank Trial thuộc Coach có thể hiển thị `Assigned to Coach`, Admin không
được tự có action Approve nếu không có quyền theo SRS.

------------------------------------------------------------------------

## 21. Admin --- Challenge Management

Table: - Challenge - Start - End - Reward - Participants - Status

Actions theo SRS: - Create - View - Edit - Activate - Close

Challenge Detail: - Description - Eligibility - Period - Reward -
Participants - Completion - Reward Status

Không tạo rule mới ngoài SRS.

------------------------------------------------------------------------

## 22. Admin --- Armory Management

Quản lý: - Rewards - Redemption Requests

Rewards: - Name - Required DP - Stock - Status

Redemption: - Member - Reward - Cost - Requested At - Status

Nếu nghiệp vụ giao quà thuộc Reception thì Admin không được tự nhận
quyền Reception. UI phải phản ánh đúng actor.

------------------------------------------------------------------------

## 23. Admin --- System Configuration

### DP Configuration

Ví dụ các trường nếu được SRS hỗ trợ: - Completion threshold - Session
point configuration - Maximum/cap configuration

Session types phải lấy theo SRS, không tự tạo.

### Rank Configuration

-   Rank
-   DP Threshold
-   Minimum Time
-   Required Course
-   Trial Required
-   Approval Required

### Streak Configuration

-   Weekly minimum sessions
-   Weekly closing time
-   Freeze rules
-   Max freeze usage

### Coach Point Limits

-   Attitude point
-   Daily limit
-   Monthly limit

### Notification Configuration

-   Event
-   Template
-   Enabled
-   Timing

Chỉ hiển thị config thực sự được SRS hỗ trợ.

------------------------------------------------------------------------

## 24. Admin --- RBAC

Tạo màn `Roles & Permissions`.

Roles phải dựa trên actor/role trong SRS. Ví dụ nếu có: - Super Admin -
Admin - Coach - Reception - Member

Permission matrix có thể thể hiện: - `system:config` - `dp:adjust` -
`rank:approve` - `challenge:manage` - `armory:manage` - `role:manage`

Chỉ sử dụng permission cụ thể nếu SRS có định nghĩa hoặc đánh dấu rõ là
mock UI.

Actions: - Create Role - Edit Role - Assign Permission - Assign Role -
Revoke Role

Không hard-code rằng mọi Admin có mọi permission.

------------------------------------------------------------------------

## 25. Admin --- Audit Logs

Table: - Timestamp - Actor - Action - Target - Before - After - Reason

Filter: - Actor - Action - Date - Member

Event mock có thể gồm: - DP_ADJUSTED - DP_REVERSED - RANK_APPROVED -
CONFIG_CHANGED - ROLE_ASSIGNED - CHALLENGE_UPDATED

Chỉ dùng event phù hợp nghiệp vụ SRS.

------------------------------------------------------------------------

# PHẦN C --- BUSINESS & ARCHITECTURE RULES

## 26. Những flow không được tạo sai nghiệp vụ

Không implement Student kiểu:

``` text
Today's Workout

☐ Push-up
☐ Squat
☐ Jab
☐ Cross

Complete → +50 DP
```

nếu SRS không có flow này.

Không cho Student: - Tự nhập completion % - Tự xác nhận attendance - Tự
cộng DP - Tự upgrade rank - Tự approve Rank Trial - Tự chỉnh Streak - Tự
xác nhận đã nhận quà khi actor khác chịu trách nhiệm

------------------------------------------------------------------------

## 27. Shared State Architecture

Dùng một shared state:

``` text
AppState
├── authState
├── currentUser
├── members
├── memberships
├── checkins
├── attendances
├── pointTransactions
├── ranks
├── rankTrials
├── streaks
├── challenges
├── rewards
├── redemptions
├── notifications
├── systemConfig
├── roles
├── permissions
└── auditLogs
```

Có thể dùng `ChangeNotifier + Provider` hoặc Riverpod.

Chọn một cách và giữ nhất quán.

------------------------------------------------------------------------

## 28. Mock data phải liên kết

Không tạo dữ liệu độc lập cho từng screen.

Ví dụ Student DP = 350 thì: - Student Home - Fighter Record - My DP -
Admin Member Detail - Admin DP Management

đều phải hiển thị cùng balance.

Nếu Admin tạo Manual Adjustment +20:

``` text
350 → 370
```

thì tất cả màn liên quan phải cập nhật.

Tương tự:

``` text
Rank Trial approved
  ↓
Rank thay đổi
  ↓
Fighter Record cập nhật
  ↓
Notification được tạo
  ↓
Audit Log xuất hiện
```

------------------------------------------------------------------------

## 29. Responsive Design

### Student

Ưu tiên mobile 360--430px.

Khi chạy Web, có thể giới hạn:

``` dart
maxWidth: 430
```

để giữ trải nghiệm mobile.

### Admin

Responsive cho: - Tablet - Laptop - Desktop

Desktop: - Sidebar + Content

Màn nhỏ: - Drawer + Content

Không render Admin như mobile app phóng lớn.

------------------------------------------------------------------------

## 30. Design System

Có thể sử dụng phong cách Dark / Boxing / Industrial.

Gợi ý token:

  Token        Value
  ------------ -----------
  Background   `#05060D`
  Surface      `#12162A`
  Card         `#1F2647`
  Primary      `#FF6A3D`
  Success      `#2ED1B0`
  Warning      `#FFC352`
  Text         `#ECEDF3`
  Text muted   `#9298B8`

Student: - Sporty - Large numbers - Progress visualization - Cards -
Strong CTA

Admin: - Data dense - Tables - Filters - Status chips - Forms -
Dialogs - Side navigation

Cả hai dùng chung branding.

------------------------------------------------------------------------

## 31. Cấu trúc source code

``` text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── app_state.dart
├── core/
│   ├── theme/
│   ├── constants/
│   └── widgets/
├── data/
│   ├── models/
│   ├── mock/
│   └── repositories/
├── features/
│   ├── auth/
│   ├── student/
│   │   ├── home/
│   │   ├── checkin/
│   │   ├── training/
│   │   ├── dp/
│   │   ├── fighter_record/
│   │   ├── rank_trial/
│   │   ├── streak/
│   │   ├── challenges/
│   │   ├── armory/
│   │   ├── notifications/
│   │   └── profile/
│   └── admin/
│       ├── dashboard/
│       ├── members/
│       ├── dp_management/
│       ├── rank_trials/
│       ├── challenges/
│       ├── armory/
│       ├── notifications/
│       ├── system_config/
│       ├── rbac/
│       └── audit_logs/
└── shared/
    ├── models/
    └── widgets/
```

Không dồn toàn bộ app vào `main.dart`.

------------------------------------------------------------------------

## 32. Quy tắc khi SRS không đủ thông tin

Nếu SRS không cung cấp giá trị cụ thể như: - DP threshold - Rank value -
Challenge reward - Reward price - Membership price - Các config numeric
khác

thì **không được tự coi giá trị giả là business rule**.

Có thể tạo mock để render UI nhưng phải đánh dấu:

``` dart
// MOCK VALUE FOR UI PROTOTYPE ONLY
```

Không để mock value trông như requirement chính thức.

------------------------------------------------------------------------

## 33. Quy tắc xử lý mâu thuẫn

Thứ tự ưu tiên:

``` text
1. SRS.docx
2. Business Rules trong từng Use Case
3. Message definitions trong SRS
4. Activity Diagram
5. Mock data chỉ phục vụ UI
```

Không để mockup hoặc ý tưởng UI override SRS.

Nếu requirement mâu thuẫn ngay trong SRS:

``` dart
// TODO(SRS-CONFLICT): describe the conflict here.
```

Không silently invent business rule để giải quyết.

------------------------------------------------------------------------

## 34. Definition of Done

Prototype hoàn thành khi:

-   [ ] Student và Admin có hai giao diện riêng biệt.
-   [ ] Student không thấy chức năng quản trị.
-   [ ] Admin dùng Sidebar/desktop dashboard.
-   [ ] Check-in bám UC4.
-   [ ] Check-in không tự cộng DP.
-   [ ] Attendance/completion không do Student chỉnh.
-   [ ] DP được biểu diễn bằng PointTransaction.
-   [ ] Fighter Record thể hiện Rank Gate.
-   [ ] Rank Trial đúng actor/quyền trong SRS.
-   [ ] Streak phản ánh đúng trạng thái nghiệp vụ.
-   [ ] Challenge phản ánh lifecycle trong SRS.
-   [ ] Armory phản ánh redemption lifecycle.
-   [ ] Admin có Manual DP Adjustment nếu SRS quy định.
-   [ ] Manual Adjustment không sửa transaction gốc.
-   [ ] Admin có System Configuration theo SRS.
-   [ ] Admin có RBAC theo SRS.
-   [ ] Admin có Audit Logs.
-   [ ] Student/Admin dùng chung mock state.
-   [ ] Không gọi API thật.
-   [ ] Không backend.
-   [ ] Không lỗi compile.
-   [ ] Chạy được bằng `flutter run -d chrome`.

------------------------------------------------------------------------

## 35. Cách triển khai bắt buộc

**Trước khi code:**

1.  Đọc toàn bộ `SRS.docx`.
2.  Liệt kê tất cả Actor.
3.  Liệt kê tất cả Use Case.
4.  Mapping Use Case → Student / Admin / System / Coach / Reception.
5.  Mapping Business Rule → màn hình cần thể hiện.
6.  Mapping MSG → UI state.
7.  Xác định feature nào thuộc Student và feature nào thuộc Admin.
8.  Xác định dữ liệu nào chỉ được xem và dữ liệu nào role đó được phép
    thay đổi.
9.  Sau đó mới thiết kế navigation.
10. Sau khi mapping xong mới bắt đầu code.

**Không bắt đầu code chỉ dựa vào tên màn hình trong prompt này.**

Nếu prompt và SRS khác nhau về nghiệp vụ:

> **SRS luôn thắng.**
