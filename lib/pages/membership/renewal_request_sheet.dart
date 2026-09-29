import 'package:flutter/material.dart';

import '../../app/repositories.dart';
import '../../core/idempotency.dart';
import '../../core/result.dart';
import '../../data/models/renewal_request.dart';
import '../../theme/app_theme.dart';
import '../../widgets/busy_button.dart';
import '../../widgets/shared_widgets.dart';

/// UC14 step 4: choose the desired package and how staff should contact you.
class RenewalRequestSheet extends StatefulWidget {
  final String memberId;
  final String? currentPackageTypeId;

  const RenewalRequestSheet(
      {super.key, required this.memberId, this.currentPackageTypeId});

  @override
  State<RenewalRequestSheet> createState() => _RenewalRequestSheetState();
}

class _RenewalRequestSheetState extends State<RenewalRequestSheet> {
  /// One id for this form; a retry after a timeout reuses it.
  final clientRequestId = newClientRequestId();
  final noteController = TextEditingController();
  String? packageId;
  ContactChannel? channel = ContactChannel.phone;
  String? error;

  @override
  void initState() {
    super.initState();
    packageId = widget.currentPackageTypeId;
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final result = await Repositories.membership.submitRenewalRequest(
      memberId: widget.memberId,
      desiredPackageTypeId: packageId,
      channel: channel,
      clientRequestId: clientRequestId,
      note: noteController.text,
    );
    if (!mounted) return;
    switch (result) {
      case Ok(:final message):
        Navigator.pop(context);
        if (message != null) showMessage(context, message.display);
      case Err(:final message):
        setState(() => error = message.display);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = Repositories.membership.packageTypes();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Yêu cầu gia hạn',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Lễ tân sẽ liên hệ để tư vấn và thu phí tại quầy.',
              style: TextStyle(color: AppColors.dim)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: packageId,
            decoration: const InputDecoration(labelText: 'Gói mong muốn'),
            items: [
              for (final package in packages)
                DropdownMenuItem(value: package.id, child: Text(package.name)),
            ],
            onChanged: (value) => setState(() => packageId = value),
          ),
          const SizedBox(height: 14),
          const Text('Kênh liên hệ', style: TextStyle(color: AppColors.dim)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            for (final option in ContactChannel.values)
              ChoiceChip(
                label: Text(option.label),
                selected: channel == option,
                onSelected: (selected) =>
                    setState(() => channel = selected ? option : null),
              ),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: const TextStyle(color: AppColors.accent)),
            ),
          const SizedBox(height: 18),
          BusyButton(label: 'GỬI YÊU CẦU', onPressed: submit),
        ],
      ),
    );
  }
}
