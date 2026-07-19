import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/api_services.dart';
import '../../routes/app_routes.dart';

class UpdatePasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> updatePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'All fields are required.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Validation Error',
        'New password and confirm password do not match.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Validation Error',
        'New password must be at least 6 characters.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found. Please log in again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final url = Uri.parse(ApiServices.updateCoachPassword);
      final body = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      print("Update Password Request: PATCH $url");
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("Update Password Response Status: ${response.statusCode}");
      print("Update Password Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        String msg = "Password updated successfully";
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['message'] != null) {
            msg = responseData['message'];
          }
        } catch (_) {}

        Get.snackbar(
          'Success',
          msg,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Clear fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate to Admin Home
        Get.offAllNamed(AppRoutes.adminhome);
      } else {
        String errorMessage = 'Failed to update password';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
