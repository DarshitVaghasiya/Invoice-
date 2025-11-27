class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String panCard;
  final String gst;
  final String street;
  final String city;
  final String state;
  final String country;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.panCard,
    required this.gst,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      company: json['company'] ?? '',
      panCard: json['panCard'] ?? '',
      gst: json['gst'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'company': company,
    'panCard': panCard,
    'gst': gst,
    'street': street,
    'city': city,
    'state': state,
    'country': country,
  };

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? panCard,
    String? gst,
    String? street,
    String? city,
    String? state,
    String? country,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      panCard: panCard ?? this.panCard,
      gst: gst ?? this.gst,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }

}

