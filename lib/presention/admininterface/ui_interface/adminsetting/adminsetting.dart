import 'package:flutter/material.dart';
import '../../widget/customnevadminbutton.dart';

class Adminsetting extends StatelessWidget {
  const Adminsetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Setting', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Admin Setting Screen'),
      ),
      bottomNavigationBar: const Customnevadminbutton(selectIndex: 3),
    );
  }
}
