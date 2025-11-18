import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget child;
  final Widget? trailing;


  const SectionWidget({
    super.key,
    this.icon,
    this.title,
    required this.child,
    this.trailing,

  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double iconSize = (screenWidth * 0.06).clamp(18, 28);
    final double fontSize = (screenWidth * 0.045).clamp(14, 20);
    final double spacing = (screenWidth * 0.02).clamp(6, 12);
    final double verticalPadding = (screenHeight * 0.015).clamp(8, 20);

    return Padding(
      padding: EdgeInsets.only(bottom: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: iconSize, color: const Color(0xFF009A75)),
              SizedBox(width: spacing),
              Expanded(
                child: Text(
                  title ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Divider(),
          SizedBox(height: spacing),
          child,
        ],
      ),
    );
  }
}
