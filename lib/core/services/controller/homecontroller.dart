import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  var hasWorkout = false.obs;

  final PageController pageController = PageController();

  final List<String> storyPages = [
    "assets/image/s1.png",
    "assets/image/s2.png",
    "assets/image/s3.png",
  ];

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < storyPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
 //====================working================workout

  void toggleWorkout() {
    hasWorkout.value = !hasWorkout.value;
  }

//====================add Routing-====================================
  final noteController = TextEditingController();

  void postNote() {
    String note = noteController.text.trim();
    if (note.isNotEmpty) {
      print("Note Posted: $note");
      noteController.clear();
      Get.snackbar("Success", "Note added to your routine!",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Error", "Please enter a note first",
          snackPosition: SnackPosition.BOTTOM);
    }
  }



  @override
  void onClose() {
    pageController.dispose();
    noteController.dispose();
    super.onClose();
  }
}