

class ProfileModel {
  final String? userID;
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
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String upi;

  ProfileModel({
    this.userID,
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
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.upi,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userID:json['userID'],
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
      bankName: json['bankName'] ?? '',
      accountHolder: json['accountHolder'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifsc: json['ifsc'] ?? '',
      upi: json['upi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID':userID,
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
      'bankName': bankName,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'upi': upi,
    };
  }

  ProfileModel copyWith({
    String? userID,
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
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? ifsc,
    String? upi,
  }) {
    return ProfileModel(
      userID: userID ?? this.userID,
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
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      ifsc: ifsc ?? this.ifsc,
      upi: upi ?? this.upi,
    );
  }
}
