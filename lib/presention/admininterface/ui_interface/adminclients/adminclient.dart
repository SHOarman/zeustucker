import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/widget/add_user_button.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';
import 'widget/clientprogresscard.dart';
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

              Obx(() => ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.clientList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var client = controller.clientList[index];
                  return ClientProgressCard(
                    name: client['name'],
                    imageUrl: client['image'],
                    progress: client['progress'],
                    hasNotification: client['hasNotification'],
                    onTap: () {
                      Get.toNamed(AppRoutes.clientdetails, arguments: client);
                    },
                  );
                },
              )),

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