import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/widget/profileprogresscard.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';

class Clientdetels extends StatelessWidget {
  const Clientdetels({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? client = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              SizedBox(height: 70,),

              //=============================Clientprogresscard===================================================


              if (client != null) ...[
                (() {
                  String formatDateRange(String? start, String? end) {
                    if (start == null || start.isEmpty) return "Current Week";
                    try {
                      final sDate = DateTime.parse(start);
                      final eDate = end != null && end.isNotEmpty ? DateTime.parse(end) : null;
                      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                      
                      final sStr = "${sDate.day} ${months[sDate.month - 1]}";
                      if (eDate != null) {
                        final eStr = "${eDate.day} ${months[eDate.month - 1]}";
                        return "$sStr - $eStr";
                      }
                      return sStr;
                    } catch (_) {
                      return start;
                    }
                  }

                  final String imageUrl = (client['profile_image'] != null && client['profile_image'].toString().isNotEmpty && client['profile_image'] != 'string')
                      ? client['profile_image']
                      : (client['image'] ?? "assets/image/David Park.png");
                  
                  final String fitnessGoal = client['fitness_goal'] ?? 'General Fitness';
                  final String weekRange = formatDateRange(client['week_start'], client['week_end']);
                  final String programName = "$fitnessGoal • $weekRange";

                  return ClientProfileHeader(
                    name: client['name'] ?? '',
                    imageUrl: imageUrl,
                    programName: programName,
                    progress: client['progress'] ?? 0.0,
                    onBackTap: () {
                      Get.back();
                    },
                    onMenuTap: () {},
                  );
                })(),
                _DailyStorybookCard(client: client),
                const _CurrentRoutineCard(),
                const _ProgressNotesCard(),
                _BottomActionButtons(client: client),
                const SizedBox(height: 40),
              ] else
                const Center(child: Text('No Client details available.')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyStorybookCard extends StatelessWidget {
  final Map<String, dynamic>? client;
  const _DailyStorybookCard({this.client});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (client != null) {
          final ClientController controller = Get.find<ClientController>();
          controller.fetchAndOpenClientStorybook(client!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF3F4F6),
                image: client != null && client!['image'] != null
                    ? DecorationImage(
                        image: client!['image'].startsWith('http') ? NetworkImage(client!['image']) as ImageProvider : AssetImage(client!['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: client == null || client!['image'] == null
                  ? const Icon(Icons.person, color: Color(0xFF9CA3AF))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Storybook",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Today's comic panel updated",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFF00C48C),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentRoutineCard extends StatelessWidget {
  const _CurrentRoutineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Routine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Active Phase: Hypertrophy",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF00C48C),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "WORKOUT",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Upper Body A",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MACROS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "180P / 250C / 65F",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressNotesCard extends StatelessWidget {
  const _ProgressNotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8FBF4),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF00C48C),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Progress Notes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Feeling stronger in the morning...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: Color(0xFF00C48C),
          ),
        ],
      ),
    );
  }
}

class _BottomActionButtons extends StatelessWidget {
  final Map<String, dynamic> client;
  const _BottomActionButtons({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {

                Get.toNamed(AppRoutes.editroutine);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C48C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: const Color(0xFF00C48C).withValues(alpha: 0.5),
              ),
              child: const Text(
                "EDIT ROUTINE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final ClientController controller = Get.find<ClientController>();
                controller.generateStorybookForClient(client);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.3),
              ),
              child: const Text(
                "CREATE STORY",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
