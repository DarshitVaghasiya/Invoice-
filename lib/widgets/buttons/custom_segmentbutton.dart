import 'package:flutter/material.dart';

enum Status { all, paid, unpaid }

class CustomSegmentedbutton extends StatelessWidget {
  final Status initialStatus;
  final ValueChanged<Status> onStatusChanged;

  const CustomSegmentedbutton({
    super.key,
    required this.initialStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Status>(
      style: ButtonStyle(
        // 🔹 Rounded look
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        // 🔹 Background colors
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color(0xFF009A75); // selected background
          }
          return Colors.grey.shade200; // default background
        }),
        // 🔹 Foreground colors
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // selected text/icon
          }
          return Colors.grey.shade900; //default text/icon
        }),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      segments: const [
        ButtonSegment(
          value: Status.all,
          label: Text("All"),
          icon: Icon(Icons.list_alt),
        ),
        ButtonSegment(
          value: Status.paid,
          label: Text("Paid"),
          icon: Icon(Icons.check_circle_outline),
        ),
        ButtonSegment(
          value: Status.unpaid,
          label: Text("Unpaid"),
          icon: Icon(Icons.cancel_outlined),
        ),
      ],
      selected: {initialStatus},
      onSelectionChanged: (newSelection) {
        onStatusChanged(newSelection.first);
      },
    );
  }
}
