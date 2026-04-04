import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/Customadminbutton.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/user_story_tile.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/homewidget/storycard.dart';
import 'package:zeustucker/presention/admininterface/widget/customnevadminbutton.dart';

import 'homewidget/CoachPortalCard.dart';

class Adminhome extends StatelessWidget {
  const Adminhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Customnevadminbutton(selectIndex: 0),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 70),

              //=============================Coach Portal Card====================================================
              CoachPortalCard(),

              SizedBox(height: 30),
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
                      // Get.toNamed(AppRoutes.adminclients);
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
              SizedBox(height: 20),

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

              SizedBox(height: 30),
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
                    onPressed: () {},
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
              SizedBox(height: 10),

              UserStoryTile(imageUrl: "assets/image/David Park.png", name: "Marcus Chen", status: "Marcus Chen", onViewStory: (){
                Future.microtask(() => Get.toNamed(AppRoutes.viewstory));
              }),
              // SizedBox(height: 5),
              UserStoryTile(imageUrl: "assets/image/Sarah.png", name: "Sarah Jenkins", status: "Routine Updated", onViewStory: (){
                Future.microtask(() => Get.toNamed(AppRoutes.viewstory));
              }),
              // SizedBox(height: 5),
              UserStoryTile(imageUrl: "assets/image/David Park.png", name: "Marcus Chen", status: "Marcus Chen", onViewStory: (){
                Future.microtask(() => Get.toNamed(AppRoutes.viewstory));
              }),
              // SizedBox(height: 5),
              UserStoryTile(imageUrl: "assets/image/Sarah.png", name: "Sarah Jenkins", status: "Routine Updated", onViewStory: (){
                Future.microtask(() => Get.toNamed(AppRoutes.viewstory));
              }),
              
              
              SizedBox(height: 30),
              
              CustomIconButton(title: "Add New Client", iconPath: "assets/icon/Container (6).png", onTap: (){
                Get.toNamed(AppRoutes.addnewclient);
              })
              






            ],
          ),
        ),
      ),
    );
  }
}
