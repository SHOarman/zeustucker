import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';
import 'package:zeustucker/core/services/controller/schedule_controller.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ScheduleController());
    ctrl.syncWithHomeController();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: const CustomBottomNav(selectIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Weekly Title
              const Text(
                'Weekly',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D292E),
                ),
              ),
              const SizedBox(height: 20),

              // // Image Section
              // _buildTopImageCard(),

              const SizedBox(height: 30),

              // Weekly Status Title
              Row(
                children: const [
                  Text(
                    '🔥 Weekly Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D292E),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Divider(color: Color(0xFF000000)),
              ),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A781)),
                      ),
                    ),
                  );
                }

                // Show week status count
                final compliantDays = ctrl.weeklySummary.value?.dailyPoints
                    .where((x) => x.combinedScore > 0 && !x.isFuture)
                    .length ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$compliantDays Days Week',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF323232),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bar chart
                    _buildBarChart(ctrl),

                    const SizedBox(height: 30),

                    // Metric Cards
                    Row(
                      children: [
                        _buildMetricCard(
                          title: 'Workout',
                          value: '${ctrl.todayWorkoutCompleted.value}/${ctrl.todayWorkoutAssigned.value}',
                          progress: ctrl.todayWorkoutAssigned.value > 0
                              ? (ctrl.todayWorkoutCompleted.value / ctrl.todayWorkoutAssigned.value).clamp(0.0, 1.0)
                              : 0.0,
                          color: const Color(0xFF38B8E6),
                          imagePath: 'assets/image/Group (2).png',
                          ontap: () {
                            Get.toNamed(AppRoutes.workout);
                          },
                        ),
                        _buildMetricCard(
                          title: 'Meals',
                          value: '${ctrl.mealsCompleted.value}/${ctrl.mealsAssigned.value}',
                          progress: ctrl.mealsAssigned.value > 0
                              ? (ctrl.mealsCompleted.value / ctrl.mealsAssigned.value).clamp(0.0, 1.0)
                              : 0.0,
                          color: const Color(0xFFFACC15),
                          imagePath: 'assets/image/Group (3).png',
                          ontap: () {
                            Get.toNamed(AppRoutes.meal);
                          },
                        ),
                        _buildMetricCard(
                          title: 'Tasks',
                          value: '${ctrl.todayTasksCompleted.value}/${ctrl.todayTasksAssigned.value}',
                          progress: ctrl.todayTasksAssigned.value > 0
                              ? (ctrl.todayTasksCompleted.value / ctrl.todayTasksAssigned.value).clamp(0.0, 1.0)
                              : 0.0,
                          color: const Color(0xFF34D399),
                          imagePath: 'assets/image/To do list.png',
                          ontap: () {
                            Get.toNamed(AppRoutes.task);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 40),
              //
              // // Generate Weekly Story Button
              // SizedBox(
              //   width: double.infinity,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       gradient: const LinearGradient(
              //         colors: [Color(0xFF48D1A3), Color(0xFF00A781)],
              //       ),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: ElevatedButton(
              //       onPressed: () {
              //
              //         //=====================================================
              //         Get.toNamed(AppRoutes.weeklystoty);
              //
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.transparent,
              //         shadowColor: Colors.transparent,
              //         padding: const EdgeInsets.symmetric(vertical: 16),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //       child: const Text(
              //         'Generate Weekly Story',
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildBarChart(ScheduleController ctrl) {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildScoreText(ctrl, index),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: ctrl.barHeights[index],
                decoration: BoxDecoration(
                  color: const Color(0xFF00A781),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScoreText(ScheduleController ctrl, int index) {
    final points = ctrl.weeklySummary.value?.dailyPoints ?? [];
    double score = 0;
    for (var p in points) {
      try {
        final dt = DateTime.parse(p.date);
        if (dt.weekday == index + 1) {
          score = p.combinedScore;
          break;
        }
      } catch (_) {}
    }

    if (score == 0) return const SizedBox(height: 14);

    String scoreText = score.toStringAsFixed(2);
    if (scoreText.endsWith('.00')) {
      scoreText = score.toStringAsFixed(0);
    } else if (scoreText.endsWith('0')) {
      scoreText = score.toStringAsFixed(1);
    }

    return Text(
      scoreText,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF00A781),
      ),
    );
  }

  Widget _buildMetricCard({
    required String imagePath,
    required String title,
    required String value,
    required double progress,
    required Color color,
    required Function ontap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ontap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon er bodole ekhane image use kora hoyeche
                  Image.asset(
                    imagePath,
                    height: 16,
                    width: 16,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5563),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 4,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Container(
                              height: 4,
                              width: constraints.maxWidth * progress,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
