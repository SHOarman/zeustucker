import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/api_services/api_services.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/clientcontoller.dart';

class ViewStoryController extends GetxController {
  final pages = <dynamic>[].obs;
}

class Viewstory extends StatelessWidget {
  const Viewstory({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? client = args?['client'];
    final Map<String, dynamic>? storybook = args?['storybook'];
    final String storybookId = storybook?['id']?.toString() ?? storybook?['storybook_id']?.toString() ?? '';

    final controller = Get.put(ViewStoryController(), tag: storybookId);

    if (controller.pages.isEmpty) {
      controller.pages.assignAll(List<dynamic>.from((storybook?['pages'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? []));
    }

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
              child: Obx(() => controller.pages.isEmpty
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
                          ...List.generate(controller.pages.length, (index) {
                            final page = controller.pages[index];
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
                                onReplace: () => _editStory(controller, index, storybookId, authToken),
                              ),
                            );
                          }),
                          const SizedBox(height: 30),
                        ],
                      ),
                    )),
            ),
            const SizedBox(height: 10),
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
    required VoidCallback onReplace,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          headers: authToken.isNotEmpty
                              ? {'Authorization': 'Bearer $authToken'}
                              : null,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, size: 48, color: Color(0xFF9CA3AF)),
                                SizedBox(height: 8),
                                Text("Story Image", style: TextStyle(color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                        )
                      : Image.asset(
                          imageUrl.isEmpty ? 'assets/image/Morning Gym Routine.png' : imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(Icons.image, size: 48, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                ),
              ),
              // Icons removed per user request
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (time.isNotEmpty) ...[
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  description.isNotEmpty ? description : fullStory,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onReplace,
                    icon: const Icon(Icons.find_replace, size: 20),
                    label: const Text(
                      'Replace',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BFA5),
                      side: const BorderSide(color: Color(0xFF00BFA5), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editStory(ViewStoryController controller, int index, String storybookId, String authToken) async {
    final page = controller.pages[index];
    final String currentStory = page['story'] ?? '';
    final int pageNumber = page['page_number'] ?? (index + 1);

    debugPrint("=== Replace Clicked ===");
    debugPrint("Storybook ID: $storybookId");
    debugPrint("Page Number: $pageNumber");
    debugPrint("=======================");

    final TextEditingController textController = TextEditingController(text: currentStory);
    bool isLoading = false;

    await Get.defaultDialog(
      title: "Edit Story",
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return Column(
            children: [
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: "Enter story text...",
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF00BFA5)),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    setStateDialog(() { isLoading = true; });
                    final newStory = textController.text.trim();
                    try {
                      final url = Uri.parse(ApiServices.editStorybookPage(storybookId, pageNumber));
                      final response = await http.put(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'accept': 'application/json',
                          'Authorization': 'Bearer $authToken',
                        },
                        body: jsonEncode({
                          "story": newStory
                        }),
                      );

                      if (response.statusCode == 200) {
                        final Map<String, dynamic> responseData = jsonDecode(response.body);
                        controller.pages[index] = responseData;
                        controller.pages.refresh();
                        Get.back(); // close dialog
                        Get.snackbar(
                          "Success",
                          "Story updated successfully",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF00BFA5),
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          "Error (${response.statusCode})",
                          "Failed to update: ${response.body}",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        "An error occurred",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                    setStateDialog(() { isLoading = false; });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
            ],
          );
        },
      ),
    );
  }
}
