import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback onPressed;

  /// Styling Props
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final double? iconSize;
  final bool fullWidth;

  /// Layout Props
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;

  const CustomElevatedButton({
    super.key,
    this.label,
    this.icon,
    this.suffixIcon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.iconSize,
    this.padding,
    this.margin,
    this.borderRadius,
    this.decoration,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: fullWidth ? double.infinity : null,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        splashColor: Colors.transparent,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: decoration ??
              BoxDecoration(
                color: backgroundColor ?? Colors.blue,
                borderRadius: borderRadius ?? BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderColor != null ? 1.5 : 0,
                ),
              ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, size: iconSize ?? 22, color: textColor ?? Colors.white),

                if (label != null && icon != null) const SizedBox(width: 6),

                if (label != null)
                  Flexible(
                    child: Text(
                      label!,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: fontSize ?? 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? Colors.white,
                      ),
                    ),
                  ),

                if (suffixIcon != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    suffixIcon,
                    size: iconSize ?? 22,
                    color: textColor ?? Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
