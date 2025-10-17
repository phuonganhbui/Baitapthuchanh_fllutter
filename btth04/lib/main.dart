import 'package:flutter/material.dart';
import 'survey_station_page.dart';
import 'data_map_page.dart';
import 'balance_game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thực hành Flutter - Phần cứng',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      routes: {
        '/survey': (context) => const SurveyStationPage(),
        '/dataMap': (context) => const DataMapPage(),
        '/game': (context) => const BalanceGameScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TH Flutter - Làm việc với phần cứng')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(
              context,
              icon: Icons.wb_sunny,
              text: '🧭 Ứng dụng Bản đồ nhiệt Sân trường',
              route: '/survey',
            ),
            const SizedBox(height: 16),
            _menuButton(
              context,
              icon: Icons.videogame_asset,
              text: '🕹️ Game Lăn bi thăng bằng',
              route: '/game',
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context,
      {required IconData icon, required String text, required String route}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 32),
      label: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }
}
