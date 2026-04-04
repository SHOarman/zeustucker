// ignore_for_file: file_names
import 'package:flutter/material.dart';

class WorkoutDayCard extends StatelessWidget {
  final String day;
  final String date;
  final String iconPath;
  final String title;
  final String? subtitle;
  final bool isNoWorkout;

  const WorkoutDayCard({
    super.key,
    required this.day,
    required this.date,
    required this.iconPath,
    required this.title,
    this.subtitle,
    this.isNoWorkout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isNoWorkout ? const Color(0xffF9F9F9) : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff323232),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: isNoWorkout ? Colors.grey.withValues(alpha: 0.5) : null,
          ),
          const SizedBox(width: 15),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isNoWorkout ? Colors.grey : const Color(0xff323232),
                    ),
                  ),
                  if (subtitle != null)
                    TextSpan(
                      text: " $subtitle",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}