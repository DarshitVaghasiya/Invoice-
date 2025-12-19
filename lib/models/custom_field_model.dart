import 'package:flutter/material.dart';

class CustomFieldModel {
  final TextEditingController controller;
  String operator;      // + - * /
  String valueKey;      // qty, rate, field_1...

  CustomFieldModel({
    required String label,
    this.operator = '+',
    this.valueKey = 'qty',
  }) : controller = TextEditingController(text: label);

  // JSON
  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldModel(
      label: json['label'] ?? '',
      operator: json['operator'] ?? '+',
      valueKey: json['valueKey'] ?? 'qty',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "label": controller.text,
      "operator": operator,
      "valueKey": valueKey,
    };
  }
}
