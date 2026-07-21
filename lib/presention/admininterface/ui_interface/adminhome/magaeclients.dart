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

              Obx(() {
                final acceptedList = controller.invitationList.where((item) {
                  final status = (item['ui_status'] ?? item['status'])?.toString().toUpperCase();
                  return status == 'ACCEPTED';
                }).toList();
                return Text(
                  "ALL CLIENTS (${acceptedList.length})",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff9CA3AF)),
                );
              }),

              const SizedBox(height: 10),

              //=====================================active card list================================================
              Obx(() {
                final acceptedList = controller.invitationList.where((item) {
                  final status = (item['ui_status'] ?? item['status'])?.toString().toUpperCase();
                  return status == 'ACCEPTED';
                }).toList();

                if (controller.isListLoading.value && acceptedList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (acceptedList.isEmpty) {
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
                  children: acceptedList.map((item) {
                    String name = 'Client';
                    final fName = item['first_name'] ?? item['firstName'];
                    final lName = item['last_name'] ?? item['lastName'];
                    if (fName != null || lName != null) {
                      name = "${fName ?? ''} ${lName ?? ''}".trim();
                    } else {
                      name = item['name'] ?? item['client_name'] ?? item['username'] ?? item['client_email'] ?? item['email'] ?? 'Client';
                    }
                    final bool isActive = (item['ui_status'] ?? item['status'])?.toString().toUpperCase() == 'ACCEPTED';
                    final bool hasRoutine = item['has_routine'] == true || item['routine'] != null || item['routine_id'] != null || (item['routines'] != null && (item['routines'] as List).isNotEmpty);
                    
                    final String rawImg = (item['profile_image'] ?? item['client_image'] ?? item['image'] ?? '').toString().trim();
                    final String imgUrl = (rawImg.length > 6 && rawImg != 'string' && rawImg != 'null') ? rawImg : 'assets/image/David Park.png';

                    return ClientCard(
                      name: name,
                      imageUrl: imgUrl,
                      isActive: isActive,
                      hasRoutine: hasRoutine,
                      onEditRoutine: () {
                        final String clientUuid = (item['client_id'] ?? item['client_uuid'] ?? item['user_id'] ?? item['id'] ?? '').toString().trim();
                        debugPrint("Navigating to editroutine for client: $name, clientUuid: $clientUuid");
                        Get.toNamed(AppRoutes.editroutine, arguments: {
                          'id': clientUuid,
                          'name': name,
                          'imageUrl': imgUrl,
                          'isCreate': !hasRoutine,
                        });
                      },
                      onDelete: () {
                        final String clientUuid = (item['client_id'] ?? item['id'] ?? '').toString();
                        if (clientUuid.isNotEmpty && clientUuid != 'string' && clientUuid != 'null') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Warning Icon Circle
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEE2E2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Title
                                      const Text(
                                        "Remove Client",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Content Text
                                      const Text(
                                        "Are you sure you want to remove this client? This action will permanently delete their connection and routine.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF4B5563),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Buttons Row
                                      Row(
                                        children: [
                                          // Cancel Button
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(0xFF6B7280),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Delete Button
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  controller.deleteClient(clientUuid);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFEF4444),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Remove",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          Get.snackbar("Error", "Cannot remove client without ID.",
                              backgroundColor: Colors.red, colorText: Colors.white);
                        }
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
