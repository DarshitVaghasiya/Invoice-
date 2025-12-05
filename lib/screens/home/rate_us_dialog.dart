import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

Future<void> showRateUsDialog(
  BuildContext context,
  Function(double rating) onSubmit,
) async {
  double selectedRating = 0;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    // 🔥 REQUIRED
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEEF4FF), Color(0xFFFDFEFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        offset: const Offset(0, 6),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Rate Your Experience",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 21,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 14),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          selectedRating == 0
                              ? "🙂"
                              : (selectedRating <= 2
                                    ? "😕"
                                    : selectedRating == 3
                                    ? "😊"
                                    : "🤩"),
                          key: ValueKey(selectedRating),
                          style: const TextStyle(fontSize: 46),
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text(
                        "Your feedback helps us improve!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      SmoothStarRating(
                        allowHalfRating: false,
                        starCount: 5,
                        rating: selectedRating,
                        size: 42,
                        filledIconData: Icons.star_rounded,
                        color: Colors.amber,
                        borderColor: Colors.grey.shade400,
                        spacing: 6,
                        onRatingChanged: (value) {
                          setState(() => selectedRating = value);
                        },
                      ),

                      const SizedBox(height: 26),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                        ),
                        child: CustomIconButton(
                          label: "Submit Rating",
                          textColor: Colors.white,
                          onTap: () {
                            onSubmit(selectedRating);
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      CustomIconButton(
                        label: "Maybe Later",
                        textColor: Colors.black54,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
