import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/panelcard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/routine_needs_review_card.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/widget/stories_management_card.dart';
import '../../widget/customnevadminbutton.dart';

class Adminstory extends StatelessWidget {
  const Adminstory({super.key});

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "8 Active Reviews",
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
              const SizedBox(height: 20),
              const RoutineNeedsReviewCard(
                name: "Sarah Jenkins",
                routineName: "MORNING ROUTINE V2",
                imageUrl: "assets/image/Panel 2.png",
                buttonText: 'NEEDS REVIEW',
                buttonColor: Color(0xffA16207),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 195,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: const [
                      Panelcard(
                        imageUrl: 'assets/image/Panel 1.png',
                        panelName: 'Panel 1',
                        showTick: false,
                      ),
                      SizedBox(width: 10),
                      Panelcard(
                        imageUrl: 'assets/image/Panel 2.png',
                        showTick: false,
                        panelName: "panel 2",
                      ),
                      SizedBox(width: 10),
                      Panelcard(
                        imageUrl: 'assets/image/Thumbnail.png',
                        panelName: 'Panel 3',
                        showTick: false,
                      ),
                      SizedBox(width: 10),

                      Panelcard(
                        imageUrl: 'assets/image/Panel 2.png',
                        showTick: false,
                        panelName: "panel 4",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),


              //========================button=======================================================

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. REGENERATE ALL Button
                  Material(
                    elevation: 2,
                    shadowColor: Colors.black26,
                    color: const Color(0xff00A97D),
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () {
                        debugPrint("Regenerate All Tap");
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 240,
                        height: 48,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "REGENERATE ALL",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 2. EDIT Button
                  Material(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () {
                        debugPrint("Edit Tap");
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 80,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xffE5E7EB), width: 1),
                        ),
                        child: Text(
                          "EDIT",
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xff374151),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),




              const RoutineNeedsReviewCard(
                name: "Marcus Chen",
                routineName: "Gym Flow Comic",
                imageUrl: "assets/image/Panel 1.png",
                buttonText: 'FINISHED',
                buttonColor: Color(0xff15803D),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 195,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: const [
                      Panelcard(
                        imageUrl: 'assets/image/Panel 1.png',

                        showTick: true,
                      ),
                      SizedBox(width: 10),
                      Panelcard(
                        imageUrl: 'assets/image/Panel 2.png',
                        showTick: true,
                      ),
                      SizedBox(width: 10),
                      Panelcard(
                        imageUrl: 'assets/image/Thumbnail.png',
                        showTick: true,
                      ),
                      SizedBox(width: 10),

                      Panelcard(
                        imageUrl: 'assets/image/Panel 2.png',
                        showTick: true,
                      ),
                    ],
                  ),
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }
}