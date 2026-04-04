import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/daily_goals_section.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/EditRoutineHeader.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/nutrition_plan_card.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/workout_plan_section.dart';

class Editruting extends StatelessWidget {
  const Editruting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(height: 70),

                //==========================================editroutine=================================
                EditRoutineHeader(
                  clientName: "Sarah Jenkins",
                  imageUrl: "assets/image/Elena Rodriguez.png",
                ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      "WORKOUT PLAN",
                      style: TextStyle(
                        color: Color(0xff9CA3AF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      "assets/icon/Container (1).png",
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                //==========================================WorkoutPlanSection=======================================
                WorkoutPlanSection(
                  onAddPressed: () {},
                  exerciseController: TextEditingController(),
                ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      "NUTRITION PLAN",
                      style: TextStyle(
                        color: Color(0xff9CA3AF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      "assets/image/Container (9).png",
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                NutritionPlanCard(
                  caloriesController: TextEditingController(),
                  proteinController: TextEditingController(),
                  carbsController: TextEditingController(),
                  fatsController: TextEditingController(),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      "DAILY GOALS",
                      style: TextStyle(
                        color: Color(0xff9CA3AF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      "assets/image/Container (10).png",
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                DailyGoalsSection(
                  onSave: () {
                    Get.toNamed(AppRoutes.adminhome);
                  },
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
