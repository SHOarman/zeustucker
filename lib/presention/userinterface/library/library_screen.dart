import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';

import '../../customwidget/custom_bottom_nav.dart';


class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

              // --- HEADER SECTION ---
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

              const SizedBox(height: 30),

              // --- CHAPTER 3 ---
              _buildChapterSection(
                chapter: "Chapter 3",
                routine: "MORNING ROUTINE V2",
                status: "FINALISED",
                statusColor: const Color(0xFF166534),
                statusBg: const Color(0xFFDCFCE7),
                chapterData: [
                  {
                    "image": "assets/image/card1 (1).png",
                    "name": "The Awakening",
                    "onTap": (){
                      Get.toNamed(AppRoutes.librarydetails);
                    }
                  },
                  {
                    "image": "assets/image/card1 (2).png",
                    "name": "Flow State",
                    "onTap": (){
                      Get.toNamed(AppRoutes.librarydetails);
                    }
                  },
                ],
              ),

              const SizedBox(height: 45),

              // --- CHAPTER 2 ---
              _buildChapterSection(
                chapter: "Chapter 2",
                routine: "NIGHT OWL REFLECTION",
                status: "MASTERED",
                statusColor: const Color(0xFF166534),
                statusBg: const Color(0xFFDCFCE7),
                chapterData: [
                  {
                    "image": "assets/image/chapter22.png",
                    "name": "Golden Hour",
                    "onTap": (){
                      Get.toNamed(AppRoutes.librarydetails);
                    }
                  },
                  {
                    "image": "assets/image/chapter21.png",
                    "name": "High Mountain",
                    "onTap": (){
                      Get.toNamed(AppRoutes.librarydetails);
                    }
                  },
                ],
              ),


              const SizedBox(height: 40),
              // Footer Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset("assets/image/Container.png"), // Asset check korun
                  const SizedBox(width: 6),
                  const Text(
                    "EndOf History",
                    style: TextStyle(color: Color(0xffA1A1AA), fontSize: 12, fontWeight: FontWeight.w600),
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
    required List<Map<String, dynamic>> chapterData, // String theke dynamic kora holo function neuar jonno
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chapter, style: const TextStyle(color: Color(0xff18181B), fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(routine, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: chapterData.map((data) => _ImageCard(
              imagePath: data['image']!,
              imageName: data['name']!,
              onTap: data['onTap'],
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final String imageName;
  final VoidCallback onTap; // Callback define kora holo

  const _ImageCard({
    required this.imagePath,
    required this.imageName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Custom action trigger hoba
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 192,
        height: 256,
        child: Stack(
          children: [
            // Image Layer
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Text Layer
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Text(
                imageName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}