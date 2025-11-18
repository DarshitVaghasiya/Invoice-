class AddItemModel {
  final int id;
  final String title;
  final String details;
  final int price;

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
    'price':price,
  };

  factory AddItemModel.fromJson(Map<String, dynamic> json) => AddItemModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    details: json['details'] ?? '',
    price: json['price'] ?? ','
  );
}
