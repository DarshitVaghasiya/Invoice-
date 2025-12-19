import 'package:flutter/material.dart';

class AppDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String labelText;
  final bool enabled;

  const AppDropdownFormField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    this.enabled = true,
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

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      dropdownColor: Colors.white,
      onChanged: enabled ? onChanged : null,
      isDense: true,
      style: TextStyle(fontSize: fontSize, color: Colors.black),
      icon: const Icon(Icons.arrow_drop_down),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey, fontSize: fontSize - 0.1),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
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
    );
  }
}
