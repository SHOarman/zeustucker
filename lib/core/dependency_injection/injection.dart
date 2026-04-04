import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/clientcontoller.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';
import 'package:zeustucker/core/services/controller/login_controller.dart';
import 'package:zeustucker/core/services/controller/profilecontroller.dart';

import '../services/controller/macro_controller.dart';

class DependencyInjection {
  static void bindings() {

    Get.lazyPut(()=>LoginController());
    //==========home controller=============================
    Get.lazyPut(()=>HomeController());

    //======================macro controller===========================
    Get.lazyPut(()=>MacroController());

    //========================profilecontroller===============
    Get.lazyPut(()=>EditProfileController());
    
    
    
    
    
    //=========================adminpenlcontroller===============================
    Get.lazyPut(()=>ClientController());
  }
}
