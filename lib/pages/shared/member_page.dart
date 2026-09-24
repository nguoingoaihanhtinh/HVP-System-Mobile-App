import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(20), children: [
        Panel(
            child: ListTile(
                leading: const CircleAvatar(child: Text('M')),
                title: const Text('Minh Nguyễn'),
                subtitle: Text(
                    'student@hvp.demo\nGói A · ACTIVE · ${appState.remainingSessions} buổi còn lại'),
                trailing: Text('${appState.dpBalance} DP',
                    style: const TextStyle(color: AppColors.teal)))),
        const Panel(
            child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Mock member record'),
                subtitle:
                    Text('Prototype chỉ dùng local state, không có backend.'))),
      ]),
    );
  }
}
