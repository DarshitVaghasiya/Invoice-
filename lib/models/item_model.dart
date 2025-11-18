import 'package:flutter/material.dart';

class ItemModel {
  TextEditingController desc;
  TextEditingController qty;
  TextEditingController rate;

  ItemModel({
    String? desc,
    String? qty,
    String? rate,
  })  : desc = TextEditingController(text: desc ?? ''),
        qty = TextEditingController(text: qty ?? ''),
        rate = TextEditingController(text: rate ?? '');

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      desc: json['desc'] ?? '',
      qty: json['qty'] ?? '',
      rate: json['rate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "desc": desc.text,
    "qty": qty.text,
    "rate": rate.text,
    "amount": (int.tryParse(qty.text) ?? 0) *
        (double.tryParse(rate.text) ?? 0),
  };
}
