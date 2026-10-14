import 'package:expenzia/screens/splash_screen.dart';
import 'package:expenzia/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseManagement());
}

class ExpenseManagement extends StatelessWidget {
  const ExpenseManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenzia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Splashscreen(),
    );
  }
}