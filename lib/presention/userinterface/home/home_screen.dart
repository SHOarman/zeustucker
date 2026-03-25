import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';
import 'package:zeustucker/presention/userinterface/home/widget/RoutineNoteInput.dart';
import 'package:zeustucker/presention/userinterface/home/widget/marcotargets.dart';
import 'package:zeustucker/presention/userinterface/home/widget/workoutSection.dart';

import '../../../core/services/controller/homecontroller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  void _showStoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 40,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  right: 15,
                  child: IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: controller.pageController,
                            itemCount: controller.storyPages.length,
                            onPageChanged: controller.updateIndex,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    controller.storyPages[index],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Back Arrow
                          Obx(
                            () => controller.currentIndex.value > 0
                                ? Positioned(
                                    left: 5,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new,
                                      ),
                                      onPressed: controller.previousPage,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          // Forward Arrow
                          Obx(
                            () =>
                                controller.currentIndex.value <
                                    controller.storyPages.length - 1
                                ? Positioned(
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: controller.nextPage,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    // Reactive Dots
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.storyPages.length,
                            (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: controller.currentIndex.value == index
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(selectIndex: 0),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Profile Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning, John!",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff323232),
                        ),
                      ),
                      Text(
                        "Ready to build today's story?",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => print("Profile"),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/image/Ellipse 1.png",
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Book Card
              Container(
                width: double.infinity,
                height: 530,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage("assets/image/book.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () => _showStoryDialog(context),
                      child: Container(
                        width: 180,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            "Open Book",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Macro Targets Title
              Row(
                children: [
                  Image.asset(
                    "assets/icon/Container.png",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Todays Macro Targets",
                    style: TextStyle(
                      color: Color(0xff2D292E),
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Macro Slider
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    MacroTargetCard(
                      label: "Calories",
                      value: "0",
                      unit: "kcal",
                      iconPath: "assets/image/Icon.png",
                      valueColor: const Color(0xFFE05C5C),
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    MacroTargetCard(
                      label: "Protein",
                      value: "0",
                      unit: "g",
                      iconPath: "assets/image/Margin344.png",
                      valueColor: const Color(0xFF1CBBA7),
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    MacroTargetCard(
                      label: "Carbs",
                      value: "0",
                      unit: "g",
                      iconPath: "assets/image/Margin.png",
                      valueColor: const Color(0xFFEF9E16),
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    MacroTargetCard(
                      label: "Fats",
                      value: "0",
                      unit: "g",
                      iconPath: "assets/image/Margin34.png",
                      valueColor: const Color(0xFFE93CA4),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              CustomDottedCard(
                bodyText: "No macro targets set for today.",
                centerWidget: Image.asset("assets/image/cicel.png"),
                onTap: () {},
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Image.asset("assets/icon/workout.png"),
                  SizedBox(width: 6),
                  Text(
                    "Todays Workout",
                    style: TextStyle(
                      color: Color(0xff111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              CustomDottedCard(
                bodyText: "No workout has been set for today yet.",
                centerWidget: Image.asset("assets/image/deactiveworkout.png"),
                onTap: () {},
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Image.asset("assets/image/notes.png", height: 20, width: 20),
                  SizedBox(width: 8),
                  Text(
                    "Routine Notes",
                    style: TextStyle(
                      color: Color(0xff111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12,),
              RoutineNoteInput(
                controller: controller.noteController,
                onPost: controller.postNote,
              ),

              SizedBox(height: 12,),
              CustomDottedCard(
                bodyText: "No routine notes for today.",
                centerWidget: Image.asset("assets/image/addrouting.png"),
                onTap: () {},
              ),

            ],
          ),
        ),
      ),
    );
  }
}
