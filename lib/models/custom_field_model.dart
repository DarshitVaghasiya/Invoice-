import 'package:flutter/material.dart';

class CustomFieldModel {
  final TextEditingController controller;
  String valueKey; // qty, rate, field_1...

  CustomFieldModel({required String label, this.valueKey = 'qty'})
    : controller = TextEditingController(text: label);

  // JSON
  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldModel(
      label: json['label'] ?? '',
      valueKey: json['valueKey'] ?? 'qty',
    );
  }

  Map<String, dynamic> toJson() {
    return {"label": controller.text, "valueKey": valueKey};
  }
}
