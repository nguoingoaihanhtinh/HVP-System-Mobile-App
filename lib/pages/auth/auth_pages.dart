import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  void login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(
          () => error = 'MSG5 · Vui lòng nhập email/username và mật khẩu.');
      return;
    }
    final email = emailController.text.trim();
    if (email != 'minh' &&
        email != 'student@hvp.demo' &&
        email != 'admin@hvp.demo' &&
        email != 'coach@hvp.demo') {
      setState(
          () => error = 'MSG6 · Đăng nhập thất bại. Sai email hoặc mật khẩu.');
      return;
    }
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập để tiếp tục hành trình của bạn',
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email hoặc username'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
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
        FilledButton(onPressed: login, child: const Text('ĐĂNG NHẬP')),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SignupScreen())),
          child: const Text('Chưa có tài khoản? Đăng ký'),
        ),
      ],
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Chọn giao diện demo',
      subtitle: 'Role Selection chỉ phục vụ prototype UI.',
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
          label: const Text('STAFF / COACH'),
        ),
        const SizedBox(height: 20),
        const Text('student@hvp.demo  ·  admin@hvp.demo  ·  coach@hvp.demo',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.faint, fontSize: 12)),
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

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const fields = [
      'Họ và tên',
      'Email',
      'Số điện thoại',
      'Địa chỉ',
      'Mật khẩu',
      'Xác nhận mật khẩu'
    ];
    return AuthLayout(
      title: 'Tạo tài khoản',
      subtitle: 'Bắt đầu xây dựng phiên bản mạnh mẽ hơn',
      children: [
        for (final field in fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(decoration: InputDecoration(labelText: field)),
          ),
        FilledButton(
          onPressed: () =>
              showMessage(context, 'MSG3 · Tài khoản đã được tạo thành công!'),
          child: const Text('ĐĂNG KÝ'),
        ),
      ],
    );
  }
}

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Khôi phục mật khẩu',
      subtitle: 'Nhập số điện thoại để nhận mã PIN',
      children: [
        const TextField(
            decoration: InputDecoration(labelText: 'Số điện thoại')),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => showMessage(
              context, 'MSG10 · Mã PIN đã được gửi tới điện thoại.'),
          child: const Text('GỬI MÃ PIN'),
        ),
      ],
    );
  }
}
