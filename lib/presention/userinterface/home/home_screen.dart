import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';
import 'package:zeustucker/presention/userinterface/home/widget/routine_note_input.dart';
import 'package:zeustucker/presention/userinterface/home/widget/marcotargets.dart';
import 'package:zeustucker/presention/userinterface/home/widget/workout_section.dart';

import 'package:zeustucker/core/services/api_services/api_services.dart';
import 'package:zeustucker/core/services/controller/macro_controller.dart';
import '../../../core/services/controller/homecontroller.dart';
import '../../../core/services/controller/profilecontroller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final MacroController macroController = Get.isRegistered<MacroController>()
      ? Get.find<MacroController>()
      : Get.put(MacroController());

  void _showStoryDialog(BuildContext context) {
    controller.fetchClientStorybook();

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
                Obx(() {
                  if (controller.isStoryLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF00A37B)),
                      ),
                    );
                  }

                  if (controller.clientPages.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No story pages generated for you yet. Please request your coach to generate a storybook.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 50),
                      // Story Title above image
                      Obx(() {
                        if (controller.clientPages.isEmpty) return const SizedBox.shrink();
                        final idx = controller.currentIndex.value;
                        if (idx >= controller.clientPages.length) return const SizedBox.shrink();
                        final page = controller.clientPages[idx];
                        final rawTitle = page['title'];
                        final String titleText = (rawTitle != null && rawTitle.toString() != 'null')
                            ? rawTitle.toString()
                            : '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            titleText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF18181B),
                            ),
                          ),
                        );
                      }),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: controller.pageController,
                              itemCount: controller.clientPages.length,
                              onPageChanged: controller.updateIndex,
                              itemBuilder: (context, index) {
                                final page = controller.clientPages[index];
                                final String rawImg = page['image_url'] ?? '';
                                final String normalizedUrl = controller.normalizeImageUrl(rawImg);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        normalizedUrl,
                                        height: 440,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        headers: controller.authToken.isNotEmpty
                                            ? {'Authorization': 'Bearer ${controller.authToken}'}
                                            : null,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 440,
                                          width: double.infinity,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
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
                              () => controller.currentIndex.value <
                                      controller.clientPages.length - 1
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              controller.clientPages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: controller.currentIndex.value == index ? 20 : 8,
                                decoration: BoxDecoration(
                                  color: controller.currentIndex.value == index
                                      ? const Color(0xFF00A37B)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
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
              Obx(() {
                final profileController = Get.put(EditProfileController());
                final String name = profileController.profileData['name'] ?? profileController.profileData['full_name'] ?? 'User';
                final String? profileImage = profileController.profileData['profile_image'];

                final hour = DateTime.now().hour;
                String greeting;
                if (hour >= 5 && hour < 12) {
                  greeting = "Good Morning";
                } else if (hour >= 12 && hour < 17) {
                  greeting = "Good Afternoon";
                } else if (hour >= 17 && hour < 21) {
                  greeting = "Good Evening";
                } else {
                  greeting = "Good Night";
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$greeting, $name!",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff323232),
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
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => debugPrint("Profile"),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipOval(
                          child: _buildSafeHeaderImage(profileImage, "assets/image/Ellipse 1.png"),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 40),
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
              Obx(() {
                final int cal = macroController.caloriesGoal.value > 0
                    ? macroController.caloriesGoal.value
                    : macroController.caloriesConsumed.value;
                final int prot = macroController.proteinGoal.value > 0
                    ? macroController.proteinGoal.value.toInt()
                    : macroController.protein.value.toInt();
                final int carb = macroController.carbsGoal.value > 0
                    ? macroController.carbsGoal.value.toInt()
                    : macroController.carbs.value.toInt();
                final int fat = macroController.fatsGoal.value > 0
                    ? macroController.fatsGoal.value.toInt()
                    : macroController.fats.value.toInt();

                final bool hasTarget = macroController.caloriesGoal.value > 0 ||
                    macroController.proteinGoal.value > 0 ||
                    macroController.carbsGoal.value > 0 ||
                    macroController.fatsGoal.value > 0;

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          MacroTargetCard(
                            label: "Calories",
                            value: "$cal",
                            unit: "kcal",
                            iconPath: "assets/image/Icon.png",
                            valueColor: const Color(0xFFE05C5C),
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          MacroTargetCard(
                            label: "Protein",
                            value: "$prot",
                            unit: "g",
                            iconPath: "assets/image/Margin344.png",
                            valueColor: const Color(0xFF1CBBA7),
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          MacroTargetCard(
                            label: "Carbs",
                            value: "$carb",
                            unit: "g",
                            iconPath: "assets/image/Margin.png",
                            valueColor: const Color(0xFFEF9E16),
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          MacroTargetCard(
                            label: "Fats",
                            value: "$fat",
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
                      bodyText: hasTarget
                          ? "Daily Target: $cal kcal (Protein: ${prot}g | Carbs: ${carb}g | Fats: ${fat}g)"
                          : "No macro targets set for today.",
                      centerWidget: Image.asset("assets/image/cicel.png"),
                      onTap: () {},
                    ),
                  ],
                );
              }),

              const SizedBox(height: 30),

              Row(
                children: [
                  Image.asset("assets/icon/workout.png"),
                  const SizedBox(width: 6),
                  const Text(
                    "Todays Workout",
                    style: TextStyle(
                      color: Color(0xff111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Obx(() {
                if (controller.isWorkoutLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1CBBA7)),
                      ),
                    ),
                  );
                }

                if (controller.workoutItems.isEmpty) {
                  return CustomDottedCard(
                    bodyText: "No workout has been set for today yet.",
                    centerWidget: Image.asset("assets/image/deactiveworkout.png"),
                    onTap: () {
                      controller.fetchAssignedWorkoutPlan();
                    },
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: controller.workoutItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.workoutItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          onTap: () {
                            controller.toggleWorkoutItemCompletion(item.id, !item.completed);
                          },
                          leading: Icon(
                            item.completed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: item.completed
                                ? const Color(0xFF1CBBA7)
                                : Colors.grey[400],
                            size: 26,
                          ),
                          title: Text(
                            item.instruction,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: item.completed
                                  ? Colors.grey[400]
                                  : const Color(0xff111827),
                              decoration: item.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 30),

              Row(
                children: [
                  Image.asset(
                    "assets/image/Container (10).png",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Daily Goals",
                    style: TextStyle(
                      color: Color(0xff111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Obx(() {
                if (controller.isGoalsLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1CBBA7)),
                      ),
                    ),
                  );
                }

                if (controller.todayGoals.isEmpty) {
                  return CustomDottedCard(
                    bodyText: "No daily goals have been set for today yet.",
                    centerWidget: Image.asset("assets/image/To do list.png"),
                    onTap: () {
                      controller.fetchTodayGoals();
                    },
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: controller.todayGoals.length,
                  itemBuilder: (context, index) {
                    final item = controller.todayGoals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          onTap: () {
                            controller.toggleGoalItemCompletion(item.id, !item.completed);
                          },
                          leading: Icon(
                            item.completed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: item.completed
                                ? const Color(0xFF1CBBA7)
                                : Colors.grey[400],
                            size: 26,
                          ),
                          title: Text(
                            item.instruction,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: item.completed
                                  ? Colors.grey[400]
                                  : const Color(0xff111827),
                              decoration: item.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

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

  Widget _buildSafeHeaderImage(String? profileImage, String defaultAsset) {
    if (profileImage == null || profileImage.isEmpty || profileImage == 'string' || profileImage == 'null') {
      return Image.asset(defaultAsset, height: 60, width: 60, fit: BoxFit.cover);
    }

    if (profileImage.startsWith('http://') || profileImage.startsWith('https://')) {
      return Image.network(
        profileImage,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final altUrl = profileImage.contains(':8000')
              ? profileImage.replaceAll(':8000', ':8004')
              : profileImage.replaceAll(':8004', ':8000');
          return Image.network(
            altUrl,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultAsset,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }

    if (profileImage.startsWith('/')) {
      final primaryUrl = "${ApiServices.baseUrl}$profileImage";
      final altUrl = "${ApiServices.baseUrl.replaceAll(':8000', ':8004')}$profileImage";
      return Image.network(
        primaryUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.network(
          altUrl,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            defaultAsset,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (profileImage.startsWith('assets/')) {
      return Image.asset(
        profileImage,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, height: 60, width: 60, fit: BoxFit.cover),
      );
    }

    try {
      final bytes = base64Decode(profileImage);
      return Image.memory(
        bytes,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(defaultAsset, height: 60, width: 60, fit: BoxFit.cover),
      );
    } catch (_) {
      return Image.asset(defaultAsset, height: 60, width: 60, fit: BoxFit.cover);
    }
  }
}
