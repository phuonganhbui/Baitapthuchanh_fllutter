import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'product_category.dart';

class ApiService {
  static String get baseUrl {
    const port = String.fromEnvironment('API_PORT', defaultValue: '8000');
    const hostOverride = String.fromEnvironment(
      'API_HOST',
      defaultValue: '192.168.1.2',
    ); // Cập nhật IP thực từ ảnh

    if (hostOverride.isNotEmpty) {
      return 'http://$hostOverride:$port/api';
    }
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    } else {
      return 'http://192.168.1.2:$port/api'; // Mặc định dùng IP từ ảnh, có thể thay đổi
    }
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 422 || response.statusCode == 302) {
      final errors = jsonDecode(response.body)['errors'];
      final errorMessage = errors.values
          .map((v) => v is List ? v.join(', ') : v.toString())
          .join('\n');
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to add product: ${response.statusCode}');
    }
  }

  Future<Product> updateProduct(Product product) async {
    if (product.id == null) throw Exception('Product ID is required');
    final response = await http.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 422 || response.statusCode == 302) {
      final errors = jsonDecode(response.body)['errors'];
      final errorMessage = errors.values
          .map((v) => v is List ? v.join(', ') : v.toString())
          .join('\n');
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  Future<List<ProductCategory>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => ProductCategory.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách thể loại');
    }
  }
}
