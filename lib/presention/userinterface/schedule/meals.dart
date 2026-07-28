import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/schedule_controller.dart';
import '../../customwidget/WorkoutDayCard.dart';

class Meals extends StatelessWidget {
  const Meals({super.key});

  String _getWeekdayLabel(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const weekdays = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"];
      return weekdays[dt.weekday - 1];
    } catch (_) {
      return "";
    }
  }

  String _getDayNumber(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return dt.day.toString();
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScheduleController ctrl = Get.find<ScheduleController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weekly Meals",
                style: TextStyle(
                  color: Color(0xff323232),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Main Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/image/image 9.png",
                  height: 232,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Weekly Meals Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff323232),
                ),
              ),
              const SizedBox(height: 12),

              Obx(() => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/icon/Fire.png", height: 20),
                        const SizedBox(width: 8),
                        const Text("Streak: 1 Week",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff323232))),
                      ],
                    ),
                    Text(
                      "Meals: ${ctrl.mealsCompleted.value} / ${ctrl.mealsAssigned.value}",
                      style: const TextStyle(
                        color: Color(0xff323232),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),

              // "This Week" Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff00A878),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "This Week",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),

              //====================================meals day cards====================================//
              Obx(() {
                if (ctrl.weeklyMeals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No meals logged this week",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: ctrl.weeklyMeals.map((day) {
                    final hasLogged = day.consumed.kcal > 0 ||
                        day.consumed.protein > 0 ||
                        day.consumed.carbs > 0 ||
                        day.consumed.fat > 0;

                    final isNoMeal = !hasLogged;
                    String title = "No meals logged";
                    String? subtitle;
                    String iconPath = "assets/icon/Container (4).png";

                    if (!isNoMeal) {
                      title = "Logged: ${day.consumed.kcal.round()} kcal";
                      iconPath = "assets/icon/Container (3).png"; // meals icon
                    }

                    return WorkoutDayCard(
                      day: _getWeekdayLabel(day.date),
                      date: _getDayNumber(day.date),
                      iconPath: iconPath,
                      title: title,
                      subtitle: subtitle,
                      isNoWorkout: isNoMeal,
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}