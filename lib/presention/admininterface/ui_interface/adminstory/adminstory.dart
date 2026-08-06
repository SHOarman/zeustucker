import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/panelcard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/routine_needs_review_card.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/stories_management_card.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';
import '../../widget/customnevadminbutton.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/storycard.dart';
import 'package:zeustucker/core/services/api_services/api_services.dart';

class Adminstory extends StatelessWidget {
  const Adminstory({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientController controller = Get.isRegistered<ClientController>() 
        ? Get.find<ClientController>() 
        : Get.put(ClientController());

    return Scaffold(
      bottomNavigationBar: const Customnevadminbutton(selectIndex: 2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 70),
              StoriesManagementCard(
                totalStories: 124,
                starImageUrl: "assets/image/Overlay+OverlayBlur.png",
                // bookImageUrl: "assets/image/notes.png",
                onBulkReviewTap: () {
                  Get.toNamed(AppRoutes.blukreview);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Stories",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D292E),
                    ),
                  ),
                  Obx(() => GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${controller.pendingStoriesList.length} Active Reviews",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              
              Obx(() {
                if (controller.pendingStoriesList.isEmpty && controller.finishedStoriesList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("No stories found.", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Pending Stories (Horizontal Scroll)
                    if (controller.pendingStoriesList.isNotEmpty) ...[
                      SizedBox(
                        height: 310,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.pendingStoriesList.length,
                          itemBuilder: (context, index) {
                            final story = controller.pendingStoriesList[index];
                            final name = story['profile_name'] ?? 'Client';
                            final profileImage = (story['profile_image'] != null && story['profile_image'].toString().isNotEmpty && story['profile_image'].toString() != 'string')
                                ? story['profile_image']
                                : "assets/image/David Park.png";
                            
                            final normalizedImageUrl = profileImage.toString().startsWith('http') || profileImage.toString().startsWith('assets/') 
                                ? profileImage.toString() 
                                : ApiServices.normalizeImageUrl(profileImage.toString());

                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: StoryCard(
                                onTap: () {},
                                imageUrl: normalizedImageUrl,
                                author: '', 
                                title: name,
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    if (controller.finishedStoriesList.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Finished Stories",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2D292E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Finished Stories (Horizontal Scroll)
                    if (controller.finishedStoriesList.isNotEmpty) ...[
                      SizedBox(
                        height: 310,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.finishedStoriesList.length,
                          itemBuilder: (context, index) {
                            final story = controller.finishedStoriesList[index];
                            final name = story['profile_name'] ?? 'Client';
                            final profileImage = (story['profile_image'] != null && story['profile_image'].toString().isNotEmpty && story['profile_image'].toString() != 'string')
                                ? story['profile_image']
                                : "assets/image/David Park.png";
                            
                            final normalizedImageUrl = profileImage.toString().startsWith('http') || profileImage.toString().startsWith('assets/') 
                                ? profileImage.toString() 
                                : ApiServices.normalizeImageUrl(profileImage.toString());

                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: StoryCard(
                                onTap: () {
                                  controller.fetchAndOpenClientStorybook(story);
                                },
                                imageUrl: normalizedImageUrl,
                                author: '', 
                                title: name,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              }),



            ],
          ),
        ),
      ),
    );
  }
}