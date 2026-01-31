import 'package:invoice/models/bank_account_model.dart';

class ProfileModel {
  final String? userID;
  String? originalImageBase64;
  String? profileImageBase64;
  final String name;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  final String pan;
  final String gst;
  String currencyCode;
  String currencySymbol;
  String currencyName;
  List<BankAccountModel>? bankAccounts;
  bool skipUsed;

  ProfileModel({
    this.userID,
    this.originalImageBase64,
    this.profileImageBase64,
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.pan,
    required this.gst,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyName,
    required this.bankAccounts,
    this.skipUsed = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userID: json['userID'],
      originalImageBase64: json["originalImageBase64"],
      profileImageBase64: json["profileImageBase64"],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pan: json['pan'] ?? '',
      gst: json['gst'] ?? '',
      currencyCode: json['currencyCode'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
      currencyName: json['currencyName'] ?? '',
      bankAccounts:
          (json['bankAccounts'] as List<dynamic>?)
              ?.map((e) => BankAccountModel.fromJson(e))
              .toList() ??
          [],
      skipUsed: json['skipUsed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'originalImageBase64': originalImageBase64,
      'profileImageBase64': profileImageBase64 ?? '',
      'name': name,
      'email': email,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'pan': pan,
      'gst': gst,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'currencyName': currencyName,
      'bankAccounts': bankAccounts?.map((e) => e.toJson()).toList() ?? [],
      'skipUsed': skipUsed,
    };
  }

  ProfileModel copyWith({
    String? userID,
    String? originalImageBase64,
    String? profileImageBase64,
    String? name,
    String? email,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? country,
    String? pan,
    String? gst,
    String? currencyCode,
    String? currencySymbol,
    String? currencyName,
    List<BankAccountModel>? bankAccounts,
    bool? skipUsed,
  }) {
    return ProfileModel(
      userID: userID ?? this.userID,
      originalImageBase64: originalImageBase64 ?? this.originalImageBase64,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pan: pan ?? this.pan,
      gst: gst ?? this.gst,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      skipUsed: skipUsed ?? this.skipUsed,
    );
  }
}
