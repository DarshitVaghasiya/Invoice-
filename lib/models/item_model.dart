import 'package:flutter/material.dart';

class ItemModel {
  TextEditingController desc;
  TextEditingController qty;
  TextEditingController rate;
  Map<String, TextEditingController> customControllers = {};

  ItemModel({
    required String desc,
    required String qty,
    required String rate,
    required List<String> customFields,
  }) : desc = TextEditingController(text: desc),
       qty = TextEditingController(text: qty),
       rate = TextEditingController(text: rate) {
    // CREATE CONTROLLERS FOR CUSTOM FIELDS
    for (var f in customFields) {
      customControllers[f] = TextEditingController();
    }
  }

  // ---------------------------
  //      FROM JSON FIX
  // ---------------------------
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> customData = Map<String, dynamic>.from(
      json['customData'] ?? {},
    );

    final model = ItemModel(
      desc: json['desc'] ?? '',
      qty: json['qty'] ?? '',
      rate: json['rate'] ?? '',
      customFields: customData.keys.map((e) => e.toString()).toList(),
    );

    // ✅ SET VALUES
    customData.forEach((key, value) {
      model.customControllers[key]?.text = value?.toString() ?? '';
    });

    return model;
  }

  // ---------------------------
  //      TO JSON FIX
  // ---------------------------
  Map<String, dynamic> toJson() {
    return {
      "desc": desc.text,
      "qty": qty.text,
      "rate": rate.text,
      "customData": {
        for (var entry in customControllers.entries)
          entry.key: entry.value.text,
      },
    };
  }
}
