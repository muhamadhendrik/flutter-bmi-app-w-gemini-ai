import 'package:flutter/material.dart';
import 'package:flutter_w_gemini/screen/bmi_calculator_screen.dart';
import 'package:flutter_w_gemini/screen/chat_screen.dart';
import 'package:flutter_w_gemini/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const HomeScreen(),
        "/chat": (context) => const ChatScreen(),
        "/bmi": (context) =>const BMICalculatorScreen(),
      },
    );
  }
}
