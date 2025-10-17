import 'product_category.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final ProductCategory? category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      if (category != null) 'category_id': category!.id,
    };
  }
}
