import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/adminsendrequestcontroller.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/clientcontoller.dart';
import 'package:zeustucker/core/services/controller/authcontroller.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';
import 'package:zeustucker/core/services/controller/login_controller.dart';
import 'package:zeustucker/core/services/controller/profilecontroller.dart';

import '../services/controller/macro_controller.dart';

import 'package:zeustucker/core/services/controller/storybook_controller.dart';

class DependencyInjection {
  static void bindings() {

    //===================authcontroller===========================================
    Get.lazyPut(()=>Authcontroller());

    Get.lazyPut(()=>LoginController());
    //==========home controller=============================
    // Controllers will be initialized with Get.put(..., permanent: true) in their respective screens
    // to prevent GetX from disposing them during Get.offAllNamed navigation.
    // Get.lazyPut(()=>HomeController(), fenix: true);
    // Get.lazyPut(()=>StorybookController(), fenix: true);

    //======================macro controller===========================
    // Get.lazyPut(()=>MacroController());

    //========================profilecontroller===============
    Get.lazyPut(()=>EditProfileController());
    
    
    
    
    
    //=========================adminpenlcontroller===============================
    Get.lazyPut(()=>ClientController());

    //============================request========================================

    Get.lazyPut(()=>Adminsendrequestcontroller());
  }
}
