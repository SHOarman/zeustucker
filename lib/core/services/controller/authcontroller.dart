import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/api_services.dart';

class Authcontroller extends GetxController {
  var isLoading = false.obs;
  var selectedRole = 'user'.obs;
  var registeredEmail = ''.obs;
  final roleController = TextEditingController(text: 'user');

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
        "date_of_birth": dateOfBirth,
        "role": role,
      };

      print("Registration Payload: \${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.reg);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status: \${response.statusCode}");
      print("Response Body: \${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('role', role);
        await prefs.setString('registered_email', email); // Save email for verify
        registeredEmail.value = email;
        
        try {
          final data = jsonDecode(response.body);
          if (data['token'] != null) {
            await prefs.setString('auth_token', data['token']);
          }
        } catch (_) {}

        Get.snackbar('Success', 'Registration successful', backgroundColor: Colors.green, colorText: Colors.white);
        
        Get.toNamed('/verifyEmail');
      } else {
        Get.snackbar('Error', 'Registration failed: \${response.statusCode}', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  //====================================verfiyemila===================================================

  Future<void> verifyEmail({required String email, required String code}) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "code": code,
      };

      print("Verify Email Payload: \${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.verifyemail);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Verify Response Status: \${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Email verified successfully', backgroundColor: Colors.green, colorText: Colors.white);
        // Navigate to login or home
        Get.offAllNamed('/login'); // Use actual route
      } else {
        Get.snackbar('Error', 'Verification failed', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', backgroundColor: Colors.red, colorText: Colors.white);
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

      print("Login Payload: \${jsonEncode(requestBody)}");

      final url = Uri.parse(ApiServices.login);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Login Response Status: \${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        try {
          final data = jsonDecode(response.body);
          if (data['token'] != null) {
            await prefs.setString('auth_token', data['token']);
          }
        } catch (_) {}
        Get.snackbar('Success', 'Login successful', backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed('/home'); // Assuming /home is the route
      } else {
        Get.snackbar('Error', 'Login failed', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}