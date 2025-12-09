import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';

Future<bool?> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData? icon = Icons.warning_amber_rounded,
  Color iconColor = Colors.red,
  String btn3 = 'button 3',
  String btn2 = 'button 2',
  String btn1 = 'Cancel',
  Color btn3Color = Colors.red,
  Color btn2Color = const Color(0xFF009A75),
  Color btn1Color = Colors.red,

  bool singleButton = false,
  bool addButton = false,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Dialog",
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink(); // required but unused
    },
    transitionBuilder: (_, animation, __, ___) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return Center(
        child: ScaleTransition(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Title + Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon!, color: iconColor, size: 32),
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

                  const SizedBox(height: 24),

                  // 🔹 Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (addButton)
                        CustomIconButton(
                          label: btn1,
                          backgroundColor: Colors.transparent,
                          borderColor: btn1Color,
                          textColor: btn1Color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          onTap: () => Navigator.pop(context),
                        ),

                      if (addButton) const SizedBox(width: 10),

                      if (!singleButton)
                        CustomIconButton(
                          label: btn2,
                          backgroundColor: Colors.transparent,
                          borderColor: btn2Color,
                          textColor: btn2Color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          onTap: () => Navigator.pop(context, false),
                        ),

                      if (!singleButton) const SizedBox(width: 10),

                      CustomIconButton(
                        label: singleButton ? "OK" : btn3,
                        borderColor: btn3Color,
                        textColor: btn3Color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
