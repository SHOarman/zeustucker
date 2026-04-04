import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Viewstory extends StatelessWidget {
  const Viewstory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSubHeader(),
                    const SizedBox(height: 16),
                    _buildStoryPanel(
                      imageUrl: 'assets/image/Morning Gym Routine.png',
                      time: '06:30 AM',
                      description:
                          'Sarah starts her day with a high-intensity session at the local gym, focusing on strength training to build her foundation.',
                      showBadge: true,
                    ),
                    const SizedBox(height: 20),
                    _buildStoryPanel(
                      imageUrl: 'assets/image/Morning Gym Routine.png',
                      time: '08:15 AM',
                      description:
                          'Refueling is key. She prepares a balanced protein bowl with fresh greens and quinoa to sustain her energy levels for the work day ahead.',
                    ),
                    const SizedBox(height: 20),
                    _buildStoryPanel(
                      imageUrl: 'assets/image/Work Focus.png',
                      time: '10:30 AM',
                      description: 'Sarah stays hydrated and focused.',
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                'Sarah Jenkins',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'CHAPTER 4 - PEAK PERFORMANCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00BFA5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Icon(Icons.more_horiz, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'TUESDAY, MAY 14TH',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        // Row(
        //   children: [
        //     Icon(Icons.widgets, color: Colors.blue.shade400, size: 18),
        //     const SizedBox(width: 10),
        //     Icon(Icons.add_box, color: Colors.blue.shade400, size: 18),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildStoryPanel({
    required String imageUrl,
    required String time,
    required String description,
    bool showBadge = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                child: Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    // decoration: const BoxDecoration(
                    //   color: Colors.blue,
                    //   borderRadius: BorderRadius.only(
                    //     bottomLeft: Radius.circular(10),
                    //     topRight: Radius.circular(14),
                    //   ),
                    // ),
                    // child: const Text(
                    //   '6 × 6',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ),
                ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildIconButton(Icons.refresh),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.edit),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$time — ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.black87),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // --- Approve & Publish Button ---
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar('Published', 'Story approved and published!');
              },
              // Ekhane default Icon-er poriborte Image.asset use kora holo
              icon: Image.asset(
                'assets/image/Icon (4).png', // Tomar image path
                width: 20,
                height: 20,
                color: Colors.white, // Image-ta jodi single color hoy tobe white kora jabe
              ),
              label: const Text(
                'Approve & Publish',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Request Changes Button ---
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar('Request Changes', 'Feedback form opened.');
              },
              // Ekhane-o Image.asset use kora holo
              icon: Image.asset(
                'assets/image/Icon (3).png', // Tomar image path
                width: 20,
                height: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Request Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }}
