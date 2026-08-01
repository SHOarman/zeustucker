import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';
import 'auth_base_state_mixin.dart';

mixin AuthPasswordMixin on AuthBaseStateMixin {
  //====================================forgot password===================================================

  Future<void> forgotPassword({required String email}) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
      };

      print("Forgot Password API Request: POST ${ApiServices.forgot_password}");
      print("Forgot Password Payload: ${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.forgot_password);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Forgot Password Response Status: ${response.statusCode}");
      print("Forgot Password Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        isForgotPasswordFlow = true;
        registeredEmail.value = email;

        try {
          final Map<String, dynamic> resData = jsonDecode(response.body);
          final otpCode = resData['code'] ?? resData['otp'] ?? resData['reset_code'] ?? resData['verification_code'] ?? resData['message'];
          debugPrint("\n\n");
          debugPrint("====================================================");
          debugPrint("🔑     FORGOT PASSWORD RESET CODE (OTP): $otpCode");
          debugPrint("       TARGET EMAIL: $email");
          debugPrint("====================================================");
          debugPrint("\n\n");
        } catch (_) {}

        Get.snackbar('Success', 'Password reset code sent', backgroundColor: Colors.green, colorText: Colors.white);
        Get.toNamed(AppRoutes.createNewPassword);
      } else {
        Get.snackbar('Error', 'Failed to send reset code', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  //====================================reset password===================================================

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "code": code,
        "new_password": password,
        "confirm_password": confirmPassword,
      };

      print("Reset Password API Request: POST ${ApiServices.resutandconfrom_password}");
      print("Reset Password Payload: ${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.resutandconfrom_password);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Reset Password Response Status: ${response.statusCode}");
      print("Reset Password Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Password reset successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(AppRoutes.login);
      } else {
        String errorMessage = 'Password reset failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (_) {}
        Get.snackbar('Error', errorMessage, backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'Something went wrong: $e', backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
