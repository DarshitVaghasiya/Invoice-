import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';

Future<bool?> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData icon = Icons.warning_amber_rounded,
  Color iconColor = Colors.red,
  String confirmText = "Delete",
  String cancelText = "Cancel",
  Color confirmColor = Colors.red,
  Color cancelColor = const Color(0xFF009A75),

  bool singleButton = false, // 🔥 NEW: show only OK button
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth = screenWidth > 600
          ? 400.0
          : (screenWidth * 0.85).toDouble();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Title with Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: iconColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 Message
                Text(
                  message,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 22),

                // 🔹 Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ❌ Hide Cancel Button if singleButton = true
                    if (!singleButton)
                      CustomIconButton(
                        label: cancelText,
                        backgroundColor: Colors.transparent,
                        borderColor: cancelColor,
                        textColor: cancelColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        onTap: () => Navigator.pop(context, false),
                      ),

                    if (!singleButton) const SizedBox(width: 10),

                    CustomIconButton(
                      label: singleButton ? "OK" : confirmText, // 🔥 auto changes
                      borderColor: confirmColor,
                      textColor: confirmColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
