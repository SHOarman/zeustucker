import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../customwidget/WorkoutDayCard.dart';

class Workout extends StatelessWidget {
  const Workout({super.key});

  @override
  Widget build(BuildContext context) {
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

              Container(
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
                    const Text("Workout: 4 / 5",
                        style: TextStyle(color: Color(0xff323232), fontWeight: FontWeight.w500,)),
                  ],
                ),
              ),
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

              Column(
                children: [
                  WorkoutDayCard(
                    day: "Mon", date: "22",
                    iconPath: "assets/icon/Container (1).png",
                    title: "Strength", subtitle: "45 min Medium",
                  ),
                  WorkoutDayCard(
                    day: "Tues", date: "23",
                    iconPath: "assets/icon/Container (2).png",
                    title: "Custom", subtitle: "1 hour",
                  ),
                  WorkoutDayCard(
                    day: "Wed", date: "24",
                    iconPath: "assets/icon/Container (3).png",
                    title: "Cardio", subtitle: "30 min",
                  ),
                  WorkoutDayCard(
                    day: "Thur", date: "25",
                    iconPath: "assets/icon/Container (1).png",
                    title: "Strength", subtitle: "30 min Medium",
                  ),
                  WorkoutDayCard(
                    day: "Fri", date: "26",
                    iconPath: "assets/icon/Container (4).png",
                    title: "No workout",
                    isNoWorkout: true,
                  ),
                  WorkoutDayCard(
                    day: "Sat", date: "27",
                    iconPath: "assets/icon/Container (4).png",
                    title: "No workout",
                    isNoWorkout: true,
                  ),
                  WorkoutDayCard(
                    day: "Sun", date: "28",
                    iconPath: "assets/icon/Container (4).png",
                    title: "No workout",
                    isNoWorkout: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}