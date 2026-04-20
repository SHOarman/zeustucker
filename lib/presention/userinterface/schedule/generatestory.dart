import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenerateStory extends StatefulWidget {
  const GenerateStory({super.key});

  @override
  State<GenerateStory> createState() => _GenerateStoryState();
}

class _GenerateStoryState extends State<GenerateStory> {
  bool _usePreviousReference = true;
  final double _progressValue = 0.35; // 35% Progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9), // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
            onPressed: () {
              Get.back();
            }
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Generate Weekly Story',
                style: TextStyle(
                  color: Color(0xff323232),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Creating New Pages From Recent Week',
                style: TextStyle(
                  color: Color(0xff757575),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Main Image with Border
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/image/image 6.png",
                  height: 232,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Creating Pages',
                style: TextStyle(
                  color: Color(0xff323232),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Custom Progress Bar with Moving Indicator
              LayoutBuilder(
                builder: (context, constraints) {
                  double totalWidth = constraints.maxWidth;
                  double currentProgressWidth = totalWidth * _progressValue;

                  return Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      // Gray Background Bar
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Green Progress Fill
                      Container(
                        height: 8,
                        width: currentProgressWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Indicator Image (Sparkle)
                      Positioned(
                        left: currentProgressWidth - 12, // Offset to center the image on the tip
                        top: -8, // Adjust based on your asset height
                        child: Image.asset(
                          "assets/image/Container (1).png",
                          height: 24, // Matches the design scale
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
              const Text(
                'For better face consistency, reuse previous image.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Toggle Switch Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Use Previous Image Reference',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    Switch(
                      value: _usePreviousReference,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF14B8A6),
                      inactiveTrackColor: Colors.grey[300],
                      onChanged: (value) {
                        setState(() {
                          _usePreviousReference = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}