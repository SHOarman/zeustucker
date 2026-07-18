import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  String tempFullName = '';
  String tempEmail = '';
  String tempPassword = '';
  String tempConfirmPassword = '';
  String tempDateOfBirth = '';
  String tempRole = '';
  String tempOccupation = '';
  String tempFitnessGoal = '';
  String tempBio = '';
  String tempGender = '';
  String tempHeight = '';
  int? tempWeight;
  int? tempTargetWeight;
  String tempWakeUpTime = '';
  String tempBedTime = '';
  String tempFitnessMotivation = '';
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final wakeUpTimeController = TextEditingController();
  final bedTimeController = TextEditingController();
  final fitnessMotivationController = TextEditingController();
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
      ).timeout(const Duration(seconds: 10));

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
            ).timeout(const Duration(seconds: 10));
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
        print("\n================ SELF PROFILE DATA FROM SERVER ================");
        print("Gender: ${profileData['gender']}");
        print("Occupation: ${profileData['occupation'] ?? profileData['profession']}");
        print("Fitness Goal: ${profileData['fitness_goal']}");
        print("Wake Up Time: ${profileData['wake_up_time']}");
        print("Bed Time: ${profileData['bed_time']}");
        print("Height: ${profileData['height']}");
        print("Weight: ${profileData['weight']}");
        print("Target Weight: ${profileData['target_weight']}");
        print("Fitness Motivation: ${profileData['fitness_motivation']}");
        print("Reference Image (Length): ${profileData['reference_image']?.toString().length ?? 0}");
        print("Short Bio: ${profileData['short_bio'] ?? profileData['bio']}");
        print("================================================================\n");
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
      print("Update Profile Settings Request: PATCH ${ApiServices.getProfile}");
      print("Update Profile Settings Payload: ${jsonEncode(logBody)}");

      final url = Uri.parse(ApiServices.getProfile);
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