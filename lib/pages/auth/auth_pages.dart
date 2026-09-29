import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/repositories.dart';
import '../../core/messages.dart';
import '../../core/result.dart';
import '../../data/mock/mock_db.dart';
import '../../data/models/member.dart';
import '../../data/repositories/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/busy_button.dart';
import '../../widgets/shared_widgets.dart';
import '../admin/admin_pages.dart';
import '../staff/staff_pages.dart';
import '../student/student_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_mma, size: 70, color: AppColors.accent),
            SizedBox(height: 16),
            Text('HVP BOXING',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Text('DISCIPLINE BUILDS CHAMPIONS',
                style: TextStyle(color: AppColors.dim, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// Clears the stack and opens Login, e.g. after sign-up (MSG4) or a
/// password reset (MSG14).
void openLogin(BuildContext context, {String? email, Msg? notice}) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (_) => LoginScreen(prefillEmail: email, notice: notice)),
    (_) => false,
  );
}

/// UC2 Login.
class LoginScreen extends StatefulWidget {
  final String? prefillEmail;
  final Msg? notice;

  const LoginScreen({super.key, this.prefillEmail, this.notice});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final emailController = TextEditingController(text: widget.prefillEmail);
  final passwordController = TextEditingController();
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final result = await Repositories.auth
        .login(emailController.text, passwordController.text);
    if (!mounted) return;
    switch (result) {
      case Err(:final message):
        setState(() => error = message.display);
      case Ok(:final value, :final message):
        setState(() => error = null);
        final member = Repositories.membership.member(value.user.id);
        showMessage(
            context,
            member?.status == MemberStatus.inactive
                ? Msgs.viewOnly.display
                : message!.display);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập để tiếp tục hành trình của bạn',
      children: [
        if (widget.notice != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(widget.notice!.display,
                style: const TextStyle(color: AppColors.teal)),
          ),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email hoặc username'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          onSubmitted: (_) => login(),
          decoration: const InputDecoration(labelText: 'Mật khẩu'),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(error!, style: const TextStyle(color: AppColors.accent)),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ForgotScreen())),
            child: const Text('Quên mật khẩu?'),
          ),
        ),
        BusyButton(label: 'ĐĂNG NHẬP', onPressed: login),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SignupScreen())),
          child: const Text('Chưa có tài khoản? Đăng ký'),
        ),
        const SizedBox(height: 8),
        const Text(
            'Demo: minh · reception@hvp.demo · admin@hvp.demo · coach@hvp.demo\n'
            'Mật khẩu: ${MockDb.demoPassword}',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.faint, fontSize: 12)),
      ],
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Repositories.auth.currentSession?.user;
    return AuthLayout(
      title: 'Chọn giao diện demo',
      subtitle: user == null
          ? 'Role Selection chỉ phục vụ prototype UI.'
          : 'Đăng nhập: ${user.fullName} · Role Selection chỉ phục vụ prototype UI.',
      children: [
        FilledButton.icon(
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomeShell(onSwitchRole: _openRoleSelection))),
          icon: const Icon(Icons.person_outline),
          label: const Text('STUDENT / MEMBER'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AdminShell(onSwitchRole: _openRoleSelection))),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text('ADMIN'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      StaffShell(onSwitchRole: _openRoleSelection))),
          icon: const Icon(Icons.support_agent_outlined),
          label: const Text('STAFF / COACH / LỄ TÂN'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            await Repositories.auth.logout();
            if (context.mounted) openLogin(context);
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    );
  }

  void _openRoleSelection(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
  }
}

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthLayout(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.sports_mma, color: AppColors.accent, size: 48),
              const SizedBox(height: 28),
              Text(title,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: AppColors.dim)),
              const SizedBox(height: 30),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// UC1 Sign up.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  String? error;

  @override
  void dispose() {
    for (final controller in [name, email, phone, address, password, confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    final result = await Repositories.auth.signUp(SignUpData(
      fullName: name.text,
      email: email.text,
      phone: phone.text,
      address: address.text,
      password: password.text,
      confirmPassword: confirm.text,
    ));
    if (!mounted) return;
    switch (result) {
      case Err(:final message):
        setState(() => error = message.display);
      case Ok(:final value, :final message):
        showMessage(context, message!.display);
        openLogin(context, email: value.email, notice: Msgs.redirectLogin);
    }
  }

  Widget _field(TextEditingController controller, String label,
          {bool obscure = false, TextInputType? type}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Tạo tài khoản',
      subtitle: 'Bắt đầu xây dựng phiên bản mạnh mẽ hơn',
      children: [
        _field(name, 'Họ và tên'),
        _field(email, 'Email', type: TextInputType.emailAddress),
        _field(phone, 'Số điện thoại', type: TextInputType.phone),
        _field(address, 'Địa chỉ (không bắt buộc)'),
        _field(password, 'Mật khẩu (≥ 8 ký tự, có chữ và số)', obscure: true),
        _field(confirm, 'Xác nhận mật khẩu', obscure: true),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(error!, style: const TextStyle(color: AppColors.accent)),
          ),
        BusyButton(label: 'ĐĂNG KÝ', onPressed: submit),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đã có tài khoản? Đăng nhập'),
        ),
      ],
    );
  }
}

