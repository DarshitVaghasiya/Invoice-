class BankAccountModel {
  final String? id;
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String upi;

  BankAccountModel({
    this.id,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.upi,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'],
      bankName: json['bankName'] ?? '',
      accountHolder: json['accountHolder'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifsc: json['ifsc'] ?? '',
      upi: json['upi'] ?? '',
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
    };
  }

  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? ifsc,
    String? upi,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      ifsc: ifsc ?? this.ifsc,
      upi: upi ?? this.upi,
    );
  }
}
