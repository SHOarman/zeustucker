import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';
import 'homewidget/user_story_tile.dart';

class AllClinet extends StatelessWidget {
  const AllClinet({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientController controller = Get.find<ClientController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Client Roster",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D292E),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.clientList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.clientList.isEmpty) {
          return Center(
            child: Text(
              "No clients found",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        final allClients = controller.clientList;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: allClients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final client = allClients[index];
            final String name = client['name'] ?? client['email'] ?? 'Client';
            final String imageUrl = (client['profile_image'] != null && client['profile_image'].toString().isNotEmpty && client['profile_image'] != 'string')
                ? client['profile_image']
                : "assets/image/David Park.png";

            return UserStoryTile(
              imageUrl: imageUrl,
              name: name,
              status: client['fitness_goal'] ?? "Active Client",
              onViewStory: () {
                controller.fetchAndOpenClientStorybook(client);
              },
            );
          },
        );
      }),
    );
  }
}
