import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';
import 'auth_base_state_mixin.dart';

mixin AuthOnboardingMixin on AuthBaseStateMixin {
  //==========================================onloading data with self==============================================

  Future<void> completeOnboarding({
    String? profileImagePath,
    String? userProfileImagePath,
    required bool useForRegeneration,
  }) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('email') ?? '';

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found. Please log in again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final savedFullName = prefs.getString('full_name');
      final savedDob = prefs.getString('dob');

      final url = Uri.parse(ApiServices.onboding_information);
      final request = http.MultipartRequest('PATCH', url);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['full_name'] = savedFullName ?? (tempFullName.isNotEmpty ? tempFullName : "User");
      request.fields['date_of_birth'] = savedDob ?? (tempDateOfBirth.isNotEmpty ? tempDateOfBirth : "2000-01-01");
      if (tempGender.isNotEmpty) request.fields['gender'] = tempGender;
      if (tempOccupation.isNotEmpty) {
        request.fields['occupation'] = tempOccupation;
        request.fields['profession'] = tempOccupation;
      }
      if (tempFitnessGoal.isNotEmpty) request.fields['fitness_goal'] = tempFitnessGoal;
      if (tempHeight.isNotEmpty) request.fields['height'] = tempHeight;
      if (tempWeight != null) request.fields['weight'] = tempWeight.toString();
      if (tempTargetWeight != null) request.fields['target_weight'] = tempTargetWeight.toString();
      if (tempBio.isNotEmpty) request.fields['short_bio'] = tempBio;
      if (tempWakeUpTime.isNotEmpty) request.fields['wake_up_time'] = tempWakeUpTime;
      if (tempBedTime.isNotEmpty) request.fields['bed_time'] = tempBedTime;
      if (tempFitnessMotivation.isNotEmpty) request.fields['fitness_motivation'] = tempFitnessMotivation;

      if (userProfileImagePath != null && userProfileImagePath.isNotEmpty) {
        try {
          if (kIsWeb) {
            final response = await http.get(Uri.parse(userProfileImagePath));
            String extension = userProfileImagePath.split('.').last.split('?').first.toLowerCase();
            String mimeType = 'image/jpeg';
            if (extension == 'png') {
              mimeType = 'image/png';
            } else if (extension == 'gif') {
              mimeType = 'image/gif';
            } else if (extension == 'webp') {
              mimeType = 'image/webp';
            } else if (extension == 'jpg' || extension == 'jpeg') {
              mimeType = 'image/jpeg';
            }

            request.files.add(
              http.MultipartFile.fromBytes(
                'profile_image',
                response.bodyBytes,
                filename: 'profile_image.$extension',
                contentType: MediaType.parse(mimeType),
              ),
            );
          } else {
            String cleanPath = userProfileImagePath;
            if (cleanPath.startsWith('file://')) {
              cleanPath = cleanPath.replaceFirst('file://', '');
            }
            final file = File(cleanPath);
            if (await file.exists()) {
              String extension = cleanPath.split('.').last.toLowerCase();
              String mimeType = 'image/jpeg';
              if (extension == 'png') {
                mimeType = 'image/png';
              } else if (extension == 'gif') {
                mimeType = 'image/gif';
              } else if (extension == 'webp') {
                mimeType = 'image/webp';
              } else if (extension == 'jpg' || extension == 'jpeg') {
                mimeType = 'image/jpeg';
              }

              request.files.add(
                await http.MultipartFile.fromPath(
                  'profile_image',
                  cleanPath,
                  contentType: MediaType.parse(mimeType),
                ),
              );
            } else {
              print("Onboarding: Profile image file does not exist at path: $cleanPath");
            }
          }
        } catch (e) {
          print("Error adding profile image to request: $e");
        }
      }

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        try {
          if (kIsWeb) {
            final response = await http.get(Uri.parse(profileImagePath));
            String extension = profileImagePath.split('.').last.split('?').first.toLowerCase();
            String mimeType = 'image/jpeg';
            if (extension == 'png') {
              mimeType = 'image/png';
            } else if (extension == 'gif') {
              mimeType = 'image/gif';
            } else if (extension == 'webp') {
              mimeType = 'image/webp';
            } else if (extension == 'jpg' || extension == 'jpeg') {
              mimeType = 'image/jpeg';
            }

            request.files.add(
              http.MultipartFile.fromBytes(
                'reference_image',
                response.bodyBytes,
                filename: 'reference_image.$extension',
                contentType: MediaType.parse(mimeType),
              ),
            );
          } else {
            String cleanPath = profileImagePath;
            if (cleanPath.startsWith('file://')) {
              cleanPath = cleanPath.replaceFirst('file://', '');
            }
            final file = File(cleanPath);
            if (await file.exists()) {
              String extension = cleanPath.split('.').last.toLowerCase();
              String mimeType = 'image/jpeg';
              if (extension == 'png') {
                mimeType = 'image/png';
              } else if (extension == 'gif') {
                mimeType = 'image/gif';
              } else if (extension == 'webp') {
                mimeType = 'image/webp';
              } else if (extension == 'jpg' || extension == 'jpeg') {
                mimeType = 'image/jpeg';
              }

              request.files.add(
                await http.MultipartFile.fromPath(
                  'reference_image',
                  cleanPath,
                  contentType: MediaType.parse(mimeType),
                ),
              );
            } else {
              print("Onboarding: File does not exist at path: $cleanPath");
            }
          }
        } catch (e) {
          print("Error adding reference image to request: $e");
        }
      }

      print("Onboarding Request: PATCH ${ApiServices.onboding_information}");
      print("Onboarding Fields: ${request.fields}");
      print("Onboarding Files: ${request.files.map((f) => '${f.field}: ${f.filename}')}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Onboarding Response Status: ${response.statusCode}");
      print("Onboarding Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final resData = jsonDecode(response.body);
          final userGender = resData['user']?['gender'] ?? resData['gender'];
          if (userGender != null) {
            await prefs.setString('user_gender', userGender.toString());
          }
        } catch (e) {
          print("Failed to save gender: $e");
        }

        if (tempOccupation.isNotEmpty) {
          try {
            print("Sending settings patch request for occupation: $tempOccupation");
            final settingsUrl = Uri.parse(ApiServices.getProfile);
            final settingsResponse = await http.patch(
              settingsUrl,
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'occupation': tempOccupation,
                'profession': tempOccupation,
              }),
            );
            print("Settings response status (occupation update): ${settingsResponse.statusCode}");
            print("Settings response body (occupation update): ${settingsResponse.body}");
          } catch (e) {
            print("Failed to save occupation settings: $e");
          }
        }

        if (email.isNotEmpty) {
          await prefs.setBool('onboarded_$email', true);
        }
        Get.snackbar(
          'Success',
          'Onboarding completed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.home);
      } else {
        String errorMessage = 'Onboarding failed';
        bool isEmptyFieldsError = false;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
            if (errorMessage.toLowerCase().contains("no registration information fields")) {
              isEmptyFieldsError = true;
            }
          }
        } catch (_) {}

        if (isEmptyFieldsError) {
          if (email.isNotEmpty) {
            await prefs.setBool('onboarded_$email', true);
          }
          Get.snackbar(
            'Success',
            'Onboarding completed',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar(
            'Error (${response.statusCode})',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
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
