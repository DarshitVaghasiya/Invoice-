class BankAccountModel {
  final String? id;
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String upi;
  bool isPrimary;

  BankAccountModel({
    this.id,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.upi,
    this.isPrimary = false,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'],
      bankName: json['bankName'] ?? '',
      accountHolder: json['accountHolder'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifsc: json['ifsc'] ?? '',
      upi: json['upi'] ?? '',
      isPrimary: json["isPrimary"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'upi': upi,
      "isPrimary": isPrimary,
    };
  }

  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? ifsc,
    String? upi,
    bool? isPrimary,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      ifsc: ifsc ?? this.ifsc,
      upi: upi ?? this.upi,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  String toString() {
    return '''
BankAccountModel(
  id: $id,
  bankName: $bankName,
  accountHolder: $accountHolder,
  accountNumber: $accountNumber,
  ifsc: $ifsc,
  upi: $upi,
  isPrimary: $isPrimary
)''';
  }
}
