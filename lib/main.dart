import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/home_screen.dart';
import 'utils/ble_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SensioRingApp());
}

class SensioRingApp extends StatelessWidget {
  const SensioRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENSIO Ring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
