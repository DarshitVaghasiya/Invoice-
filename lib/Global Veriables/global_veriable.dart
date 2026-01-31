library;

import 'package:flutter/material.dart';
import 'package:invoice/screens/menu/upgrade_plan/upgrade_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔹 Global variables
bool isPurchase = false;

// 🔹 Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void showLimitDialog(String message) {
  showGeneralDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, _, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(animation.value),
        child: Opacity(
          opacity: animation.value,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium Icon Circle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                      ),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  const Text(
                    "Premium Feature",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Upgrade Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF0072FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PlanPage()),
                        );

                        if (result == true) {
                          final prefs = await SharedPreferences.getInstance();
                          isPurchase = prefs.getBool("isPurchase") ?? false;
                        }
                      },

                      child: const Text(
                        "Upgrade Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Not Now Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Maybe Later",
                      style: TextStyle(
                        color: Color(0xFF0072FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
