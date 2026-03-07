import 'package:flutter/material.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: const Center(
        child: Text(
          'Stats',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectIndex: 2),
    );
  }
}
