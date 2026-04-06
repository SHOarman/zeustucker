import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/ClientCapacityCard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/resentaddprofile.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/tierBenefitsCard.dart';

import '../adminhome/homewidget/Customadminbutton.dart';

class Clientmanagementlimirs extends StatelessWidget {
  const Clientmanagementlimirs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 70,),

              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),

                   Center(
                     child: Text(
                      "CLIENT LIMITS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: -0.5,
                      ),
                                       ),
                   ),
                ],
              ),

              SizedBox(height: 20,),

              //====================================client capacity==================================================================

              Center(
                child: ClientCapacityCard(
                  usedClients: 7,
                  totalClients: 10,
                  // Pass the explicit icon image here (from image_1.png style)
                  // I am using a placeholder network image, replace with your asset path
                  cornerImage: 'assets/icon/Icon (15).png',
                ),
              ),

              SizedBox(height: 20,),

              //===========================================TierBenefitsCard=================================================================


              TierBenefitsCard(),

              SizedBox(height: 20,),

              CustomIconButton(title: "Upgrade to Pro", iconPath: "assets/icon/Icon (17).png", onTap: (){
                Get.back();
              }),

              SizedBox(height: 20,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text("RECENT ADDED CLIENTS",style: TextStyle(color: Color(0xff9CA3AF),fontSize: 14,fontWeight: FontWeight.w700,letterSpacing: 1.5),),
                  
                  SizedBox(width: 10,),
                  TextButton(onPressed: (){}, child: Text("View Roster",style: TextStyle(color: Color(0xFF00A97D),fontSize: 14,fontWeight: FontWeight.w600),))

                ],
              ),

              SizedBox(height: 20,),

              Resentaddprofile(imageUrl: "assets/icon/Client.png", name: "Luna Sterling", status: "Added 2 days ago", onTap: (){}),
              Resentaddprofile(imageUrl: "assets/icon/Container (18).png", name: "Felix Arvid", status: "Added 4 days ago", onTap: (){}),
              SizedBox(height: 20,),












            ],
          ),
        ),
      ),
    );
  }
}
