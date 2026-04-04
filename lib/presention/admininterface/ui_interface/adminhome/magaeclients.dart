import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/widget/clientcard.dart';

import 'homewidget/Customadminbutton.dart';
import 'homewidget/ManageClientsHeader.dart';

class Magaeclients extends StatelessWidget {
  const Magaeclients({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,


            children: [

              SizedBox(height: 70,),

              //=================================ManageClientsHeader====================================================

               ManageClientsHeader(),


              SizedBox(height: 20,),

              Text("ALL CLIENTS (7)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff9CA3AF)),),


              SizedBox(height: 10,),

              //=====================================active&pendingcard================================================



              // Clientcard(name: "Sarah Jenkins", imageUrl: "assets/image/Elena Rodriguez.png", isActive: true, onEditRoutine: (){}, onDelete: (){}),
              ClientCard(name: "Marcus Chen", imageUrl: "assets/image/David Park.png", isActive: false, onEditRoutine: (){
                Get.toNamed(AppRoutes.editroutine);
              }, onDelete: (){}),
              ClientCard(name: "Sarah Jenkins", imageUrl: "assets/image/Elena Rodriguez.png", isActive: true, onEditRoutine: (){
                Get.toNamed(AppRoutes.editroutine);

              }, onDelete: (){

              }),

              ClientCard(name: "Elena Rodriguez", imageUrl: "assets/image/Sarah.png", isActive: false, onEditRoutine: (){
                Get.toNamed(AppRoutes.editroutine);

              }, onDelete: (){

              }),
              ClientCard(name: "Sarah Jenkins", imageUrl: "assets/image/Elena Rodriguez.png", isActive: true, onEditRoutine: (){
                Get.toNamed(AppRoutes.editroutine);

              }, onDelete: (){

              }),
              ClientCard(name: "Sarah Jenkins", imageUrl: "assets/image/Elena Rodriguez.png", isActive: true, onEditRoutine: (){
                Get.toNamed(AppRoutes.editroutine);

              }, onDelete: (){

              }),




              //==========================invite new client=============================================

              SizedBox(height: 30,),

              CustomIconButton(title: "Invite New Client", iconPath: "assets/image/Container (7).png", onTap: (){}),

              SizedBox(height: 30,),







            ],
          ),
        ),
      ),

    );
  }
}
