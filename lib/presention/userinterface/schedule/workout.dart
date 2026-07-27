import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/schedule_controller.dart';
import '../../customwidget/WorkoutDayCard.dart';

class Workout extends StatelessWidget {
  const Workout({super.key});

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
                "Weekly Workout",
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
                  "assets/image/image 6.png",
                  height: 232,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Weekly Workout Summary",
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
                      "Workout: ${ctrl.workoutCompleted.value} / ${ctrl.workoutAssigned.value}",
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

              //====================================workout day cards====================================//
              Obx(() {
                if (ctrl.weeklyWorkouts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No workout plan assigned",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: ctrl.weeklyWorkouts.map((day) {
                    final isNoWorkout = day.items.isEmpty || day.assignedCount == 0;
                    String title = "No workout";
                    String? subtitle;
                    String iconPath = "assets/icon/Container (4).png";

                    if (!isNoWorkout) {
                      final item = day.items.first;
                      final instruction = item.instruction;
                      final parts = instruction.split(' ');
                      title = parts.isNotEmpty ? parts.first : "Workout";
                      subtitle = parts.length > 1 ? parts.sublist(1).join(' ') : null;

                      if (instruction.toLowerCase().contains("strength")) {
                        iconPath = "assets/icon/Container (1).png";
                      } else if (instruction.toLowerCase().contains("custom")) {
                        iconPath = "assets/icon/Container (2).png";
                      } else if (instruction.toLowerCase().contains("cardio")) {
                        iconPath = "assets/icon/Container (3).png";
                      } else {
                        iconPath = "assets/icon/Container (1).png"; // default fallback icon
                      }
                    }

                    return WorkoutDayCard(
                      day: _getWeekdayLabel(day.date),
                      date: _getDayNumber(day.date),
                      iconPath: iconPath,
                      title: title,
                      subtitle: subtitle,
                      isNoWorkout: isNoWorkout,
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