import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';
import '../login_controller.dart';
import 'auth_base_state_mixin.dart';

mixin AuthRegistrationMixin on AuthBaseStateMixin {
  Future<void> loadRegisteredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      registeredEmail.value = prefs.getString('registered_email') ?? '';
    } catch (_) {}
  }

  //================================register========================================================

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String dateOfBirth,
    required String role,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "username": username,
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
        "full_name": username,
        "role": role,
        "date_of_birth": dateOfBirth,
        "gender": null,
        "occupation": null,
        "fitness_goal": null,
        "profile_image": null,
        "reference_image": null,
      };

      print("Registration Payload: ${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.reg);
      final request = http.MultipartRequest('POST', url);
      requestBody.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('role', role);
        await prefs.setString('registered_email', email);
        await prefs.setString('full_name', username);
        await prefs.setString('dob', dateOfBirth);
        registeredEmail.value = email;
        try {
          final loginController = Get.put(LoginController());
          loginController.emailController.text = email;
          loginController.passwordController.clear();
        } catch (_) {}
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            final sendUrl = Uri.parse(ApiServices.emailsend);
            final sendResponse = await http.post(
              sendUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({"email": email}),
            );
            print("Send Verification Status: ${sendResponse.statusCode}");
            print("Send Verification Response: ${sendResponse.body}");

            if (sendResponse.statusCode == 200 || sendResponse.statusCode == 201) {
              final sendData = jsonDecode(sendResponse.body);
              final otpCode = sendData['otp'] ?? sendData['code'] ?? sendData['verification_code'];
              if (otpCode != null) {
                print("\n\n\n\n");
                print("====================================================");
                print("        EMAIL VERIFICATION CODE (OTP): $otpCode");
                print("====================================================");
                print("\n\n\n\n");
              }
            }
          } catch (e) {
            print("Error sending/getting verification code: $e");
          }
        });

        try {
          final data = jsonDecode(response.body);
          final token = data['token'] ?? data['access_token'] ?? data['access'];
          if (token != null) {
            await prefs.setString('auth_token', token);
          }
        } catch (_) {}

        Get.snackbar(
          'Success',
          'Registration successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.toNamed(AppRoutes.verifyEmail);
      } else {
        String errorMessage = 'Registration failed: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            if (errorData['detail'] is String) {
              errorMessage = errorData['detail'];
            } else if (errorData['detail'] is List) {
              errorMessage = errorData['detail'][0]['msg'] ?? errorMessage;
            }
          }
        } catch (_) {}
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //====================================verfiyemila===================================================

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {"email": email, "code": code};

      print("Verify Email Payload: ${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.emailverfy);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Verify Response Status: ${response.statusCode}");
      print("Verify Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("\n\n\n\n");
        print("====================================================");
        print("        EMAIL VERIFIED SUCCESSFULLY!");
        print("====================================================");
        print("\n\n\n\n");
        Get.snackbar(
          'Success',
          'Email verified successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (isForgotPasswordFlow) {
          forgotPasswordCode = code;
          isForgotPasswordFlow = false;
          Get.toNamed(AppRoutes.createNewPassword);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        String errorMessage = 'Verification failed';
        bool alreadyVerified = false;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
            if (errorMessage.toLowerCase().contains("already been used") ||
                errorMessage.toLowerCase().contains("already verified")) {
              alreadyVerified = true;
            }
          }
        } catch (_) {}

        if (alreadyVerified) {
          print("\n\n\n\n");
          print("====================================================");
          print("        EMAIL ALREADY VERIFIED!");
          print("====================================================");
          print("\n\n\n\n");
          Get.snackbar(
            'Success',
            'Email is already verified, redirecting to Login...',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAllNamed(AppRoutes.login);
        } else {
          Get.snackbar(
            'Error',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
