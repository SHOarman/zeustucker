import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/api_services/api_services.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/clientcontoller.dart';

class Viewstory extends StatelessWidget {
  const Viewstory({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? client = args?['client'];
    final Map<String, dynamic>? storybook = args?['storybook'];
    final List<dynamic> pages = storybook?['pages'] ?? [];

    final clientName = client?['name'] ?? 'Client';
    final storyDate = storybook?['date'] ?? 'Current Week';

    String authToken = "";
    if (Get.isRegistered<HomeController>()) {
      authToken = Get.find<HomeController>().authToken;
    } else if (Get.isRegistered<ClientController>()) {
      authToken = Get.find<ClientController>().authToken;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(clientName, storyDate),
            Expanded(
              child: pages.isEmpty
                  ? const Center(
                      child: Text(
                        "No story pages generated yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildSubHeader(storyDate),
                          const SizedBox(height: 16),
                          ...pages.map((page) {
                            final String storyText = page['story'] ?? '';
                            final String rawImageUrl = page['image_url'] ?? '';
                            final String imageUrl = ApiServices.normalizeImageUrl(rawImageUrl);
                            
                            // Split the storyText to extract time if present (e.g. "06:30 AM — ...")
                            String time = "";
                            String description = storyText;
                            if (storyText.contains(' — ')) {
                                final parts = storyText.split(' — ');
                                time = parts[0];
                                description = parts.sublist(1).join(' — ');
                            } else if (storyText.contains(' - ')) {
                                final parts = storyText.split(' - ');
                                time = parts[0];
                                description = parts.sublist(1).join(' - ');
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: _buildStoryPanel(
                                imageUrl: imageUrl,
                                time: time,
                                description: description,
                                fullStory: storyText,
                                authToken: authToken,
                              ),
                            );
                          }).toList(),
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

  Widget _buildHeader(String clientName, String dateStr) {
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
              Text(
                clientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DATE: $dateStr',
                style: const TextStyle(
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

  Widget _buildSubHeader(String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dateStr.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryPanel({
    required String imageUrl,
    required String time,
    required String description,
    required String fullStory,
    required String authToken,
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
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.cover,
                        headers: authToken.isNotEmpty
                            ? {'Authorization': 'Bearer $authToken'}
                            : null,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 300,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Image.asset(
                        imageUrl.isEmpty ? 'assets/image/Morning Gym Routine.png' : imageUrl,
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
