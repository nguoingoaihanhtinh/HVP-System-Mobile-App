import 'models.dart';

const exercises = [
  Exercise('🦵', 'Squat tạ', '4 hiệp × 12 lần'),
  Exercise('🏃', 'Lunge bước dài', '3 hiệp × 10 lần / bên'),
  Exercise('🧎', 'Hip thrust', '4 hiệp × 15 lần'),
  Exercise('🪢', 'Plank giữ core', '3 hiệp × 45 giây'),
  Exercise('🔁', 'Mountain climber', '3 hiệp × 30 giây'),
  Exercise('🧘', 'Glute bridge', '3 hiệp × 15 lần'),
  Exercise('🪑', 'Wall sit', '3 hiệp × 40 giây'),
  Exercise('🌀', 'Giãn cơ kết thúc', '5 phút cooldown'),
];
const challenges = [
  Challenge(
      '⚡',
      'Không nghỉ giữa hiệp',
      'Hoàn thành toàn bộ bài tập với thời gian nghỉ dưới 30 giây giữa mỗi hiệp.',
      15),
  Challenge('🏋️', 'Tăng mức tạ',
      'Tăng thêm 2.5kg so với buổi trước cho squat và hip thrust.', 15),
  Challenge('❤️', 'Giữ nhịp tim vùng đốt mỡ',
      'Duy trì nhịp tim trong vùng 70–80% suốt buổi tập.', 20),
];
const notices = [
  Notice('✅', 'WORK DONE',
      'Bạn đã hoàn thành buổi tập. +45 DP đã được cập nhật.', '2 giờ trước'),
  Notice('⚡', '120 DP REMAIN', 'Chỉ còn 120 DP để mở khóa hạng tiếp theo.',
      'Hôm qua'),
  Notice('🏆', 'RANK EARNED', 'Bạn đã sẵn sàng viết tiếp câu chuyện của mình.',
      '2 ngày trước'),
  Notice('🔥', 'ĐỪNG ĐỂ CHUỖI DỪNG LẠI',
      'Bạn còn một buổi tập để bảo toàn streak tuần này.', '3 ngày trước'),
  Notice('🧊', 'THE STREAK ENDS',
      'Streak Freeze đã được dùng để bảo toàn chuỗi của bạn.', '5 ngày trước'),
  Notice('🎒', 'YOU’VE BEEN GONE FOR 7 DAYS',
      'Phòng tập đang chờ bạn quay lại.', '1 tuần trước'),
  Notice('🎁', 'YOUR MARKS ARE WAITING', 'Có phần thưởng mới trong The Armory.',
      '1 tuần trước'),
];
