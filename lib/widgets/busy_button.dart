import 'package:flutter/material.dart';

/// Submit button that disables itself while [onPressed] runs, so a double
/// tap cannot send the same request twice.
class BusyButton extends StatefulWidget {
  final String label;
  final Future<void> Function()? onPressed;
  final bool outlined;

  const BusyButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.outlined = false});

  @override
  State<BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<BusyButton> {
  bool busy = false;

  Future<void> run() async {
    setState(() => busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = busy || widget.onPressed == null ? null : run;
    final child = busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2))
        : Text(widget.label);
    return widget.outlined
        ? OutlinedButton(onPressed: onPressed, child: child)
        : FilledButton(onPressed: onPressed, child: child);
  }
}
