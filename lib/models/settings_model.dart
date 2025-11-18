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


  SettingsModel({
    this.showTax = false,
    this.showPurchaseNo = false,
    this.showBank = false,
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
      showTax: json["showTax"] ?? false,
      showPurchaseNo: json["showPurchaseNo"] ?? false,
      showBank: json["showBank"] ?? false,
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

  /// ✅ Add this method
  SettingsModel copyWith({
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
