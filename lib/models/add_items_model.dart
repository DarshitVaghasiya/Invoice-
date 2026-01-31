class AddItemModel {
  final String id;
  final String title;
  final String details;
  final double price;

  AddItemModel({
    required this.id,
    required this.title,
    required this.details,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'details': details,
    'price': price,
  };

  factory AddItemModel.fromJson(Map<String, dynamic> json) => AddItemModel(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    details: json['details'] ?? '',
    price: (json['price'] as num).toDouble(),
  );
}
