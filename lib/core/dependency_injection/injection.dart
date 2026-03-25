import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';
import 'package:zeustucker/core/services/controller/login_controller.dart';

import '../services/controller/macro_controller.dart';

class DependencyInjection {
  static void bindings() {

    Get.lazyPut(()=>LoginController());
    //==========home controller=============================
    Get.lazyPut(()=>HomeController());

    //======================macro controller===========================
    Get.lazyPut(()=>MacroController());
  }
}
