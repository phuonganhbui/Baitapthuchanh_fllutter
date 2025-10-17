import 'dart:convert';

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'product.dart';
import 'product_category.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng sản phẩm',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          primary: const Color(0xFF6200EE),
          secondary: const Color(0xFF03DAC6),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;
  final ApiService apiService = ApiService();
  List<ProductCategory> categories = [];

  @override
  void initState() {
    super.initState();
    _refreshProducts();
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final cats = await apiService.fetchCategories();
      setState(() {
        categories = cats;
      });
    } catch (e) {
      // Có thể xử lý lỗi tải category ở đây
    }
  }

  void _refreshProducts() {
    setState(() {
      futureProducts = apiService.fetchProducts();
    });
  }

  void _showProductDialog({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    ProductCategory? selectedCategory;
    if (product?.category != null && categories.isNotEmpty) {
      selectedCategory = categories.firstWhere(
        (cat) => cat.id == product!.category!.id,
        orElse: () => categories.first,
      );
    } else if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }

    Map<String, String> fieldErrors = {};
    bool isSaving = false;

    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    errorText: fieldErrors['name'],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    errorText: fieldErrors['description'],
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Giá',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixText: '₫ ',
                    errorText: fieldErrors['price'],
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductCategory>(
                  value: selectedCategory,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem<ProductCategory>(
                          value: cat,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (cat) => setState(() => selectedCategory = cat),
                  decoration: InputDecoration(
                    labelText: 'Thể loại',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: fieldErrors['category_id'],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    isSaving
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              fieldErrors.clear();
                              final name = nameController.text.trim();
                              final desc = descController.text.trim();
                              final priceText = priceController.text.trim();
                              final price = double.tryParse(priceText);
                              final category = selectedCategory;
                              bool hasError = false;
                              if (name.isEmpty) {
                                fieldErrors['name'] = 'Tên không được để trống';
                                hasError = true;
                              }
                              if (desc.isEmpty) {
                                fieldErrors['description'] =
                                    'Mô tả không được để trống';
                                hasError = true;
                              }
                              if (priceText.isEmpty) {
                                fieldErrors['price'] =
                                    'Giá không được để trống';
                                hasError = true;
                              } else if (price == null || price < 0) {
                                fieldErrors['price'] = 'Giá phải là số dương';
                                hasError = true;
                              }
                              if (category == null) {
                                fieldErrors['category_id'] =
                                    'Vui lòng chọn thể loại';
                                hasError = true;
                              }
                              if (hasError) {
                                setState(() {});
                                return;
                              }
                              setState(() => isSaving = true);
                              final data = {
                                'name': name,
                                'description': desc,
                                'price': price,
                                'category': category,
                              };
                              if (product != null) {
                                data['id'] = product.id;
                              }
                              try {
                                if (product == null) {
                                  await apiService.addProduct(
                                    Product(
                                      id: 0,
                                      name: data['name'] as String,
                                      description:
                                          data['description'] as String,
                                      price: data['price'] as double,
                                      category:
                                          data['category'] as ProductCategory,
                                    ),
                                  );
                                } else {
                                  await apiService.updateProduct(
                                    Product(
                                      id: data['id'] as int,
                                      name: data['name'] as String,
                                      description:
                                          data['description'] as String,
                                      price: data['price'] as double,
                                      category:
                                          data['category'] as ProductCategory,
                                    ),
                                  );
                                }
                                Navigator.pop(context, data);
                                _refreshProducts();
                              } catch (e) {
                                // Parse lỗi từ API
                                String errorMessage =
                                    'Đã xảy ra lỗi không xác định';
                                fieldErrors.clear();
                                if (e.toString().contains('422')) {
                                  try {
                                    final errorJson = e.toString();
                                    // Parse lỗi JSON
                                    final RegExp regExp = RegExp(
                                      r'\{.*\}',
                                      dotAll: true,
                                    );
                                    final match = regExp.firstMatch(errorJson);
                                    if (match != null) {
                                      final jsonStr = match.group(0);
                                      if (jsonStr != null) {
                                        final Map<String, dynamic> errMap =
                                            jsonDecode(jsonStr);
                                        if (errMap['errors'] != null) {
                                          final errors =
                                              errMap['errors']
                                                  as Map<String, dynamic>;
                                          errors.forEach((key, value) {
                                            if (value is List &&
                                                value.isNotEmpty) {
                                              fieldErrors[key] = value.first
                                                  .toString();
                                            }
                                          });
                                        }
                                        if (errMap['message'] != null) {
                                          errorMessage = errMap['message']
                                              .toString();
                                        }
                                      }
                                    }
                                  } catch (_) {}
                                } else {
                                  errorMessage = e.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  );
                                }
                                setState(
                                  () => isSaving = false,
                                ); // Cập nhật lỗi lên UI
                              }
                            },
                            child: Text(product == null ? 'Lưu' : 'Cập nhật'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await apiService.deleteProduct(product.id);
      _refreshProducts();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text(
              'Không thể xóa sản phẩm: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có sản phẩm nào'));
            }

            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category?.name ?? 'Không có danh mục',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₫${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          tooltip: 'Sửa',
                          onPressed: () => _showProductDialog(product: product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Xóa',
                          onPressed: () => _deleteProduct(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Thêm sản phẩm',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
