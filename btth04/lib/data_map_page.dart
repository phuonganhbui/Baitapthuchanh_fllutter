import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DataMapPage extends StatefulWidget {
  const DataMapPage({super.key});

  @override
  State<DataMapPage> createState() => _DataMapPageState();
}

class _DataMapPageState extends State<DataMapPage> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/schoolyard_map_data.json");

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);

        // Chuyển đổi sang dạng Map an toàn
        setState(() {
          records = jsonList.map<Map<String, dynamic>>((item) {
            return Map<String, dynamic>.from(item);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Lỗi đọc dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bản đồ Dữ liệu"),
        backgroundColor: Colors.blueAccent,
      ),
      body: records.isEmpty
          ? const Center(
        child: Text(
          "Chưa có dữ liệu khảo sát",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index];

          double? lat = _toDouble(r['latitude']);
          double? lng = _toDouble(r['longitude']);
          double? light = _toDouble(r['light']);
          double? accel = _toDouble(r['accel']);
          double? magnetic = _toDouble(r['magnetic']);
          String time = r['time']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 3,
            child: ListTile(
              title: Text(
                (lat != null && lng != null)
                    ? "(${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})"
                    : "Vị trí không xác định",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (light != null) _iconRow(Icons.wb_sunny, Colors.amber, light, "Ánh sáng"),
                  if (accel != null) _iconRow(Icons.directions_run, Colors.red, accel, "Gia tốc"),
                  if (magnetic != null) _iconRow(Icons.explore, Colors.blue, magnetic, "Từ trường"),
                  const SizedBox(height: 4),
                  Text("🕒 $time"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Hàm chuyển dữ liệu sang double an toàn
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Widget dòng có icon và giá trị
  Widget _iconRow(IconData icon, Color color, double value, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text("$label: ${value.toStringAsFixed(2)}"),
      ],
    );
  }
}
