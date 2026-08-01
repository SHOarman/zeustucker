import 'package:get/get.dart';
import 'auth/auth_base_state_mixin.dart';
import 'auth/auth_registration_mixin.dart';
import 'auth/auth_login_mixin.dart';
import 'auth/auth_password_mixin.dart';
import 'auth/auth_onboarding_mixin.dart';
import 'auth/auth_profile_mixin.dart';

class Authcontroller extends GetxController
    with
        AuthBaseStateMixin,
        AuthRegistrationMixin,
        AuthLoginMixin,
        AuthPasswordMixin,
        AuthOnboardingMixin,
        AuthProfileMixin {
  @override
  void onInit() {
    super.onInit();
    loadRegisteredEmail();
  }
}