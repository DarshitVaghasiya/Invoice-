import 'package:flutter/material.dart';

class TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final String currencySymbol;

  const TotalRow({
    super.key,
    required this.label,
    required this.value,
    this.currencySymbol = "₹",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          "$currencySymbol ${value.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
