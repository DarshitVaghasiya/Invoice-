import 'item_model.dart';

class InvoiceModel {
  final int? customerId;
  String invoiceNo;
  String? poNumber;
  String from;
  String billTo;
  String? shipTo;
  String date;
  String dueDate;
  String descLabel;
  String qtyLabel;
  String rateLabel;
  List<ItemModel> items;
  double subtotal;
  String discount;
  double discountAmount; // calculated amount (e.g. 100.0)
  String discountType; // "percent" or "amount"
  String tax;
  double taxAmount;
  String taxType; // "percent" or "amount"
  String shipping;
  double total;
  String? notes;
  String? terms;
  String status;

  String? currencyCode;
  String? currencySymbol;
  String? currencyName;

  InvoiceModel({
    this.customerId,
    required this.invoiceNo,
    this.poNumber,
    required this.from,
    required this.billTo,
    this.shipTo,
    required this.date,
    required this.dueDate,
    required this.descLabel,
    required this.qtyLabel,
    required this.rateLabel,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.discountAmount,
    required this.discountType,
    required this.tax,
    required this.taxAmount,
    required this.taxType,
    required this.shipping,
    required this.total,
    this.notes,
    this.terms,
    required this.status,

    this.currencyCode,
    this.currencySymbol,
    this.currencyName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      customerId: json['customerId'],
      invoiceNo: json['invoiceNo'],
      poNumber: json['poNumber'],
      from: json['from'],
      billTo: json['billTo'],
      shipTo: json['shipTo'],
      date: json['date'],
      dueDate: json['dueDate'],
      descLabel: json['descLabel'] ?? "Product",
      qtyLabel: json['qtyLabel'] ?? "Qty",
      rateLabel: json['rateLabel'] ?? "Price",
      items: (json['items'] as List? ?? [])
          .map((e) => e is ItemModel ? e : ItemModel.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: json['discount'] ?? "0",
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? "percent",
      tax: json['tax'] ?? "0",
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxType: json['taxType'] ?? "percent",
      shipping: json['shipping'] ?? "0",
      total: (json['total'] ?? 0).toDouble(),
      notes: json['notes'],
      terms: json['terms'],
      status: json['status'] ?? "unpaid",
      currencyCode: json['currencyCode'],
      currencySymbol: json['currencySymbol'],
      currencyName: json['currencyName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    "invoiceNo": invoiceNo,
    "poNumber": poNumber,
    "from": from,
    "billTo": billTo,
    "shipTo": shipTo,
    "date": date,
    "dueDate": dueDate,
    "descLabel": descLabel,
    "qtyLabel": qtyLabel,
    "rateLabel": rateLabel,
    "items": items.map((e) => e.toJson()).toList(),
    "subtotal": subtotal,
    "discount": discount,
    "discountAmount": discountAmount,
    "discountType": discountType,
    "tax": tax,
    'taxAmount': taxAmount,
    "taxType": taxType,
    "shipping": shipping,
    "total": total,
    "notes": notes,
    "terms": terms,
    "status": status,
    'currencyCode': currencyCode,
    'currencySymbol': currencySymbol,
    'currencyName': currencyName,
  };

  /// ✅ Add this method
  InvoiceModel copyWith({
    int? customerId,
    String? invoiceNo,
    String? poNumber,
    String? from,
    String? billTo,
    String? shipTo,
    String? date,
    String? dueDate,
    String? descLabel,
    String? qtyLabel,
    String? rateLabel,
    List<ItemModel>? items,
    double? subtotal,
    String? discount,
    double? discountAmount,
    String? discountType,
    String? tax,
    double? taxAmount,
    String? taxType,
    String? shipping,
    double? total,
    String? notes,
    String? terms,
    String? status,
    String? currencyCode,
    String? currencySymbol,
    String? currencyName,
  }) {
    return InvoiceModel(
      customerId: customerId ?? this.customerId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      poNumber: poNumber ?? this.poNumber,
      from: from ?? this.from,
      billTo: billTo ?? this.billTo,
      shipTo: shipTo ?? this.shipTo,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      descLabel: descLabel ?? this.descLabel,
      qtyLabel: qtyLabel ?? this.qtyLabel,
      rateLabel: rateLabel ?? this.rateLabel,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      tax: tax ?? this.tax,
      taxAmount: taxAmount ?? this.taxAmount,
      taxType: taxType ?? this.taxType,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      status: status ?? this.status,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
    );
  }
}
