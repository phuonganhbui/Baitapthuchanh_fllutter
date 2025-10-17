import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BalanceGameScreen extends StatefulWidget {
  const BalanceGameScreen({super.key});

  @override
  State<BalanceGameScreen> createState() => _BalanceGameScreenState();
}

class _BalanceGameScreenState extends State<BalanceGameScreen> {
  double ballX = 150, ballY = 300;
  double targetX = 200, targetY = 500;
  double screenWidth = 0, screenHeight = 0;

  StreamSubscription? accelSub;

  @override
  void initState() {
    super.initState();
    accelSub = accelerometerEvents.listen((event) {
      setState(() {
        ballX -= event.x * 2;
        ballY += event.y * 2;

        ballX = ballX.clamp(0, screenWidth - 50);
        ballY = ballY.clamp(0, screenHeight - 50);

        _checkWin();
      });
    });
  }

  void _checkWin() {
    double dx = (ballX - targetX).abs();
    double dy = (ballY - targetY).abs();
    double distance = sqrt(dx * dx + dy * dy);
    if (distance < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Bạn đã thắng!")),
      );
      setState(() {
        targetX = Random().nextDouble() * (screenWidth - 50);
        targetY = Random().nextDouble() * (screenHeight - 50);
      });
    }
  }

  @override
  void dispose() {
    accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Game Lăn Bi")),
      body: Stack(
        children: [
          Positioned(
            left: targetX,
            top: targetY,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 4),
              ),
            ),
          ),
          Positioned(
            left: ballX,
            top: ballY,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
