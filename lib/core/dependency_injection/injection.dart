import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/login_controller.dart';

class DependencyInjection {
  static void bindings() {

    Get.lazyPut(()=>LoginController());
  }
}
