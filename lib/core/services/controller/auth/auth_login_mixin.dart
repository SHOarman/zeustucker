import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';
import 'auth_base_state_mixin.dart';

mixin AuthLoginMixin on AuthBaseStateMixin {
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
      ).timeout(const Duration(seconds: 30));

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
        await prefs.setString('email', email);

        String role = 'SELF';
        bool hasOnboarded = false;

        if (token != null) {
          try {
            final profileUrl = Uri.parse(ApiServices.getProfile);
            final profileResponse = await http.get(
              profileUrl,
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ).timeout(const Duration(seconds: 30));
            print("Login Profile Fetch Response Status: ${profileResponse.statusCode}");
            print("Login Profile Fetch Response Body: ${profileResponse.body}");

            if (profileResponse.statusCode == 200 || profileResponse.statusCode == 201) {
              final profileData = jsonDecode(profileResponse.body);
              if (profileData['role'] != null) {
                role = profileData['role'];
              }
              if (profileData['name'] != null) {
                await prefs.setString('full_name', profileData['name'].toString());
              }
              if (profileData['date_of_birth'] != null) {
                await prefs.setString('dob', profileData['date_of_birth'].toString());
              }
              final profileId = profileData['id'] ?? profileData['user_id'] ?? profileData['user']?['id'] ?? profileData['uid'];
              if (profileId != null) {
                await prefs.setString('user_id', profileId.toString());
                debugPrint("Saved user_id from profile response during login: $profileId");
              }

              bool isFieldPopulated(dynamic val) {
                if (val == null) return false;
                final str = val.toString().trim();
                return str.isNotEmpty && str.toLowerCase() != 'string' && str != '0';
              }

              final goal = profileData['fitness_goal'];
              final gender = profileData['gender'];
              final height = profileData['height'];
              final weight = profileData['weight'];
              final targetWeight = profileData['target_weight'];
              final bio = profileData['short_bio'] ?? profileData['bio'];
              final refImg = profileData['reference_image'];

              if (isFieldPopulated(goal) ||
                  isFieldPopulated(gender) ||
                  isFieldPopulated(height) ||
                  isFieldPopulated(weight) ||
                  isFieldPopulated(targetWeight) ||
                  isFieldPopulated(bio) ||
                  isFieldPopulated(refImg)) {
                hasOnboarded = true;
              }
            }
          } catch (e) {
            print("Error fetching profile during login: $e");
          }
        }
        await prefs.setString('role', role);

        final localOnboarded = prefs.getBool('onboarded_$email') ?? false;
        if (localOnboarded) {
          hasOnboarded = true;
        }

        if (hasOnboarded) {
          await prefs.setBool('onboarded_$email', true);
        }

        Get.snackbar(
          'Success',
          'Login successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final cleanRole = role.trim().toUpperCase();
        print("\n\n\n\n");
        print("====================================================");
        print("        USER LOGGED IN SUCCESSFULLY!");
        print("        Role: $cleanRole");
        print("        Onboarded: $hasOnboarded");
        print("====================================================");
        print("\n\n\n\n");
        print("Logged in user role (normalized): $cleanRole, Has completed onboarding: $hasOnboarded");

        if (cleanRole == 'COACH') {
          print("Routing coach (COACH) to Admin Home (adminhome)");
          Get.offAllNamed(AppRoutes.adminhome);
        } else {
          if (hasOnboarded) {
            print("Routing onboarded user to Home (home)");
            Get.offAllNamed(AppRoutes.home);
          } else {
            print("Routing new user to Onboarding (onloading1)");
            Get.offAllNamed(AppRoutes.onloading1);
          }
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
}
