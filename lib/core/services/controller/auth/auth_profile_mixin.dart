import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_services/api_services.dart';
import 'auth_base_state_mixin.dart';

mixin AuthProfileMixin on AuthBaseStateMixin {
  Future<void> fetchAndSaveProfile() async {
    final data = await getSelfProfile();
    if (data != null) {
      profileData.value = data;
    }
  }

  //====================================get self profile===================================================

  Future<Map<String, dynamic>?> getSelfProfile() async {
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
        );
        return null;
      }

      final url = Uri.parse(ApiServices.getProfile);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final String safeBody = response.body.length > 300 ? "${response.body.substring(0, 300)}...[truncated]" : response.body;
      print("Get Profile Response Status: ${response.statusCode}");
      print("Get Profile Response Body: $safeBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final profileId = data['id'] ?? data['user_id'] ?? data['user']?['id'] ?? data['uid'];
        if (profileId != null) {
          await prefs.setString('user_id', profileId.toString());
        }
        print("\n================ SELF PROFILE DATA FROM SERVER ================");
        print("Gender: ${data['gender']}");
        print("Occupation: ${data['occupation'] ?? data['profession']}");
        print("Fitness Goal: ${data['fitness_goal']}");
        print("Wake Up Time: ${data['wake_up_time']}");
        print("Bed Time: ${data['bed_time']}");
        print("Height: ${data['height']}");
        print("Weight: ${data['weight']}");
        print("Target Weight: ${data['target_weight']}");
        print("Fitness Motivation: ${data['fitness_motivation']}");
        print("Profile Image: ${data['profile_image']}");
        print("Reference Image: ${data['reference_image']}");
        print("Short Bio: ${data['short_bio'] ?? data['bio']}");
        print("================================================================\n");
        return data;
      } else {
        print("Failed to load profile settings: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting self profile: $e");
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  //====================================update self profile settings========================================

  Future<bool> updateSelfProfileSettings({
    String? name,
    String? dateOfBirth,
    String? bio,
    String? profileImage,
    String? referenceImage,
    bool? useReferenceImage,
  }) async {
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
        );
        return false;
      }

      final String updateUrlStr = ApiServices.updateSelfProfile;
      final url = Uri.parse(updateUrlStr);

      final Map<String, dynamic> jsonBody = {};
      if (name != null && name.isNotEmpty) jsonBody['name'] = name;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) jsonBody['date_of_birth'] = dateOfBirth;
      if (bio != null && bio.isNotEmpty) {
        jsonBody['bio'] = bio;
        jsonBody['short_bio'] = bio;
      }
      if (useReferenceImage != null) jsonBody['use_reference_image'] = useReferenceImage;

      // Process profileImage to Base64 (Data URI format)
      if (profileImage != null && profileImage.isNotEmpty && profileImage != 'base64') {
        String val = profileImage;
        if (!kIsWeb && File(val.replaceFirst('file://', '')).existsSync()) {
          final bytes = await File(val.replaceFirst('file://', '')).readAsBytes();
          val = base64Encode(bytes);
        }
        if (!val.startsWith('data:') && !val.startsWith('http')) {
          val = 'data:image/jpeg;base64,$val';
        }
        jsonBody['profile_image'] = val;
      }

      // Process referenceImage to Base64 (Data URI format)
      if (referenceImage != null && referenceImage.isNotEmpty && referenceImage != 'base64') {
        String val = referenceImage;
        if (!kIsWeb && File(val.replaceFirst('file://', '')).existsSync()) {
          final bytes = await File(val.replaceFirst('file://', '')).readAsBytes();
          val = base64Encode(bytes);
        }
        if (!val.startsWith('data:') && !val.startsWith('http')) {
          val = 'data:image/jpeg;base64,$val';
        }
        jsonBody['reference_image'] = val;
      }

      final logBody = Map<String, dynamic>.from(jsonBody);
      if (logBody['profile_image'] != null) logBody['profile_image'] = "...[base64 profile image truncated]...";
      if (logBody['reference_image'] != null) logBody['reference_image'] = "...[base64 reference image truncated]...";

      print("Update Profile Settings Request (JSON): PATCH $url");
      print("Payload: ${jsonEncode(logBody)}");

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(jsonBody),
      );

      final String safeBody = response.body.length > 300 ? "${response.body.substring(0, 300)}...[truncated]" : response.body;
      print("Update Profile Settings Response Status: ${response.statusCode}");
      print("Update Profile Settings Response Body: $safeBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }

      // Format fallback: try plain Base64 without data URI prefix if 400 or 422 error
      if (response.statusCode == 400 || response.statusCode == 422) {
        bool modified = false;
        if (jsonBody['profile_image'] != null && jsonBody['profile_image'].toString().startsWith('data:')) {
          jsonBody['profile_image'] = jsonBody['profile_image'].toString().split(',').last;
          modified = true;
        }
        if (jsonBody['reference_image'] != null && jsonBody['reference_image'].toString().startsWith('data:')) {
          jsonBody['reference_image'] = jsonBody['reference_image'].toString().split(',').last;
          modified = true;
        }

        if (modified) {
          print("Retrying JSON PATCH with plain Base64 (without Data URI prefix)...");
          final retryResponse = await http.patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(jsonBody),
          );

          final String safeRetryBody = retryResponse.body.length > 300 ? "${retryResponse.body.substring(0, 300)}...[truncated]" : retryResponse.body;
          print("Retry Profile Settings Response Status: ${retryResponse.statusCode}");
          print("Retry Profile Settings Response Body: $safeRetryBody");

          if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
            Get.snackbar(
              'Success',
              'Profile updated successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            return true;
          }
        }
      }

      String errorMessage = 'Failed to update profile';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (_) {}
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    return false;
  }
}
