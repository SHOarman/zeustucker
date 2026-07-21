import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

import '../api_services/api_services.dart';
import '../../routes/app_routes.dart';

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
  final bioController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final selectedImagePath = ''.obs;
  final selectedGender = ''.obs;
  final dob = ''.obs;
  final age = 0.obs;

  var coachRequests = <Map<String, dynamic>>[].obs;
  var isRequestsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileIntoControllers();
    fetchCoachRequests();
  }

  Future<void> loadProfileIntoControllers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getSelfProfile();
    if (data != null) {
      profileData.value = data;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      professionController.text = data['occupation'] ?? '';
      bioController.text = data['bio'] ?? data['short_bio'] ?? '';
      phoneNumberController.text = data['phone_number'] ?? data['phone'] ?? '';
      
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
      
      final g = data['gender'] ?? prefs.getString('user_gender');
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
      final String role = profileData['role'] ?? '';
      bool success;

      if (role.toUpperCase() == 'COACH') {
        success = await updateCoachProfileSettings(
          name: nameController.text,
          bio: bioController.text,
          phoneNumber: phoneNumberController.text,
          profileImagePath: selectedImagePath.value,
        );
      } else {
        String? base64Img;
        if (selectedImagePath.value.isNotEmpty && selectedImagePath.value != "base64") {
          if (kIsWeb) {
            final response = await http.get(Uri.parse(selectedImagePath.value));
            base64Img = base64Encode(response.bodyBytes);
          } else {
            final bytes = await File(selectedImagePath.value).readAsBytes();
            base64Img = base64Encode(bytes);
          }
        }

        success = await updateSelfProfileSettings(
          name: nameController.text,
          dateOfBirth: dob.value,
          gender: selectedGender.value,
          occupation: professionController.text,
          bio: bioController.text,
          profileImage: base64Img,
        );
      }
      
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        if (selectedGender.value.isNotEmpty) {
          await prefs.setString('user_gender', selectedGender.value);
        }
        await fetchAndSaveProfile();
        Get.snackbar("Success", "Profile Updated Successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
        
        if (role.toUpperCase() == 'SELF') {
          Get.offAllNamed(AppRoutes.profile);
        } else {
          Get.offAllNamed(AppRoutes.adminsettings);
        }
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
        print("Reference Image (Length): ${data['reference_image']?.toString().length ?? 0}");
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

  Future<bool> updateSelfProfileSettings({
    String? name,
    String? dateOfBirth,
    String? gender,
    String? occupation,
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
      if (gender != null) requestBody['gender'] = gender;
      if (occupation != null) {
        requestBody['occupation'] = occupation;
        requestBody['profession'] = occupation;
      }
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
      print("Update Profile Settings Request: PATCH ${ApiServices.updateSelfProfile}");
      print("Update Profile Settings Payload: ${jsonEncode(logBody)}");

      final url = Uri.parse(ApiServices.updateSelfProfile);
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

  Future<bool> updateCoachProfileSettings({
    required String name,
    required String bio,
    required String phoneNumber,
    String? profileImagePath,
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

      final url = Uri.parse(ApiServices.updateCoachProfile);
      final request = http.MultipartRequest('PATCH', url);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['bio'] = bio;
      request.fields['phone_number'] = phoneNumber;

      if (profileImagePath != null && profileImagePath.isNotEmpty && profileImagePath != "base64") {
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
              }
              request.files.add(
                await http.MultipartFile.fromPath(
                  'profile_image',
                  cleanPath,
                  contentType: MediaType.parse(mimeType),
                ),
              );
            }
          }
        } catch (e) {
          print("Error adding coach profile image to request: $e");
        }
      }

      print("Coach Settings Request: PATCH $url");
      print("Coach Settings Fields: ${request.fields}");
      print("Coach Settings Files: ${request.files.map((f) => '${f.field}: ${f.filename}')}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Coach Settings Response Status: ${response.statusCode}");
      print("Coach Settings Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMessage = 'Failed to update coach settings';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
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
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
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

  Future<void> logout() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final url = Uri.parse(ApiServices.logout);
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print("Logout Response Status: ${response.statusCode}");
        print("Logout Response Body: ${response.body}");
      }
      
      await prefs.clear();
      
      Get.snackbar("Success", "Logged out successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
      
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print("Error logging out: $e");
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final url = Uri.parse(ApiServices.deleteAccount);
        final response = await http.delete(
          url,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        );
        print("Delete Account Response Status: ${response.statusCode}");
        print("Delete Account Response Body: ${response.body}");
      }
      
      await prefs.clear();
      
      Get.snackbar("Success", "Account deleted successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
      
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print("Error deleting account: $e");
      Get.snackbar("Error", "Failed to delete account: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCoachRequests() async {
    isRequestsLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final role = (profileData['role'] ?? prefs.getString('role') ?? '').toString().toUpperCase();
      if (role == 'COACH') {
        // GET /coach/client-requests is reserved for SELF (client) users to view pending requests sent by coaches.
        coachRequests.clear();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiServices.coachClientRequests),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint("Get Coach Requests Status: ${response.statusCode}");
      debugPrint("Get Coach Requests Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        coachRequests.value = List<Map<String, dynamic>>.from(data);
      } else {
        coachRequests.clear();
      }
    } catch (e) {
      debugPrint("Error fetching coach requests: $e");
    } finally {
      isRequestsLoading.value = false;
    }
  }

  Future<bool> acceptCoachRequest(String requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = ApiServices.acceptClientRequest(requestId);
      debugPrint(">>> API REQUEST: POST $url");
      debugPrint(">>> REQUEST HEADERS: Authorization: Bearer $token");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint("<<< API RESPONSE: ${response.statusCode}");
      debugPrint("<<< RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Request accepted successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchCoachRequests();
        return true;
      } else {
        Get.snackbar("Error", "Failed to accept request.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error accepting coach request: $e");
      Get.snackbar("Error", "Failed to accept request: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    return false;
  }

  Future<bool> declineCoachRequest(String requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = "${ApiServices.coachClientRequests}/$requestId";
      debugPrint(">>> API REQUEST (DELETE): DELETE $url");
      debugPrint(">>> REQUEST HEADERS: Authorization: Bearer $token");

      // Try DELETE first
      var response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      debugPrint("<<< API RESPONSE (DELETE): ${response.statusCode}");
      debugPrint("<<< RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Request declined.",
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchCoachRequests();
        return true;
      }

      // Try POST decline if DELETE fails
      if (response.statusCode == 404 || response.statusCode == 405) {
        final postUrl = "${ApiServices.coachClientRequests}/$requestId/decline";
        debugPrint(">>> API REQUEST (POST fallback): POST $postUrl");
        
        response = await http.post(
          Uri.parse(postUrl),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
        
        debugPrint("<<< API RESPONSE (POST fallback): ${response.statusCode}");
        debugPrint("<<< RESPONSE BODY: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 204) {
          Get.snackbar("Success", "Request declined.",
              backgroundColor: Colors.green, colorText: Colors.white);
          await fetchCoachRequests();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error declining coach request: $e");
    }
    // Fallback: local remove
    coachRequests.removeWhere((req) => req['id'] == requestId);
    Get.snackbar("Success", "Request declined.",
        backgroundColor: Colors.green, colorText: Colors.white);
    return true;
  }

  Future<void> pickAndUpdateImage(BuildContext context, bool isReferenceImage) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        bool success;
        if (isReferenceImage) {
          success = await updateSelfProfileSettings(referenceImage: base64Image);
        } else {
          success = await updateSelfProfileSettings(profileImage: base64Image);
        }
        
        if (success) {
          await fetchAndSaveProfile();
        }
      } catch (e) {
        debugPrint("Error picking/updating profile image: $e");
      }
    }
  }

  Future<void> updateName(String newName) async {
    if (newName.isNotEmpty) {
      final success = await updateSelfProfileSettings(name: newName);
      if (success) {
        await fetchAndSaveProfile();
      }
    }
  }
}