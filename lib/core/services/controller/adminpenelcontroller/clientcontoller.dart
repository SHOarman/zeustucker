import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../api_services/api_services.dart';

class ClientController extends GetxController {

  RxString userName = "Alexander Mitchell".obs;
  RxString emailaddress = "alexander.m@dailey.ai".obs;
  RxString phonenumber = "+1 (555) 902-3482".obs;
  RxString coachbio = "Specializing in routine-building through narrative psychology. Helping over 50 clients find their daily flow since 2022.".obs;

  var searchText = "".obs;
  var drinkWater = true.obs;
  var steps10k = true.obs;
  var noSugar = false.obs;
  var sleep8Hours = false.obs;

  final TextEditingController searchController = TextEditingController();

  var clientList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var pendingRequestsCount = 0.obs;
  var generatingStorybookClientName = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    fetchPendingRequests();
  }

  String authToken = "";

  Future<void> fetchClients() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;
      authToken = token;

      final url = Uri.parse(ApiServices.coachClients);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("ClientController: Fetch Clients Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        clientList.value = List<Map<String, dynamic>>.from(data);
        _fetchClientsProgress();
      }
    } catch (e) {
      debugPrint("Error fetching clients in ClientController: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchClientsProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final futures = clientList.map((client) async {
      final clientId = client['id'];
      if (clientId == null) return;

      try {
        final url = Uri.parse(ApiServices.coachClientWeeklySummary(clientId));
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> summary = jsonDecode(response.body);
          final progressPercent = (summary['weekly_progress_percentage'] ?? 0.0) is num 
              ? (summary['weekly_progress_percentage'] as num).toDouble() / 100.0
              : 0.0;
          final weekStart = summary['week_start'] ?? '';
          final weekEnd = summary['week_end'] ?? '';
          
          final index = clientList.indexWhere((c) => c['id'] == clientId);
          if (index != -1) {
            final updatedClient = Map<String, dynamic>.from(clientList[index]);
            updatedClient['progress'] = progressPercent;
            updatedClient['week_start'] = weekStart;
            updatedClient['week_end'] = weekEnd;
            clientList[index] = updatedClient;
          }
        }
      } catch (e) {
        debugPrint("Error fetching progress for client $clientId: $e");
      }
    }).toList();

    await Future.wait(futures);
    clientList.refresh();
  }

  void updateSearch(String value) {
    searchText.value = value;
    debugPrint("Searching for: $value");
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = "";
  }

  void toggleGoal(RxBool goal) {
    goal.value = !goal.value;
  }

  void onClientTap(int index) {
    var selectedClient = clientList[index];
    debugPrint("Navigating to: ${selectedClient['name']}");
  }

  void clearNotification(int index) {
    if (index < clientList.length) {
      clientList[index]['hasNotification'] = false;
      clientList.refresh();
    }
  }

  Future<void> fetchPendingRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiServices.coachClientRequestsSent);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("ClientController: Fetch Sent Requests Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final pending = data.where((x) => x['status'] == 'PENDING').length;
        pendingRequestsCount.value = pending;
      }
    } catch (e) {
      debugPrint("Error fetching sent client requests: $e");
    }
  }

  Future<void> generateStorybookForClient(Map<String, dynamic> client) async {
    final String clientId = (client['client_id'] ?? client['client_uuid'] ?? client['user_id'] ?? client['id'] ?? '').toString().trim();
    final clientName = client['name'] ?? client['email'] ?? 'Client';
    
    debugPrint(">>> Generating storybook for clientName: $clientName, Client ID: $clientId");
    
    if (clientId.isEmpty || clientId == 'null') {
      debugPrint(">>> Error: Client ID is empty or null!");
      Get.snackbar(
        "Error",
        "Client ID is missing. Cannot generate storybook.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (generatingStorybookClientName.value.isNotEmpty) {
      Get.snackbar(
        "Busy",
        "Already generating a storybook for ${generatingStorybookClientName.value}. Please wait.",
        backgroundColor: Colors.amber,
        colorText: Colors.black87,
      );
      return;
    }

    generatingStorybookClientName.value = clientName;

    Get.snackbar(
      "Storybook Generation",
      "Starting storybook generation for $clientName. This will run in the background.",
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        generatingStorybookClientName.value = "";
        return;
      }

      const String contextJson = "string";

      String? selfieVal = (client['selfie'] ??
              client['reference_image'] ??
              client['profile_image'] ??
              client['selfie_url'] ??
              client['image'])
          ?.toString()
          .trim();

      // Fetch client profile from API if reference_image is not in client object
      if ((selfieVal == null || selfieVal.isEmpty || selfieVal == 'string') && clientId.isNotEmpty) {
        try {
          final profileUrl = Uri.parse(ApiServices.getCoachClientProfile(clientId));
          final profileResp = await http.get(
            profileUrl,
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          if (profileResp.statusCode == 200) {
            final profileData = jsonDecode(profileResp.body);
            if (profileData is Map) {
              selfieVal = (profileData['selfie'] ??
                      profileData['reference_image'] ??
                      profileData['profile_image'] ??
                      profileData['image'])
                  ?.toString()
                  .trim();
            }
          }
        } catch (e) {
          debugPrint("Error fetching client profile for reference image: $e");
        }
      }

      // 1st API: POST /storybook/generate/execute
      final executeUrl = Uri.parse(ApiServices.executeStorybookGeneration);
      final request = http.MultipartRequest('POST', executeUrl);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['context_json'] = contextJson;
      request.fields['client_id'] = clientId;

      if (selfieVal != null && selfieVal.isNotEmpty && selfieVal != 'string') {
        try {
          final file = File(selfieVal);
          if (file.existsSync()) {
            final int fileLength = await file.length();
            if (fileLength <= 950000) {
              request.files.add(await http.MultipartFile.fromPath('selfie', selfieVal));
              debugPrint(">>> Attached selfie as MultipartFile from path: $selfieVal");
            } else {
              final bytes = await file.readAsBytes();
              request.files.add(http.MultipartFile.fromBytes(
                'selfie',
                bytes.sublist(0, 950000),
                filename: 'selfie.jpg',
              ));
              debugPrint(">>> Truncated selfie file to 950KB and attached as MultipartFile");
            }
          } else if (selfieVal.startsWith('http://') || selfieVal.startsWith('https://')) {
            request.fields['selfie'] = selfieVal;
            debugPrint(">>> Attached selfie as URL String: $selfieVal");
          } else {
            try {
              String cleanBase64 = selfieVal.replaceAll(RegExp(r'^data:image\/[a-z]+;base64,'), '').trim();
              cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
              cleanBase64 = base64.normalize(cleanBase64);
              Uint8List bytes = base64Decode(cleanBase64);
              if (bytes.length > 950000) {
                bytes = bytes.sublist(0, 950000);
              }
              request.files.add(http.MultipartFile.fromBytes(
                'selfie',
                bytes,
                filename: 'selfie.jpg',
              ));
              debugPrint(">>> Successfully attached Base64 selfie as MultipartFile Bytes (byte size: ${bytes.length} bytes)");
            } catch (e) {
              debugPrint(">>> Base64 decode failed for selfie ($e), setting default field 'string'");
              request.fields['selfie'] = 'string';
            }
          }
        } catch (e) {
          debugPrint(">>> Exception preparing selfie ($e), setting default field 'string'");
          request.fields['selfie'] = 'string';
        }
      } else {
        request.fields['selfie'] = 'string';
      }

      debugPrint("==================================================");
      debugPrint(">>> 🚀 [CREATE STORYBOOK - 1ST API REQUEST]");
      debugPrint(">>> URL: $executeUrl");
      debugPrint(">>> Method: POST (multipart/form-data)");
      debugPrint(">>> Headers: ${request.headers}");
      debugPrint(">>> Fields: ${request.fields}");
      debugPrint("==================================================");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("==================================================");
      debugPrint(">>> 📩 [CREATE STORYBOOK - 1ST API RESPONSE]");
      debugPrint(">>> Status Code: ${response.statusCode}");
      debugPrint(">>> Body: ${response.body}");
      debugPrint("==================================================");
      
      if (response.statusCode == 202) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        final String? storybookId = resData['storybook_id']?.toString();
        
        if (storybookId != null && storybookId.isNotEmpty) {
          debugPrint("Storybook creation started successfully! ID from API: $storybookId");
          // 2nd API: Poll status using storybook_id directly returned from API
          _pollStorybookStatus(storybookId, clientName, token, client);
        } else {
          generatingStorybookClientName.value = "";
          Get.snackbar(
            "Error",
            "Storybook ID not returned by server.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        generatingStorybookClientName.value = "";
        Get.snackbar(
          "Error",
          "Failed to start storybook generation. Code ${response.statusCode}.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      generatingStorybookClientName.value = "";
      debugPrint("Error generating storybook for $clientName: $e");
      Get.snackbar(
        "Error",
        "Failed to generate storybook: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _pollStorybookStatus(String storybookId, String clientName, String token, Map<String, dynamic> client) {
    const pollInterval = Duration(seconds: 5);
    int attempts = 0;
    const maxAttempts = 60;

    Future.doWhile(() async {
      await Future.delayed(pollInterval);
      attempts++;
      
      try {
        // 2nd API: GET /storybook/{storybook_id}/status
        final url = Uri.parse(ApiServices.storybookStatus(storybookId));
        final response = await http.get(
          url,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        debugPrint("Poll Storybook Status ($attempts): ${response.statusCode}");
        if (response.statusCode == 200) {
          final Map<String, dynamic> statusData = jsonDecode(response.body);
          final String status = statusData['status'] ?? '';
          
          debugPrint("Storybook $storybookId status from API: $status");

          if (status == 'COMPLETED') {
            generatingStorybookClientName.value = "";
            
            Get.defaultDialog(
              title: "Success",
              middleText: "Storybook generated successfully for $clientName!",
              textConfirm: "View Storybook",
              textCancel: "Close",
              confirmTextColor: Colors.white,
              buttonColor: const Color(0xFF00A37B),
              onConfirm: () {
                Get.back();
                // 3rd API: Fetch story details using storybookId from API
                fetchAndOpenClientStorybookById(storybookId, client);
              },
            );
            return false;
          } else if (status == 'FAILED') {
            generatingStorybookClientName.value = "";
            Get.defaultDialog(
              title: "Failed",
              middleText: "Failed to generate storybook for $clientName. Please try again.",
              textConfirm: "OK",
              confirmTextColor: Colors.white,
              buttonColor: Colors.redAccent,
              onConfirm: () => Get.back(),
            );
            return false;
          }
        }
      } catch (e) {
        debugPrint("Error polling status: $e");
      }

      if (attempts >= maxAttempts) {
        generatingStorybookClientName.value = "";
        Get.snackbar(
          "Storybook Status",
          "Storybook generation for $clientName is taking longer than expected.",
          backgroundColor: Colors.amber,
          colorText: Colors.black87,
        );
        return false;
      }
      
      return true;
    });
  }

  Future<void> fetchAndOpenClientStorybook(Map<String, dynamic> client) async {
    debugPrint(">>> [FETCH STORYBOOK] Client Map: $client");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final String clientId = (client['id'] ?? client['client_id'] ?? client['user_id'] ?? client['_id'] ?? client['uuid'] ?? client['client_uuid'] ?? '').toString().trim();
    final String clientName = client['name'] ?? client['email'] ?? 'Client';

    String storybookId = (client['storybook_id'] ?? client['latest_storybook_id'] ?? client['storybook']?['id'] ?? '').toString().trim();
    
    // Fetch storybookId directly from Server API profile if not in client object
    if (storybookId.isEmpty && clientId.isNotEmpty && token != null) {
      try {
        final profileUrl = Uri.parse(ApiServices.getCoachClientProfile(clientId));
        final profileResp = await http.get(
          profileUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (profileResp.statusCode == 200) {
          final profileData = jsonDecode(profileResp.body);
          if (profileData is Map) {
            storybookId = (profileData['storybook_id'] ?? profileData['latest_storybook_id'] ?? profileData['storybook']?['id'] ?? '').toString().trim();
          }
        }
      } catch (e) {
        debugPrint("Error fetching client profile from API: $e");
      }
    }

    debugPrint(">>> [FETCH STORYBOOK] API storybookId: '$storybookId', clientId: '$clientId'");

    if (storybookId.isEmpty) {
      Get.defaultDialog(
        title: "No Storybook",
        middleText: "No storybook has been generated for $clientName yet. Would you like to generate one now?",
        textConfirm: "Generate Now",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF00A37B),
        onConfirm: () {
          Get.back();
          generateStorybookForClient(client);
        },
      );
      return;
    }

    await fetchAndOpenClientStorybookById(storybookId, client);
  }

  /// 3rd API: GET /storybook/{storybook_id}
  /// Fetches storybook details directly from server API using storybookId
  Future<void> fetchAndOpenClientStorybookById(String storybookId, Map<String, dynamic> client) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final String clientName = client['name'] ?? client['email'] ?? 'Client';

    if (token == null) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF00A37B)),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // 3rd API: GET /storybook/{storybook_id}
      final detailUrl = Uri.parse(ApiServices.storybookDetail(storybookId));
      debugPrint(">>> [3RD API] Fetching storybook detail API: $detailUrl");
      final detailResponse = await http.get(
        detailUrl,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Get.back(); // close loading dialog
      debugPrint("[3RD API] Detail Status: ${detailResponse.statusCode}");
      debugPrint("[3RD API] Detail Body: ${detailResponse.body}");

      if (detailResponse.statusCode == 200) {
        final dynamic decoded = jsonDecode(detailResponse.body);
        Map<String, dynamic> storybookData = {};

        if (decoded is Map<String, dynamic>) {
          storybookData = Map<String, dynamic>.from(decoded);
          if (storybookData['pages'] is List) {
            final List pagesList = List.from(storybookData['pages']);
            pagesList.sort((a, b) => ((a['page_number'] ?? 0) as num).compareTo((b['page_number'] ?? 0) as num));
            storybookData['pages'] = pagesList;
          }
        } else if (decoded is List && decoded.isNotEmpty) {
          final matchedPages = decoded
              .where((item) => item is Map && item['storybook_id']?.toString() == storybookId)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          matchedPages.sort((a, b) => ((a['page_number'] ?? 0) as num).compareTo((b['page_number'] ?? 0) as num));

          if (matchedPages.isNotEmpty) {
            storybookData = {
              'storybook_id': storybookId,
              'pdf_url': ApiServices.storybookPdf(storybookId),
              'pages': matchedPages,
            };
          }
        }

        if (storybookData.isNotEmpty) {
          // Normalize PDF URL to Port 8004
          if (storybookData['pdf_url'] == null || storybookData['pdf_url'].toString().isEmpty) {
            storybookData['pdf_url'] = ApiServices.storybookPdf(storybookId);
          } else {
            storybookData['pdf_url'] = ApiServices.normalizeImageUrl(storybookData['pdf_url'].toString());
          }

          Get.toNamed(AppRoutes.viewstory, arguments: {
            'client': client,
            'storybook': storybookData,
          });
          return;
        }
      }

      Get.defaultDialog(
        title: "No Storybook",
        middleText: "Could not retrieve storybook for $clientName from server. Would you like to generate one?",
        textConfirm: "Generate Now",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF00A37B),
        onConfirm: () {
          Get.back();
          generateStorybookForClient(client);
        },
      );
    } catch (e) {
      Get.back();
      debugPrint("Error fetching client storybook: $e");
    }
  }
}