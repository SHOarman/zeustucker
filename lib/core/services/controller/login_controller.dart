import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Usernamecontroller = TextEditingController();

  // ==============================Create New Password=========================
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final agreeToTerms = false.obs;
  final isLoading = false.obs;

  // ========================onlodaing============================
  final profileImagePath = Rxn<String>();
  final useForRegeneration = true.obs;
  final _picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      profileImagePath.value = image.path;
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      profileImagePath.value = image.path;
    }
  }

  void toggleUseForRegeneration() {
    useForRegeneration.value = !useForRegeneration.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void toggleTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  void submitNewPassword() {

  }

  //===============daycontroller===================================================
  // final Usernamecontroller = TextEditingController();

  var selectedDay = "".obs;
  var selectedMonth = "".obs;
  var selectedYear = "".obs;

  final List<String> days = List.generate(
    31,
    (index) => (index + 1).toString(),
  );
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  final List<String> years = List.generate(
    100,
    (index) => (DateTime.now().year - index).toString(),
  );
}
