import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/widget/clientcard.dart';

import 'package:zeustucker/core/services/controller/adminpenelcontroller/adminsendrequestcontroller.dart';
import 'homewidget/Customadminbutton.dart';
import 'homewidget/ManageClientsHeader.dart';

class Magaeclients extends StatelessWidget {
  const Magaeclients({super.key});

  @override
  Widget build(BuildContext context) {
    final Adminsendrequestcontroller controller = Get.put(Adminsendrequestcontroller());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              //=================================ManageClientsHeader====================================================
               ManageClientsHeader(),

              const SizedBox(height: 20),

              Obx(() => Text(
                "ALL CLIENTS (${controller.invitationList.length})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff9CA3AF)),
              )),

              const SizedBox(height: 10),

              //=====================================active&pendingcard================================================
              Obx(() {
                if (controller.isListLoading.value && controller.invitationList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.invitationList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No clients found",
                        style: TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.invitationList.map((item) {
                    String name = 'Client';
                    final fName = item['first_name'] ?? item['firstName'];
                    final lName = item['last_name'] ?? item['lastName'];
                    if (fName != null || lName != null) {
                      name = "${fName ?? ''} ${lName ?? ''}".trim();
                    } else {
                      name = item['name'] ?? item['client_name'] ?? item['username'] ?? item['client_email'] ?? item['email'] ?? 'Client';
                    }
                    final bool isActive = item['ui_status'] == 'ACCEPTED';
                    final bool hasRoutine = item['has_routine'] == true || item['routine'] != null || item['routine_id'] != null || (item['routines'] != null && (item['routines'] as List).isNotEmpty);
                    
                    final String rawImg = (item['profile_image'] ?? item['client_image'] ?? item['image'] ?? '').toString().trim();
                    final String imgUrl = (rawImg.length > 6 && rawImg != 'string' && rawImg != 'null') ? rawImg : 'assets/image/David Park.png';

                    return ClientCard(
                      name: name,
                      imageUrl: imgUrl,
                      isActive: isActive,
                      hasRoutine: hasRoutine,
                      onEditRoutine: () {
                        Get.toNamed(AppRoutes.editroutine, arguments: {
                          'id': item['client_id'] ?? item['client_email'] ?? item['email'] ?? item['id'] ?? '',
                          'name': name,
                          'imageUrl': imgUrl,
                          'isCreate': !hasRoutine,
                        });
                      },
                      onDelete: () {
                        // Delete logic if needed
                      },
                    );
                  }).toList(),
                );
              }),




              //==========================invite new client=============================================

              SizedBox(height: 30,),

              CustomIconButton(
                title: "Invite New Client", 
                iconPath: "assets/image/Container (7).png", 
                onTap: () {
                  Get.toNamed(AppRoutes.addnewclient);
                },
              ),

              SizedBox(height: 30,),







            ],
          ),
        ),
      ),

    );
  }
}
