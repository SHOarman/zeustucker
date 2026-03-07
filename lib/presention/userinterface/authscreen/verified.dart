import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custombutton.dart';

class Verified extends StatelessWidget {
  const Verified({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              SizedBox(height: 100),

              Center(
                child: Image.asset(
                  "assets/image/Group.png",
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: SvgPicture.asset(
                  "assets/icon/Frame (4).svg",
                  height: 48,
                  width: 48,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  "Verified",
                  style: TextStyle(
                    color: Color(0xff2D292E),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "You have successfully verified your account.",
                style: TextStyle(
                  color: Color(0xff2D292E),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              Custombutton(iconname: 'Login to your Account', ontap: (){
                Get.toNamed(AppRoutes.login);
              },),
            ],
          ),
        ),
      ),
    );
  }
}
