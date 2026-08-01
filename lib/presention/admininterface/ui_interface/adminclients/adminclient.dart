import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/widget/add_user_button.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';
import '../adminhome/homewidget/user_story_tile.dart';
import 'widget/client_roseter.dart';
import '../../widget/customnevadminbutton.dart';

class Adminclient extends StatelessWidget {
  const Adminclient({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientController controller = Get.put(ClientController());

    return Scaffold(
      bottomNavigationBar: Customnevadminbutton(selectIndex: 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              Clientroseter(),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Clients",
                    style: TextStyle(
                      color: Color(0xff1A1A1A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "A-Z",
                      style: TextStyle(
                        color: Color(0xff9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Obx(() {
                final list = controller.filteredClients;

                if (controller.isLoading.value && list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF00A37B)),
                      ),
                    ),
                  );
                }

                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        "No clients found",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    var client = list[index];
                    final String name = client['name'] ?? client['email'] ?? 'Client';
                    final String imageUrl = (client['profile_image'] != null &&
                            client['profile_image'].toString().isNotEmpty &&
                            client['profile_image'] != 'string')
                        ? client['profile_image']
                        : "assets/image/David Park.png";
                    final String status = client['fitness_goal'] ?? client['occupation'] ?? "Active Client";

                    return UserStoryTile(
                      imageUrl: imageUrl,
                      name: name,
                      status: status,
                      onTap: () {
                        Get.toNamed(AppRoutes.clientdetails, arguments: client);
                      },
                      onViewStory: () {
                        final String? storybookId = client['storybook_id']?.toString() ?? client['latest_storybook_id']?.toString();
                        if (storybookId != null && storybookId.isNotEmpty && storybookId != 'null' && storybookId != 'string') {
                          debugPrint(">>> 📦 [SOURCE: CLIENT OBJECT PARAMETER] Storybook ID: '$storybookId' for $name");
                          controller.fetchAndOpenClientStorybookById(storybookId, client);
                        } else {
                          debugPrint(">>> 🔄 [SOURCE: FALLBACK LOOKUP (Cache/Server)] Checking for $name");
                          controller.fetchAndOpenClientStorybook(client);
                        }
                      },
                    );
                  },
                );
              }),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AddUserButton(
                    onTap: () {
                      Get.toNamed(AppRoutes.addnewclient);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}