import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback onTap;
  final IconData? suffixIcon;

  /// 🔹 New Props
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;
  final double? fontSize;
  final double? iconSize;

  const CustomIconButton({
    super.key,
    this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    required this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.decoration,
    this.fontSize,
    this.iconSize,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: decoration ??
              BoxDecoration(
                color: backgroundColor ?? color,
                borderRadius: borderRadius ?? BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderColor != null ? 1.5 : 0,
                ),
              ),
          child: FittedBox(
            fit: BoxFit.scaleDown, // prevents overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: iconSize,
                    color: textColor,
                  ),
                if (label != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: fontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    Icon(
                      suffixIcon,
                      color: textColor ?? Colors.white,
                      size: iconSize ?? 22, // 🔹 Custom icon size
                    ),
                    if (label != null) const SizedBox(width: 5),
                  ],
                ],
              ],
            ),
          )

        ),
      ),
    );
  }
}
