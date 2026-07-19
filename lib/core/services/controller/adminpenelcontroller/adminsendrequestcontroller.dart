import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_services/api_services.dart';
import 'clientcontoller.dart';

class Adminsendrequestcontroller extends GetxController {
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  
  var assignInitialPlan = true.obs; // Defaults to true
  var selectedPlan = 'Pro Coaching Plan'.obs;
  var isLoading = false.obs;
  
  var invitationList = <Map<String, dynamic>>[].obs;
  var isListLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvitations();
  }

  @override
  void onClose() {
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void selectPlan(String plan) {
    selectedPlan.value = plan;
    assignInitialPlan.value = (plan != 'Basic Plan');
  }

  void _showSnackbar(String title, String message, {required bool isSuccess}) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      backgroundColor: isSuccess ? const Color(0xFF00A97D) : const Color(0xFFE57373),
      icon: Icon(
        isSuccess ? Icons.check_circle_outline : Icons.error_outline,
        color: Colors.white,
        size: 28,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderRadius: 16,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      barBlur: 10,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
    );
  }

  Future<void> fetchInvitations() async {
    isListLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 1. Fetch coach client profiles (to map profile images)
      final clientsUrl = Uri.parse(ApiServices.coachClients);
      final clientsResponse = await http.get(clientsUrl, headers: headers);
      final Map<String, String> profileImages = {};
      if (clientsResponse.statusCode == 200) {
        final List<dynamic> clientsData = jsonDecode(clientsResponse.body);
        for (var client in clientsData) {
          final clientId = client['id']?.toString();
          final profileImg = client['profile_image']?.toString();
          if (clientId != null && profileImg != null && profileImg.isNotEmpty && profileImg != 'string') {
            profileImages[clientId] = profileImg;
          }
        }
      }

      // 2. Fetch coach nutrition plans (to check if client has routine/nutrition plan)
      final nutritionUrl = Uri.parse(ApiServices.coachNutritionPlans);
      final nutritionResponse = await http.get(nutritionUrl, headers: headers);
      final Set<String> clientsWithPlans = {};
      if (nutritionResponse.statusCode == 200) {
        final List<dynamic> plans = jsonDecode(nutritionResponse.body);
        for (var plan in plans) {
          final cId = plan['client_id']?.toString();
          if (cId != null) {
            clientsWithPlans.add(cId);
          }
        }
      }

      // 3. Fetch coach sent client requests
      final url = Uri.parse(ApiServices.coachClientRequestsSent);
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['ui_status'] = map['status'] ?? 'PENDING';

          // Map profile image if client is accepted
          final clientId = map['client_id']?.toString();
          if (clientId != null && profileImages.containsKey(clientId)) {
            map['profile_image'] = profileImages[clientId];
          }

          // Map has_routine status
          if (clientId != null && clientsWithPlans.contains(clientId)) {
            map['has_routine'] = true;
          } else {
            map['has_routine'] = false;
          }

          return map;
        }).toList();

        // Sort by created_at descending
        list.sort((a, b) {
          final aTimeStr = a['created_at'];
          final bTimeStr = b['created_at'];
          if (aTimeStr == null || bTimeStr == null) return 0;
          try {
            return DateTime.parse(bTimeStr).compareTo(DateTime.parse(aTimeStr));
          } catch (_) {
            return 0;
          }
        });

        invitationList.value = list;
      }
    } catch (e) {
      debugPrint("Error fetching coach sent client requests: $e");
    } finally {
      isListLoading.value = false;
    }
  }

  Future<void> sendInvitation() async {
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Required', 'Please enter a client email address.', isSuccess: false);
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showSnackbar('Invalid Email', 'Please enter a valid email address.', isSuccess: false);
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _showSnackbar('Error', 'Authentication token not found. Please log in again.', isSuccess: false);
        return;
      }

      final url = Uri.parse(ApiServices.coachClients);
      final body = jsonEncode({
        "client_email": email,
        "personalized_message": message.isEmpty ? null : message,
        "assign_initial_plan": assignInitialPlan.value,
      });

      debugPrint(">>> API REQUEST: POST $url");
      debugPrint(">>> REQUEST BODY: $body");
      debugPrint(">>> REQUEST HEADERS: Authorization: Bearer $token");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint("<<< API RESPONSE: ${response.statusCode}");
      debugPrint("<<< RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar('Success', 'Invitation sent successfully to $email.', isSuccess: true);
        emailController.clear();
        messageController.clear();
        selectedPlan.value = 'Pro Coaching Plan';
        assignInitialPlan.value = true;
        // Refresh list
        fetchInvitations();
      } else {
        String errorMsg = 'Failed to send invitation.';
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map && responseData.containsKey('detail')) {
            errorMsg = responseData['detail'].toString();
          }
        } catch (_) {}
        
        _showSnackbar('Error', errorMsg, isSuccess: false);
      }
    } catch (e) {
      debugPrint("Error sending invitation: $e");
      _showSnackbar('Error', 'Something went wrong: $e', isSuccess: false);
    } finally {
      isLoading.value = false;
    }
  }

  String formatTimeAgo(Map<String, dynamic> item) {
    final status = getStatus(item);
    final String prefix = status == 'ACCEPTED' ? 'Joined' : 'Sent';
    
    final dateTimeStr = item['created_at'] ?? item['accepted_at'] ?? item['joined_at'] ?? item['updated_at'];
    if (dateTimeStr == null) return '$prefix recently';
    
    try {
      final dateTime = DateTime.parse(dateTimeStr).toUtc();
      final difference = DateTime.now().toUtc().difference(dateTime);
      
      if (difference.inDays > 0) {
        return '$prefix ${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '$prefix ${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '$prefix ${difference.inMinutes} minutes ago';
      } else if (difference.inSeconds > 0) {
        return '$prefix ${difference.inSeconds} seconds ago';
      } else {
        return '$prefix just now';
      }
    } catch (_) {
      return '$prefix recently';
    }
  }

  String getStatus(Map<String, dynamic> item) {
    final status = item['ui_status'] ?? 'SENT';
    if (status == 'PENDING') {
      return 'SENT';
    }
    return status;
  }

  String getEmail(Map<String, dynamic> item) {
    return item['client_email'] ?? item['email'] ?? item['client_id'] ?? 'Pending Client';
  }

  Future<void> deleteClient(String clientId) async {
    isListLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.deleteCoachClient(clientId));
      debugPrint(">>> DELETING COACH CLIENT: DELETE $url");
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("<<< DELETE RESPONSE STATUS: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackbar('Success', 'Client removed successfully.', isSuccess: true);
        fetchInvitations(); 
        try {
          if (Get.isRegistered<ClientController>()) {
            Get.find<ClientController>().fetchClients();
          }
        } catch (_) {}
      } else {
        _showSnackbar('Error', 'Failed to remove client: ${response.statusCode}', isSuccess: false);
      }
    } catch (e) {
      debugPrint("Error deleting client: $e");
      _showSnackbar('Error', 'An error occurred: $e', isSuccess: false);
    } finally {
      isListLoading.value = false;
    }
  }
}