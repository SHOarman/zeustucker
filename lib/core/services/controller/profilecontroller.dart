import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_services/api_services.dart';

// ===============================================================
// PROFILE CONTROLLER
// ===============================================================
class EditProfileController extends GetxController {
  final profileData = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  //==================================Profile CONTROLLER FIELDS===========================
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final professionController = TextEditingController();

  final selectedImagePath = ''.obs;
  final selectedGender = ''.obs;
  final dob = ''.obs;
  final age = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileIntoControllers();
  }

  Future<void> loadProfileIntoControllers() async {
    final data = await getSelfProfile();
    if (data != null) {
      profileData.value = data;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      professionController.text = data['occupation'] ?? '';
      
      final dobStr = data['date_of_birth'];
      if (dobStr != null && dobStr.toString().isNotEmpty) {
        dob.value = dobStr.toString();
        // Calculate age
        try {
          final parts = dobStr.toString().split('-');
          if (parts.length == 3) {
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[2]);
            final birthDate = DateTime(year, month, day);
            int calculatedAge = DateTime.now().year - birthDate.year;
            if (DateTime.now().month < birthDate.month ||
                (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
              calculatedAge--;
            }
            age.value = calculatedAge;
          }
        } catch (_) {}
      }
      
      final g = data['gender'];
      if (g != null && g.toString().isNotEmpty) {
        selectedGender.value = g.toString();
      }
      
      final img = data['profile_image'];
      if (img != null && img.toString().isNotEmpty && img != 'string') {
        selectedImagePath.value = "base64"; // flag to show base64 image
      }
    }
  }

  Future<void> saveProfileChanges() async {
    isLoading.value = true;
    try {
      String? base64Img;
      if (selectedImagePath.value.isNotEmpty && selectedImagePath.value != "base64") {
        final bytes = await File(selectedImagePath.value).readAsBytes();
        base64Img = base64Encode(bytes);
      }
      
      final success = await updateSelfProfileSettings(
        name: nameController.text,
        dateOfBirth: dob.value,
        profileImage: base64Img,
      );
      
      if (success) {
        Get.snackbar("Success", "Profile Updated Successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAndSaveProfile() async {
    final data = await getSelfProfile();
    if (data != null) {
      profileData.value = data;
    }
  }

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

      print("Get Profile Response Status: ${response.statusCode}");
      print("Get Profile Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
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

      final Map<String, dynamic> requestBody = {};
      if (name != null) requestBody['name'] = name;
      if (dateOfBirth != null) requestBody['date_of_birth'] = dateOfBirth;
      if (bio != null) requestBody['bio'] = bio;
      if (profileImage != null) requestBody['profile_image'] = profileImage;
      if (referenceImage != null) requestBody['reference_image'] = referenceImage;
      if (useReferenceImage != null) requestBody['use_reference_image'] = useReferenceImage;

      final logBody = Map<String, dynamic>.from(requestBody);
      if (logBody['profile_image'] != null) {
        logBody['profile_image'] = "...[base64 profile image truncated]...";
      }
      if (logBody['reference_image'] != null) {
        logBody['reference_image'] = "...[base64 reference image truncated]...";
      }
      print("Update Profile Settings Request: PATCH ${ApiServices.updateProfileSettings}");
      print("Update Profile Settings Payload: ${jsonEncode(logBody)}");

      final url = Uri.parse(ApiServices.updateProfileSettings);
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("Update Profile Settings Response Status: ${response.statusCode}");
      print("Update Profile Settings Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
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
    return false;
  }

  //==================================Report PROBLEM CONTROLLER===========================
  var selectedCountry = "United States".obs;
  var selectedLanguage = "English (US)".obs;
  final List<String> countries = ["United States", "Bangladesh", "United Kingdom", "Canada", "Germany"];
  final List<String> languages = ["English (US)", "Bengali", "Spanish", "French", "German"];

  void updateCountry(String value) => selectedCountry.value = value;
  void updateLanguage(String value) => selectedLanguage.value = value;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
    }
  }

  Future<void> chooseDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 11, 12),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00A97D)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dob.value = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      int calculatedAge = DateTime.now().year - pickedDate.year;
      if (DateTime.now().month < pickedDate.month ||
          (DateTime.now().month == pickedDate.month && DateTime.now().day < pickedDate.day)) {
        calculatedAge--;
      }
      age.value = calculatedAge;
    }
  }

  void showGenderSelection(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  "Select Gender",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const Divider(height: 1),
            _buildGenderTile("Male"),
            _buildGenderTile("Female"),
            _buildGenderTile("Other"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderTile(String gender) {
    return ListTile(
      title: Text(
        gender,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
      ),
      onTap: () {
        selectedGender.value = gender;
        Get.back();
      },
    );
  }
}