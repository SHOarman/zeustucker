import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../api_services/api_services.dart';

class Authcontroller extends GetxController {
  var isLoading = false.obs;
  var selectedRole = 'user'.obs;
  var registeredEmail = ''.obs;
  final roleController = TextEditingController(text: 'user');

  // Temporary storage for signup fields during onboarding flow (for SELF role)
  String tempFullName = '';
  String tempEmail = '';
  String tempPassword = '';
  String tempConfirmPassword = '';
  String tempDateOfBirth = '';
  String tempRole = '';

  // Onboarding step 2 fields
  String tempOccupation = '';
  String tempFitnessGoal = '';
  String tempBio = '';

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
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('role', role);
        await prefs.setString('registered_email', email);
        registeredEmail.value = email;

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
        Get.snackbar(
          'Success',
          'Email verified successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'Error',
          'Verification failed',
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

  //=================================login=================================================

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "password": password,
      };

      print("Login Payload: ${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.login);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Login Response Status: ${response.statusCode}");
      print("Login Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        String? token;
        try {
          final data = jsonDecode(response.body);
          token = data['access_token'] ?? data['token'] ?? data['access'];
          if (token != null) {
            await prefs.setString('auth_token', token);
          }
        } catch (e) {
          print("Error parsing token: $e");
        }

        // Default or from response
        String role = 'SELF';
        try {
          final data = jsonDecode(response.body);
          if (data['user'] != null && data['user']['role'] != null) {
            role = data['user']['role'];
          }
        } catch (_) {}
        await prefs.setString('role', role);

        Get.snackbar(
          'Success',
          'Login successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final cleanRole = role.trim().toUpperCase();
        print("Logged in user role (normalized): $cleanRole");

        if (cleanRole == 'COACH') {
          print("Routing coach (COACH) to Admin Home (adminhome)");
          Get.offAllNamed(AppRoutes.adminhome);
        } else {
          print("Routing standard user (SELF/USER/fallback) to Home (home)");
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        Get.snackbar(
          'Error',
          'Login failed',
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
        registeredEmail.value = email;
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
        Get.snackbar('Success', 'Password reset successfully', backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(AppRoutes.login);
      } else {
        String errorMessage = 'Password reset failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (_) {}
        Get.snackbar('Error', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}