/// UC3 Forgot password: phone → PIN → new password.
class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final phone = TextEditingController();
  final pin = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  PinChallenge? challenge;
  String? resetToken;
  String? error;

  @override
  void dispose() {
    for (final controller in [phone, pin, password, confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> sendPin() async {
    final result = await Repositories.auth.requestPasswordReset(phone.text);
    if (!mounted) return;
    switch (result) {
      case Err(:final message):
        setState(() => error = message.display);
      case Ok(:final value, :final message):
        setState(() {
          challenge = value;
          error = null;
        });
        // Mock only: there is no SMS gateway, so show the PIN.
        showMessage(context,
            '${message!.display}${value.debugPin == null ? '' : ' (PIN demo: ${value.debugPin})'}');
    }
  }

  Future<void> verifyPin() async {
    final result =
        await Repositories.auth.verifyPin(challenge!.requestId, pin.text);
    if (!mounted) return;
    switch (result) {
      case Err(:final message):
        setState(() => error = message.display);
      case Ok(:final value):
        setState(() {
          resetToken = value;
          error = null;
        });
    }
  }

  Future<void> resetPassword() async {
    final result = await Repositories.auth
        .resetPassword(resetToken!, password.text, confirm.text);
    if (!mounted) return;
    switch (result) {
      case Err(:final message):
        setState(() => error = message.display);
      case Ok(:final message):
        showMessage(context, message!.display);
        openLogin(context, notice: Msgs.redirectLoginNewPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = resetToken != null ? 2 : (challenge != null ? 1 : 0);
    final subtitle = switch (step) {
      0 => 'Nhập số điện thoại để nhận mã PIN',
      1 => 'Nhập mã PIN đã gửi tới ${challenge!.maskedPhone}',
      _ => 'Tạo mật khẩu mới',
    };
    return AuthLayout(
      title: 'Khôi phục mật khẩu',
      subtitle: subtitle,
      children: [
        if (step == 0) ...[
          TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại')),
        ] else if (step == 1) ...[
          TextField(
              controller: pin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Mã PIN (6 số)')),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: sendPin, child: const Text('Gửi lại mã PIN')),
          ),
        ] else ...[
          TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới (≥ 8 ký tự, có chữ và số)')),
          const SizedBox(height: 12),
          TextField(
              controller: confirm,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Xác nhận mật khẩu mới')),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error!, style: const TextStyle(color: AppColors.accent)),
          ),
        const SizedBox(height: 16),
        BusyButton(
          label: switch (step) {
            0 => 'GỬI MÃ PIN',
            1 => 'XÁC NHẬN PIN',
            _ => 'ĐẶT LẠI MẬT KHẨU',
          },
          onPressed: switch (step) {
            0 => sendPin,
            1 => verifyPin,
            _ => resetPassword,
          },
        ),
      ],
    );
  }
}
