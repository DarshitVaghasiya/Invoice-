import 'item_model.dart';

class QuotationModel {
  String? quotationID;
  String? customerId;
  String from;
  String billTo;
  String? shipTo;
  String date;
  String descLabel;
  String qtyLabel;
  String rateLabel;
  Map<String, String> customLabels;
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
  String? currencyCode;
  String? currencySymbol;
  String? currencyName;

  QuotationModel({
    this.quotationID,
    this.customerId,
    required this.from,
    required this.billTo,
    this.shipTo,
    required this.date,
    required this.descLabel,
    required this.qtyLabel,
    required this.rateLabel,
    required this.customLabels,
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
    this.currencyCode,
    this.currencySymbol,
    this.currencyName,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      quotationID:
          json['quotationID'] ?? "INV_${DateTime.now().millisecondsSinceEpoch}",
      customerId: json['customerId'].toString(),
      from: json['from'],
      billTo: json['billTo'],
      shipTo: json['shipTo'],
      date: json['date'],
      descLabel: json['descLabel'] ?? "Product",
      qtyLabel: json['qtyLabel'] ?? "Qty",
      rateLabel: json['rateLabel'] ?? "Price",
      customLabels: Map<String, String>.from(json["customLabels"] ?? {}),
      items: List<ItemModel>.from(
        json['items'].map((x) => ItemModel.fromJson(x)),
      ),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: json['discount'] ?? "0",
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? "percent",
      tax: json['tax'] ?? "0",
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxType: json['taxType'] ?? "percent",
      shipping: json['shipping'] ?? "0",
      total: (json['total'] ?? 0).toDouble(),
      currencyCode: json['currencyCode'],
      currencySymbol: json['currencySymbol'],
      currencyName: json['currencyName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'quotationID': quotationID,
    'customerId': customerId,
    "from": from,
    "billTo": billTo,
    "shipTo": shipTo,
    "date": date,
    "descLabel": descLabel,
    "qtyLabel": qtyLabel,
    "rateLabel": rateLabel,
    "customLabels": customLabels,
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
    'currencyCode': currencyCode,
    'currencySymbol': currencySymbol,
    'currencyName': currencyName,
  };

  /// ✅ Add this method
  QuotationModel copyWith({
    String? quotationID,
    String? customerId,
    String? from,
    String? billTo,
    String? shipTo,
    String? date,
    String? descLabel,
    String? qtyLabel,
    String? rateLabel,
    List<ItemModel>? items,
    double? subtotal,
    String? discount,
    double? discountAmount,
    String? discountType,
    Map<String, String>? customLabels,
    String? tax,
    double? taxAmount,
    String? taxType,
    String? shipping,
    double? total,
    String? currencyCode,
    String? currencySymbol,
    String? currencyName,
  }) {
    return QuotationModel(
      quotationID: quotationID ?? this.quotationID,
      customerId: customerId ?? this.customerId,
      from: from ?? this.from,
      billTo: billTo ?? this.billTo,
      shipTo: shipTo ?? this.shipTo,
      date: date ?? this.date,
      descLabel: descLabel ?? this.descLabel,
      qtyLabel: qtyLabel ?? this.qtyLabel,
      rateLabel: rateLabel ?? this.rateLabel,
      customLabels: customLabels ?? this.customLabels,
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
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
    );
  }
}
