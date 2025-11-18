import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.isToggle = false,
    this.toggleValue = false,
    this.onToggleChanged,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // 🔹 Determine device type
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1000;

    // 🔹 Responsive values
    final double paddingH = screenWidth * 0.03; // 3% of width
    final double paddingV = screenHeight * 0.015; // 1.5% of height
    final double iconRadius = isMobile ? 20 : isTablet ? 24 : 28;
    final double iconSize = isMobile ? 20 : isTablet ? 24 : 28;
    final double titleFont = isMobile ? 15 : isTablet ? 16 : 18;
    final double subtitleFont = isMobile ? 12 : isTablet ? 13 : 14;
    final double spacing = isMobile ? 12 : isTablet ? 16 : 18;

    return InkWell(
      onTap: isToggle ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Icon with background
            CircleAvatar(
              radius: iconRadius,
              backgroundColor: const Color(0xFF009A75).withOpacity(0.1),
              child: Icon(
                icon,
                color: const Color(0xFF009A75),
                size: iconSize,
              ),
            ),
            SizedBox(width: spacing),

            // 🔹 Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // ✅ Prevents overflow
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: subtitleFont,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // 🔹 Trailing widget (toggle or arrow)
            if (isToggle)
              Switch.adaptive(
                value: toggleValue,
                onChanged: onToggleChanged,
                activeColor: const Color(0xFF009A75),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else
              trailing ??
                  const Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
