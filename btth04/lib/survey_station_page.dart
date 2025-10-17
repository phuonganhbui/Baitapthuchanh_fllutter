import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅ thêm thư viện icon
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SurveyStationPage extends StatefulWidget {
  const SurveyStationPage({super.key});

  @override
  State<SurveyStationPage> createState() => _SurveyStationPageState();
}

class _SurveyStationPageState extends State<SurveyStationPage> {
  double light = 0.0;
  double accelMag = 0.0;
  double magField = 0.0;

  Location location = Location();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initSensors();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
  }

  void _initSensors() {
    accelerometerEvents.listen((event) {
      setState(() {
        accelMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      });
    });

    magnetometerEvents.listen((event) {
      setState(() {
        magField = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      });
    });

    // Giả lập ánh sáng (nhiều thiết bị không có cảm biến ánh sáng)
    light = Random().nextDouble() * 1000;
  }

  Future<void> _saveData() async {
    var currentLocation = await location.getLocation();
    final dataPoint = {
      "time": DateTime.now().toIso8601String(),
      "latitude": currentLocation.latitude,
      "longitude": currentLocation.longitude,
      "light": light,
      "accel": accelMag,
      "magnetic": magField,
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/schoolyard_map_data.json");

    List<dynamic> existing = [];
    if (await file.exists()) {
      existing = jsonDecode(await file.readAsString());
    }

    existing.add(dataPoint);
    await file.writeAsString(jsonEncode(existing));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Đã ghi dữ liệu thành công!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trạm Khảo sát"),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pushNamed(context, '/dataMap'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSensorTile(Icons.wb_sunny, "Cường độ ánh sáng", "${light.toStringAsFixed(2)} lux"),
            _buildSensorTile(Icons.directions_run, "Độ năng động", "${accelMag.toStringAsFixed(2)} m/s²"),
            _buildSensorTile(FontAwesomeIcons.magnet, "Từ trường", "${magField.toStringAsFixed(2)} µT"), // ✅ Sửa icon
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saveData,
              icon: const Icon(Icons.save),
              label: const Text("Ghi dữ liệu tại điểm này"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTile(IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

