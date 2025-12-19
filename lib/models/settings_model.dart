class SettingsModel {
  bool showTax;
  bool showPurchaseNo;
  bool showBank;
  bool showNotes;
  bool showTerms;
  String selectedTemplate;
  String descTitle;
  String qtyTitle;
  String rateTitle;
  String? signatureBase64;
  List<Map<String, dynamic>> customFields;

  SettingsModel({
    this.customFields = const [],
    this.showTax = false,
    this.showPurchaseNo = false,
    this.showBank = true,
    this.showNotes = false,
    this.showTerms = false,
    this.selectedTemplate = "Simple",
    this.descTitle = "Product",
    this.qtyTitle = "Qty",
    this.rateTitle = "Price",
    this.signatureBase64,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      customFields: List<Map<String, dynamic>>.from(
        (json['customFields'] ?? []).map(
              (e) => Map<String, dynamic>.from(e),
        ),
      ),
      showTax: json["showTax"] ?? false,
      showPurchaseNo: json["showPurchaseNo"] ?? false,
      showBank: json["showBank"] ?? true,
      showNotes: json["showNotes"] ?? false,
      showTerms: json["showTerms"] ?? false,
      selectedTemplate: json["selectedTemplate"] ?? "Simple",
      descTitle: json["descTitle"] ?? "Product",
      qtyTitle: json["qtyTitle"] ?? "Qty",
      rateTitle: json["rateTitle"] ?? "Price",
      signatureBase64: json["signatureBase64"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customFields": customFields,
      "showTax": showTax,
      "showPurchaseNo": showPurchaseNo,
      "showBank": showBank,
      "showNotes": showNotes,
      "showTerms": showTerms,
      "selectedTemplate": selectedTemplate,
      "descTitle": descTitle,
      "qtyTitle": qtyTitle,
      "rateTitle": rateTitle,
      "signatureBase64": signatureBase64,
    };
  }

  SettingsModel copyWith({
    List<Map<String, dynamic>>? customFields,
    bool? showTax,
    bool? showPurchaseNo,
    bool? showBank,
    bool? showNotes,
    bool? showTerms,
    String? selectedTemplate,
    String? descTitle,
    String? qtyTitle,
    String? rateTitle,
    String? signatureBase64,
  }) {
    return SettingsModel(
      customFields: customFields ?? this.customFields,
      showTax: showTax ?? this.showTax,
      showPurchaseNo: showPurchaseNo ?? this.showPurchaseNo,
      showBank: showBank ?? this.showBank,
      showNotes: showNotes ?? this.showNotes,
      showTerms: showTerms ?? this.showTerms,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      descTitle: descTitle ?? this.descTitle,
      qtyTitle: qtyTitle ?? this.qtyTitle,
      rateTitle: rateTitle ?? this.rateTitle,
      signatureBase64: signatureBase64 ?? this.signatureBase64,
    );
  }
}
