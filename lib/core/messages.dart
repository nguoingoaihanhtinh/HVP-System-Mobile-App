/// Messages shown to the user. Codes MSG1–MSG35 come from SRS.docx.
class Msg {
  final String code;
  final String text;

  const Msg(this.code, this.text);

  String get display => '$code · $text';

  /// Copy with `{name}` placeholders replaced.
  Msg fill(Map<String, Object> values) {
    var result = text;
    values.forEach((key, value) => result = result.replaceAll('{$key}', '$value'));
    return Msg(code, result);
  }

  @override
  String toString() => display;
}

class Msgs {
  // UC1 Sign up
  static const invalidInput =
      Msg('MSG1', 'Vui lòng kiểm tra lại thông tin. Hãy điền đầy đủ và đúng định dạng.');
  static const emailTaken =
      Msg('MSG2', 'Email này đã được đăng ký. Vui lòng dùng email khác hoặc đăng nhập.');
  static const accountCreated = Msg('MSG3', 'Tài khoản đã được tạo thành công!');
  static const redirectLogin =
      Msg('MSG4', 'Đang chuyển tới đăng nhập... Bạn có thể đăng nhập bằng tài khoản mới.');

  // UC2 Login
  static const loginMissing = Msg('MSG5', 'Vui lòng nhập email/username và mật khẩu.');
  static const loginFailed = Msg('MSG6', 'Đăng nhập thất bại. Sai email hoặc mật khẩu.');
  static const loginSuccess = Msg('MSG7', 'Đăng nhập thành công. Chào mừng trở lại!');
  static const loginAlertSent = Msg('MSG8', 'Thông báo đăng nhập đã được gửi tới email của bạn.');

  // UC3 Forgot password
  static const phoneNotRegistered =
      Msg('MSG9', 'Số điện thoại chưa được đăng ký. Vui lòng kiểm tra lại.');
  static const pinSent = Msg('MSG10', 'Mã PIN đã được gửi tới điện thoại của bạn.');
  static const pinInvalid = Msg('MSG11', 'Mã PIN không đúng hoặc đã hết hạn. Vui lòng yêu cầu mã mới.');
  static const passwordRule =
      Msg('MSG12', 'Mật khẩu cần tối thiểu 8 ký tự, gồm chữ và số, và phải khớp xác nhận.');
  static const passwordUpdated = Msg('MSG13', 'Mật khẩu đã được cập nhật thành công.');
  static const redirectLoginNewPassword =
      Msg('MSG14', 'Đang chuyển tới đăng nhập. Bạn có thể đăng nhập bằng mật khẩu mới.');

  // Shared with UC4 check-in
  static const membershipExpired =
      Msg('MSG18', 'Gói tập của bạn đã hết hạn hoặc hết số buổi. Vui lòng gia hạn để tiếp tục.');

  // Core idempotency
  static const duplicateTransaction = Msg('MSG33',
      'Giao dịch cho sự kiện này đã được ghi nhận trước đó. Hệ thống bỏ qua để tránh cộng trùng.');

  // UC15 BR122 reconciliation (code from HVP_Database_Design.md).
  static const balanceMismatch = Msg('MSG41',
      'Số dư Marks khi mở băng khác với lúc đóng băng. Đã ghi nhận để đối soát.');

  // UC14–UC17. Provisional codes: replace with the codes in SRS_Hung.
  static const renewalMissing =
      Msg('UC14-E1', 'Vui lòng chọn gói mong muốn và kênh liên hệ.');
  static const renewalDuplicate = Msg('UC14-E2',
      'Bạn đã có một yêu cầu gia hạn đang chờ xử lý. Lễ tân sẽ liên hệ với bạn sớm.');
  static const renewalSent =
      Msg('UC14-S1', 'Đã gửi yêu cầu gia hạn. Lễ tân sẽ liên hệ để tư vấn và thu phí tại quầy.');
  static const renewalCompleted = Msg('UC14-S2', 'Gia hạn thành công: {package}.');
  static const renewalCancelled = Msg('UC14-S3', 'Yêu cầu gia hạn đã bị huỷ. Lý do: {reason}.');
  static const cancelReasonRequired = Msg('UC14-E3', 'Vui lòng nhập lý do huỷ.');
  static const requestNotPending = Msg('UC14-E4', 'Yêu cầu này đã được xử lý.');
  static const alreadyScheduled =
      Msg('UC14-E5', 'Học viên đã có một gói nối tiếp đang chờ kích hoạt.');
  static const earlyRenewalBonus =
      Msg('UC14-S4', 'Gia hạn sớm: +{marks} Marks (1 lần cho mỗi gói).');

  static const marksFrozen = Msg('UC15-I1',
      'YOUR MARKS ARE WAITING. Gói tập đã hết hạn, Marks được đóng băng và giữ nguyên số dư.');
  static const restricted = Msg('UC15-E1',
      'Tài khoản đang ở chế độ hạn chế. Gia hạn gói tập để đổi quà và check-in.');
  static const marksUnfrozen = Msg('UC15-S1', 'Marks đã sẵn sàng sử dụng ({marks} Marks).');

  static const inactiveWarning = Msg('UC16-I1',
      'Tài khoản sẽ chuyển sang trạng thái không hoạt động sau {days} ngày nữa. Dữ liệu điểm của bạn vẫn được lưu.');
  static const accountInactive = Msg('UC16-I2',
      'Tài khoản không hoạt động. Toàn bộ DP, hạng và HVP Marks vẫn được lưu.');
  static const viewOnly = Msg('UC16-I3',
      'Chế độ chỉ xem. Kích hoạt gói tập để tiếp tục hành trình.');

  static const comebackGranted =
      Msg('UC17-S1', 'WELCOME BACK. Sau {days} ngày vắng, bạn nhận +{dp} DP.');
}
