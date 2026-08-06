import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/Customadminbutton.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/user_story_tile.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/storycard.dart';
import 'package:zeustucker/presention/admininterface/widget/customnevadminbutton.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';
import '../../../../core/services/api_services/api_services.dart';

import 'homewidget/CoachPortalCard.dart';

class Adminhome extends StatelessWidget {
  const Adminhome({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientController controller = Get.put(ClientController());

    return Scaffold(
      bottomNavigationBar: Customnevadminbutton(selectIndex: 0),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 70),

              Obx(() {
                if (controller.generatingStorybookClientName.value.isEmpty)
                  return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00A37B),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF00A37B)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Generating storybook for ${controller.generatingStorybookClientName.value} in the background...",
                          style: const TextStyle(
                            color: Color(0xFF004D40),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              //=============================Coach Portal Card====================================================
              CoachPortalCard(),

              const SizedBox(height: 30),
              Obx(() {
                if (controller.pendingStoriesList.isEmpty)
                  return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Story Not Created",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D292E),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${controller.pendingStoriesList.length} New",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    //==================================storycard================================
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 310,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.pendingStoriesList.length,
                        itemBuilder: (context, index) {
                          final pendingStory =
                              controller.pendingStoriesList[index];
                          final String profileName =
                              pendingStory['profile_name'] ?? 'Client';
                          final String profileImage =
                              (pendingStory['profile_image'] != null &&
                                  pendingStory['profile_image']
                                      .toString()
                                      .isNotEmpty &&
                                  pendingStory['profile_image'].toString() !=
                                      'string')
                              ? pendingStory['profile_image']
                              : "assets/image/David Park.png";

                          final normalizedImageUrl =
                              profileImage.startsWith('http') ||
                                  profileImage.startsWith('assets/')
                              ? profileImage
                              : ApiServices.normalizeImageUrl(profileImage);

                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: StoryCard(
                              onTap: () {},
                              imageUrl: normalizedImageUrl,
                              author: '',
                              title: profileName,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Client Roster",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D292E),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.allclinet);
                    },
                    child: Text(
                      "View All",
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              //=============================UserStoryTile======================================================
              const SizedBox(height: 10),

              Obx(() {
                if (controller.isLoading.value &&
                    controller.clientList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.clientList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No clients managed by this coach",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                final homeClients = controller.clientList.reversed
                    .take(3)
                    .toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: homeClients.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final client = homeClients[index];
                    final String name =
                        client['name'] ?? client['email'] ?? 'Client';
                    final String imageUrl =
                        (client['profile_image'] != null &&
                            client['profile_image'].toString().isNotEmpty &&
                            client['profile_image'] != 'string')
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

              const SizedBox(height: 30),

              CustomIconButton(
                title: "Add New Client",
                iconPath: "assets/icon/Container (6).png",
                onTap: () {
                  Get.toNamed(AppRoutes.addnewclient);
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
