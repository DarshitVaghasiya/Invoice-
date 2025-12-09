import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showRateUsDialog(
    BuildContext context,
    Function(double rating) onSubmit,
    ) async {
  final BuildContext parentContext = context; // store root screen context
  double selectedRating = 0;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
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
                      const SizedBox(height: 6),

                      if (selectedRating > 0)
                        Text(
                          "You rated: ${selectedRating.toInt()} ★",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),

                      const SizedBox(height: 18),

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
                          onTap: () async {
                            onSubmit(selectedRating);
                            Navigator.pop(dialogContext); // close dialog

                            await Future.delayed(const Duration(milliseconds: 400));

                            if (selectedRating >= 4) {
                              // directly open Play Store review page
                              try {
                                await launchUrl(
                                  Uri.parse("market://details?id=com.easyinvoicegenerator"),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (_) {
                                await launchUrl(
                                  Uri.parse("https://play.google.com/store/apps/details?id=com.easyinvoicegenerator"),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Thanks for your feedback 🙏"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }

                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      CustomIconButton(
                        label: "Maybe Later",
                        textColor: Colors.black54,
                        onTap: () => Navigator.pop(dialogContext),
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
