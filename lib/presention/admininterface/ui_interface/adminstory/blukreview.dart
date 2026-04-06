import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/CustomActionButton.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/HorizontalUserCard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/UserProfileTile.dart';

class Blukreview extends StatelessWidget {
  const Blukreview({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> storyData = [
      {"image": "assets/image/Morning Gym Routine.png", "text": "Morning Routine"},
      {"image": "assets/image/Thumbnail.png", "text": "Study Routine"},
      {"image": "assets/image/Panel 1.png", "text": "Workout Routine"},
      {"image": "assets/image/Morning Gym Routine.png", "text": "Evening Routine"},
    ];

    final List<Map<String, String>> storyData2 = [
      {"image": "assets/image/Thumbnail.png", "text": "Morning Routine"},
      {"image": "assets/image/Morning Gym Routine.png", "text": "Study Routine"},
      {"image": "assets/image/Panel 1.png", "text": "Workout Routine"},
      {"image": "assets/image/Morning Gym Routine.png", "text": "Evening Routine"},
    ];

    final List<Map<String, String>> storydata34 = [
      {"image": "assets/image/Background (5).png", "text": "Morning Routine"},
      {"image": "assets/image/Background (6).png", "text": "Study Routine"},
      {"image": "assets/image/Panel 1.png", "text": "Workout Routine"},
      {"image": "assets/image/Morning Gym Routine.png", "text": "Evening Routine"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              CustomUserTile(userName: "Sarah Jenkins", routineText: "MORNING ROUTINE", imageUrl: "assets/image/Sarah J..png"),
              const SizedBox(height: 20),



              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: storyData.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return HorizontalUserCard(
                      imageUrl: storyData[index]["image"]!,
                      isAsset: true,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              CustomUserTile(userName: "Marcus Chen", routineText: "GYM FLOW", imageUrl: "assets/image/Panel 1.png"),
              const SizedBox(height: 20),

              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: storyData2.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return HorizontalUserCard(
                      imageUrl: storyData[index]["image"]!,
                      isAsset: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
               CustomUserTile(userName: "Elena L.", routineText: "MEDITATION SESSION", imageUrl: "assets/image/Background (4).png"),
              const SizedBox(height: 20),


              SizedBox(
                height: 160,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storydata34.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {

                  return HorizontalUserCard(imageUrl: storydata34[index]["image"]!, isAsset: true,);
                })),
              const SizedBox(height: 60),

              Column(
                children: [
                  CustomActionButton(
                    label: "Approve Selected (8)",
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      Get.toNamed(AppRoutes.adminhome);
                    }
                  ),

                  const SizedBox(height: 16),

                  CustomActionButton(
                    label: "Regenerate Selected",
                    icon: Icons.refresh,
                    isPrimary: false,
                    onTap: () => print("Regenerating..."),
                  ),
                ],
              ),

              const SizedBox(height: 60),




            ],
          ),
        ),
      ),
    );
  }
}