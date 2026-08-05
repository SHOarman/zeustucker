import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';

import '../../customwidget/custom_bottom_nav.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(), permanent: true);

    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(selectIndex: 1),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              Text(
                "Completed Chapters",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D292E),
                ),
              ),
              const Text(
                "Revisit your fitness journey achievements.",
                style: TextStyle(
                  color: Color(0xff71717A),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

              Obx(() {
                if (homeController.isStoryLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF00A37B)),
                      ),
                    ),
                  );
                }
                if (homeController.clientPages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        "No storybook chapters generated yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  );
                }

                return _buildChapterSection(
                  chapter: "Chapter 1",
                  routine: "MORNING ROUTINE",
                  status: "COMPLETED",
                  statusColor: const Color(0xFF166534),
                  statusBg: const Color(0xFFDCFCE7),
                  chapterData: homeController.clientPages.map((page) {
                    final int pageNum = page['page_number'] ?? 1;
                    final String rawImg = page['image_url'] ?? '';
                    final String normalizedUrl = homeController.normalizeImageUrl(rawImg);
                    final String storyText = page['story'] ?? '';

                    return {
                      "image": normalizedUrl,
                      "name": "Page $pageNum",
                      "onTap": () {
                        Get.toNamed(
                          AppRoutes.librarydetails,
                          arguments: {
                            "storybook_id": page['storybook_id'],
                            "page_number": pageNum,
                            "story": storyText,
                            "title": page['title'],
                            "image_url": normalizedUrl,
                          },
                        );
                      },
                      "isNetwork": true,
                      "authToken": homeController.authToken,
                    };
                  }).toList(),
                );
              }),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/image/Container.png",
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "EndOf History",
                    style: TextStyle(
                      color: Color(0xffA1A1AA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterSection({
    required String chapter,
    required String routine,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required List<Map<String, dynamic>> chapterData,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter,
                style: const TextStyle(
                  color: Color(0xff18181B),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    routine,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: chapterData.length,
            itemBuilder: (context, index) {
              final data = chapterData[index];
              return _ImageCard(
                imagePath: data['image']!,
                imageName: data['name']!,
                onTap: data['onTap'],
                isNetwork: data['isNetwork'] ?? false,
                authToken: data['authToken'] ?? "",
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final String imageName;
  final VoidCallback onTap;
  final bool isNetwork;
  final String authToken;

  const _ImageCard({
    required this.imagePath,
    required this.imageName,
    required this.onTap,
    this.isNetwork = false,
    this.authToken = "",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: isNetwork
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      headers: authToken.isNotEmpty
                          ? {'Authorization': 'Bearer $authToken'}
                          : null,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                imageName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
