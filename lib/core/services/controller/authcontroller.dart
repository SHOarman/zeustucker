import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../api_services/api_services.dart';
import './login_controller.dart';

class Authcontroller extends GetxController {
  var isLoading = false.obs;
  var selectedRole = 'user'.obs;
  var registeredEmail = ''.obs;
  final roleController = TextEditingController(text: 'user');

  @override
  void onInit() {
    super.onInit();
    _loadRegisteredEmail();
  }

  Future<void> _loadRegisteredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      registeredEmail.value = prefs.getString('registered_email') ?? '';
    } catch (_) {}
  }

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
  String tempGender = '';
  String tempHeight = '';
  int? tempWeight;
  int? tempTargetWeight;

  // OTP email verification controllers
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Onboarding screen 2 controllers and state
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final rxSelectedGoal = RxnString();
  final rxSelectedGender = RxnString();



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
      
      // Add all non-null fields to the multipart request
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

        // Call Send Verification Code API with a 2-second delay to prevent backend collisions
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

  bool isForgotPasswordFlow = false;
  String forgotPasswordCode = '';

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

        // Save email
        await prefs.setString('email', email);

        // Default or from response
        // Fetch User Profile in background using the token to get role and onboarding status
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
            );
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

  //==========================================onloading data with self==============================================

  Future<void> completeOnboarding({
    String? profileImagePath,
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

      String? base64Image;
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        try {
          if (kIsWeb) {
            final response = await http.get(Uri.parse(profileImagePath));
            base64Image = base64Encode(response.bodyBytes);
          } else {
            String cleanPath = profileImagePath;
            if (cleanPath.startsWith('file://')) {
              cleanPath = cleanPath.replaceFirst('file://', '');
            }
            final file = File(cleanPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              base64Image = base64Encode(bytes);
            } else {
              print("Onboarding: File does not exist at path: $cleanPath");
            }
          }
        } catch (e) {
          print("Error converting image to base64: $e");
        }
      }

      final savedFullName = prefs.getString('full_name');
      final savedDob = prefs.getString('dob');

      final Map<String, dynamic> requestBody = {};
      requestBody['full_name'] = savedFullName ?? (tempFullName.isNotEmpty ? tempFullName : "User");
      requestBody['date_of_birth'] = savedDob ?? (tempDateOfBirth.isNotEmpty ? tempDateOfBirth : "2000-01-01");
      
      if (tempGender.isNotEmpty) requestBody['gender'] = tempGender;
      if (tempFitnessGoal.isNotEmpty) requestBody['fitness_goal'] = tempFitnessGoal;
      if (tempHeight.isNotEmpty) requestBody['height'] = tempHeight;
      if (tempWeight != null) requestBody['weight'] = tempWeight;
      if (tempTargetWeight != null) requestBody['target_weight'] = tempTargetWeight;
      if (tempBio.isNotEmpty) requestBody['short_bio'] = tempBio;
      if (base64Image != null) requestBody['reference_image'] = base64Image;

      // Print clean log payload (truncating base64 images if present)
      final logBody = Map<String, dynamic>.from(requestBody);
      if (logBody['profile_image'] != null) {
        logBody['profile_image'] = "...[base64 profile image truncated]...";
      }
      if (logBody['reference_image'] != null) {
        logBody['reference_image'] = "...[base64 reference image truncated]...";
      }
      print("Onboarding Request: PATCH ${ApiServices.onboding_information}");
      print("Onboarding Payload: ${jsonEncode(logBody)}");

      final url = Uri.parse(ApiServices.onboding_information);
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("Onboarding Response Status: ${response.statusCode}");
      print("Onboarding Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
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

      print("Reset Password API Request: POST ${ApiServices
          .resutandconfrom_password}");
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
    }
  }


  final profileData = <String, dynamic>{}.obs;

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

      print("Get Profile Response Status: ${response.statusCode}");
      print("Get Profile Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final profileData = jsonDecode(response.body);
        return profileData;
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

      final Map<String, dynamic> requestBody = {};
      if (name != null) requestBody['name'] = name;
      if (dateOfBirth != null) requestBody['date_of_birth'] = dateOfBirth;
      if (bio != null) requestBody['bio'] = bio;
      if (profileImage != null) requestBody['profile_image'] = profileImage;
      if (referenceImage != null) requestBody['reference_image'] = referenceImage;
      if (useReferenceImage != null) requestBody['use_reference_image'] = useReferenceImage;

      // Print clean log payload (truncating base64 images if present)
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
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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
}