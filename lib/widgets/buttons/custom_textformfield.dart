import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class textFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final String? suffixText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool readOnly;
  final bool? enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Color? cursorColor;

  const textFormField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixText,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.enabled,
    this.cursorColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double fontSize = width < 400
        ? 14
        : width < 800
        ? 16
        : 18;
    final EdgeInsets contentPadding = width < 400
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 16);

    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onTap: onTap,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        style: TextStyle(fontSize: fontSize),
        validator: validator,
        cursorColor: cursorColor ?? Colors.black,
        enabled: enabled,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization:
            (keyboardType == TextInputType.emailAddress ||
                keyboardType == TextInputType.number ||
                keyboardType == TextInputType.phone ||
                keyboardType == TextInputType.visiblePassword)
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey, fontSize: fontSize - 0.1),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: fontSize - 1, color: Colors.grey.shade400),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixText: prefixText,
          suffixText: suffixText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          fillColor: Colors.white,
          filled: true,
          contentPadding: contentPadding,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 1.2),
          ),
        ),
      ),
    );
  }
}
