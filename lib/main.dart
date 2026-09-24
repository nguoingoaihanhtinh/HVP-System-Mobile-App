import 'package:flutter/material.dart';

import 'pages/auth/auth_pages.dart';
import 'theme/app_theme.dart';

void main() => runApp(const HvpApp());

class HvpApp extends StatelessWidget {
  const HvpApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const SplashScreen(),
      );
}
