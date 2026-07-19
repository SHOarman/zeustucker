import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/Customadminbutton.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/user_story_tile.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/storycard.dart';
import 'package:zeustucker/presention/admininterface/widget/customnevadminbutton.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';

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

              //=============================Coach Portal Card====================================================
              CoachPortalCard(),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pending Stories",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D292E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint("done");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "3 New",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //==================================storycard================================
              const SizedBox(height: 20),

              SizedBox(
                height: 310, // Ensure enough height for the card
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final mockData = [
                      {
                        "image": "assets/image/Panel 2.png",
                        "title": "Morning Routine.",
                        "author": "Sarah J",
                      },
                      {
                        "image": "assets/image/Marcus.png",
                        "title": "Bedtime Comic.",
                        "author": "Marcus C.",
                      },
                      {
                        "image": "assets/image/Marcus.png",
                        "title": "Jane D.",
                        "author": "Bedtime Comic",
                      },
                    ];

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: StoryCard(
                        onTap: () {
                          debugPrint("Tapped on ${mockData[index]['title']}");
                        },
                        imageUrl: mockData[index]["image"]!,
                        author: mockData[index]["author"]!,
                        title: mockData[index]["title"]!,
                      ),
                    );
                  },
                ),
              ),

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
                      Get.toNamed(AppRoutes.adminclient);
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
                if (controller.isLoading.value && controller.clientList.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (controller.clientList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No clients managed by this coach",
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                }

                // Show only the last 3 added clients
                final homeClients = controller.clientList.length > 3
                    ? controller.clientList.sublist(controller.clientList.length - 3)
                    : controller.clientList;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: homeClients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final client = homeClients[index];
                    final String name = client['name'] ?? client['email'] ?? 'Client';
                    final String imageUrl = (client['profile_image'] != null && client['profile_image'].toString().isNotEmpty && client['profile_image'] != 'string')
                        ? client['profile_image']
                        : "assets/image/David Park.png";

                    return UserStoryTile(
                      imageUrl: imageUrl,
                      name: name,
                      status: client['fitness_goal'] ?? "Active Client",
                      onViewStory: () {
                        Future.microtask(() => Get.toNamed(AppRoutes.viewstory, arguments: client));
                      },
                    );
                  },
                );
              }),
              
              const SizedBox(height: 30),
              
              CustomIconButton(title: "Add New Client", iconPath: "assets/icon/Container (6).png", onTap: (){
                Get.toNamed(AppRoutes.addnewclient);
              }),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
