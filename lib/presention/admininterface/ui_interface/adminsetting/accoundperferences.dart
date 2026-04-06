import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/AccountPreferencesWidget.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/CustomProfileCard.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/CustomSettingTile.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/widget/tierBenefitsCard.dart';

import '../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';
import '../adminhome/homewidget/Customadminbutton.dart';

class Accoundperferences extends StatelessWidget {
  const Accoundperferences({super.key});

  @override
  Widget build(BuildContext context) {
    ClientController clientController = Get.put(ClientController());
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 70,),
//==============================================AccountPreferencesCard ===========================================================
              AccountHeaderCard(),
              
              SizedBox(height: 30,),
              
              Text("PROFILE DETAILS",style: TextStyle(color: Color(0xff9CA3AF),fontSize: 14,fontWeight: FontWeight.w700,letterSpacing: 1.5),),
              SizedBox(height: 20,),


              //========================CustomProfileCard========================================================

              CustomProfileCard(
                label: "Full Name",
                value: clientController.userName,
              ),

              SizedBox(height: 15,),

              CustomProfileCard(
                label: "EMAIL ADDRESS",
                value: clientController.emailaddress,
              ),
              SizedBox(height: 15,),
              CustomProfileCard(
                label: "PHONE NUMBER",
                value: clientController.phonenumber,
              ),

              SizedBox(height: 30,),

              CustomProfileCard(
                label: "COACH BIOGRAPHY",
                value: clientController.coachbio,
              ),

              SizedBox(height: 20,),
              Text("PASSWORD & SECURITY",style: TextStyle(color: Color(0xff9CA3AF),fontSize: 14,fontWeight: FontWeight.w700,letterSpacing: 1.5),),
              SizedBox(height: 10,),
              CustomSettingTile(
                imagePath: 'assets/icon/Container (13).png',
                title: 'Update Password',
                onTap: () {},
              ),
              SizedBox(height: 20,),

              CustomIconButton(title: "Save Changes", iconPath: "assets/icon/Container (15).png", onTap: (){
                Get.back();
              }),
              SizedBox(height: 20,),


              //============================================tierBenefitscard=================================================================






            ],
          ),
        ),
      ),
    );
  }
}
