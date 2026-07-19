import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/daily_goals_section.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/EditRoutineHeader.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/nutrition_plan_card.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/workout_plan_section.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/createRoutine.dart';

class Editruting extends StatelessWidget {
  const Editruting({super.key});

  @override
  Widget build(BuildContext context) {
    final Createroutine controller = Get.put(Createroutine());

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  //==========================================editroutine=================================
                  Obx(() => EditRoutineHeader(
                    clientName: controller.clientName.value,
                    imageUrl: controller.clientImage.value,
                    isCreateMode: controller.isCreateMode.value,
                  )),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "WORKOUT PLAN",
                        style: TextStyle(
                          color: Color(0xff9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/icon/Container (1).png",
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //==========================================WorkoutPlanSection=======================================
                  Obx(() {
                    final list = controller.exercises.toList();
                    return WorkoutPlanSection(
                      onAddPressed: controller.addExercise,
                      exerciseController: controller.exerciseController,
                      exercises: list,
                      onRemovePressed: controller.removeExercise,
                    );
                  }),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "NUTRITION PLAN",
                        style: TextStyle(
                          color: Color(0xff9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/image/Container (9).png",
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  NutritionPlanCard(
                    caloriesController: controller.caloriesController,
                    proteinController: controller.proteinController,
                    carbsController: controller.carbsController,
                    fatsController: controller.fatsController,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "DAILY GOALS",
                        style: TextStyle(
                          color: Color(0xff9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/image/Container (10).png",
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  DailyGoalsSection(
                    drinkWater: controller.drinkWater,
                    steps10k: controller.steps10k,
                    noSugar: controller.noSugar,
                    sleep8Hours: controller.sleep8Hours,
                    toggleGoal: controller.toggleGoal,
                    clientName: controller.clientName.value,
                    onSave: () {
                      controller.submitRoutine();
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00B171),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
