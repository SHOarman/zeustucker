import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  List<Map<String, dynamic>> get filteredClients {
    if (searchText.value.trim().isEmpty) {
      return clientList;
    }
    final query = searchText.value.trim().toLowerCase();
    return clientList.where((client) {
      final name = (client['name'] ?? client['email'] ?? '').toString().toLowerCase();
      final goal = (client['fitness_goal'] ?? client['occupation'] ?? '').toString().toLowerCase();
      return name.contains(query) || goal.contains(query);
    }).toList();
  }

  void updateSearch(String query) {
    searchText.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = "";
  }

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    fetchPendingRequests();
  }

  final Map<String, String> clientStorybookMap = {};

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
        debugPrint("==================================================");
        debugPrint(">>> 📋 [COACH CLIENTS LIST API RESPONSE]");
        debugPrint(">>> Body: ${response.body}");
        debugPrint("==================================================");
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
          final rawProgress = summary['weekly_progress_percentage'];
          final progressPercent = (rawProgress is num) ? rawProgress.toDouble() / 100.0 : 0.0;
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        return;
      }

      const String contextJson = "string";

      String? selfieVal = (client['reference_image'] ??
              client['selfie'] ??
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
            debugPrint("==================================================");
            debugPrint(">>> 👤 [COACH CLIENT PROFILE API RESPONSE]");
            debugPrint(">>> Status: ${profileResp.statusCode}");
            debugPrint(">>> Body: ${profileResp.body}");
            debugPrint("==================================================");
            final profileData = jsonDecode(profileResp.body);
            if (profileData is Map) {
              selfieVal = (profileData['reference_image'] ??
                      profileData['selfie'] ??
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

      // NOTE: no dummy/placeholder image fallback anymore. If the client has
      // no real reference image on file, we stop here and tell the coach,
      // instead of sending a fake selfie to the AI generation API.
      if (selfieVal == null || selfieVal.isEmpty || selfieVal == 'string') {
        debugPrint(">>> No real reference image found for $clientName. Aborting generation.");
        Get.snackbar(
          "No Reference Image",
          "$clientName has no reference/selfie image on file. Ask them to upload one before generating a storybook.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Try to actually prepare the selfie as a real file/bytes before we
      // commit to "generating" state — if this fails, we abort rather than
      // silently falling back to a dummy image.
      http.MultipartFile? selfieFile;
      try {
        // dart:io's File is not supported on Flutter Web (throws
        // "Unsupported operation: _Namespace"). Only attempt local file
        // access on non-web platforms; on web, a selfieVal is expected to
        // be a URL or base64 string anyway.
        final bool looksLikeLocalPath = !kIsWeb &&
            !selfieVal.startsWith('http://') &&
            !selfieVal.startsWith('https://') &&
            !selfieVal.startsWith('data:');

        if (looksLikeLocalPath && File(selfieVal).existsSync()) {
          final file = File(selfieVal);
          final int fileLength = await file.length();
          if (fileLength <= 950000) {
            selfieFile = await http.MultipartFile.fromPath('selfie', selfieVal);
            debugPrint(">>> Prepared selfie as MultipartFile from path: $selfieVal");
          } else {
            final bytes = await file.readAsBytes();
            selfieFile = http.MultipartFile.fromBytes(
              'selfie',
              bytes.sublist(0, 950000),
              filename: 'selfie.jpg',
            );
            debugPrint(">>> Truncated selfie file to 950KB and prepared as MultipartFile");
          }
        } else if (selfieVal.startsWith('http://') || selfieVal.startsWith('https://')) {
          final downloaded = await http.get(Uri.parse(selfieVal));
          if (downloaded.statusCode == 200) {
            Uint8List bytes = downloaded.bodyBytes;
            if (bytes.length > 950000) {
              bytes = bytes.sublist(0, 950000);
            }
            selfieFile = http.MultipartFile.fromBytes(
              'selfie',
              bytes,
              filename: 'selfie.jpg',
            );
            debugPrint(">>> Downloaded selfie from URL and prepared as MultipartFile");
          } else {
            debugPrint(">>> Failed to download selfie URL (status ${downloaded.statusCode})");
          }
        } else {
          // Assume base64
          String cleanBase64 = selfieVal.replaceAll(RegExp(r'^data:image\/[a-z]+;base64,'), '').trim();
          cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
          cleanBase64 = base64.normalize(cleanBase64);
          Uint8List bytes = base64Decode(cleanBase64);
          if (bytes.length > 950000) {
            bytes = bytes.sublist(0, 950000);
          }
          selfieFile = http.MultipartFile.fromBytes(
            'selfie',
            bytes,
            filename: 'selfie.jpg',
          );
          debugPrint(">>> Successfully prepared Base64 selfie as MultipartFile Bytes (byte size: ${bytes.length} bytes)");
        }
      } catch (e) {
        debugPrint(">>> Exception preparing selfie ($e)");
      }

      if (selfieFile == null) {
        debugPrint(">>> Could not prepare a real selfie file for $clientName. Aborting generation.");
        Get.snackbar(
          "Reference Image Error",
          "Could not read $clientName's reference image. Please check it and try again.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
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

      // 1st API: POST /storybook/generate/execute
      final executeUrl = Uri.parse(ApiServices.executeStorybookGeneration);
      final request = http.MultipartRequest('POST', executeUrl);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['context_json'] = contextJson;
      request.fields['client_id'] = clientId;
      request.files.add(selfieFile);

      debugPrint("==================================================");
      debugPrint(">>> 🚀 [CREATE STORYBOOK - 1ST API REQUEST]");
      debugPrint(">>> URL: $executeUrl");
      debugPrint(">>> Method: POST (multipart/form-data)");
      debugPrint(">>> Headers: ${request.headers}");
      debugPrint(">>> Fields: ${request.fields}");
      debugPrint(">>> Selfie source: $selfieVal");
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
          await _cacheStorybookId(client, storybookId);
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
    const maxAttempts = 180; // Extended to 15 minutes for slow AI rendering

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

        debugPrint("Poll Storybook Status ($attempts): ${response.statusCode} - Body: ${response.body}");
        if (response.statusCode == 200) {
          final Map<String, dynamic> statusData = jsonDecode(response.body);
          final String rawStatus = statusData['status']?.toString() ?? '';
          final String statusUpper = rawStatus.toUpperCase().trim();

          debugPrint("Storybook $storybookId status from API: $rawStatus");

          bool isDone = (statusUpper == 'COMPLETED' ||
              statusUpper == 'SUCCESS' ||
              statusUpper == 'SUCCESSFUL' ||
              statusUpper == 'READY' ||
              statusUpper == 'DONE' ||
              statusUpper == 'FINISHED');

          // Fallback check: Every 6 attempts (30s), check 3rd API to see if pages are already generated
          if (!isDone && attempts % 6 == 0) {
            try {
              final detailUrl = Uri.parse(ApiServices.storybookDetail(storybookId));
              final detailResponse = await http.get(
                detailUrl,
                headers: {
                  'accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              );
              if (detailResponse.statusCode == 200) {
                final dynamic decoded = jsonDecode(detailResponse.body);
                if (decoded is Map<String, dynamic> && decoded['pages'] is List && (decoded['pages'] as List).isNotEmpty) {
                  debugPrint("Storybook $storybookId completed according to detail API!");
                  isDone = true;
                } else if (decoded is List && decoded.isNotEmpty) {
                  debugPrint("Storybook $storybookId completed according to detail API list!");
                  isDone = true;
                }
              }
            } catch (e) {
              debugPrint("Detail check fallback error: $e");
            }
          }

          if (isDone) {
            generatingStorybookClientName.value = "";
            await _cacheStorybookId(client, storybookId);

            Get.defaultDialog(
              title: "Success",
              middleText: "Storybook generated successfully for $clientName!",
              textConfirm: "View Storybook",
              textCancel: "Close",
              confirmTextColor: Colors.white,
              buttonColor: const Color(0xFF00A37B),
              onConfirm: () {
                Get.back();
                fetchAndOpenClientStorybookById(storybookId, client);
              },
            );
            return false;
          } else if (statusUpper == 'FAILED' || statusUpper == 'ERROR') {
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
          "AI Generation for $clientName is taking longer. Click to check status again.",
          backgroundColor: Colors.amber,
          colorText: Colors.black87,
          duration: const Duration(seconds: 12),
          mainButton: TextButton(
            onPressed: () {
              generatingStorybookClientName.value = clientName;
              _pollStorybookStatus(storybookId, clientName, token, client);
            },
            child: const Text("Check Status", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        );
        return false;
      }

      return true;
    });
  }

  Future<void> _cacheStorybookId(Map<String, dynamic> client, String storybookId) async {
    if (storybookId.isEmpty) return;
    client['storybook_id'] = storybookId;
    client['latest_storybook_id'] = storybookId;

    final prefs = await SharedPreferences.getInstance();
    final List<String?> keys = [
      client['id']?.toString(),
      client['client_id']?.toString(),
      client['user_id']?.toString(),
      client['_id']?.toString(),
      client['uuid']?.toString(),
      client['client_uuid']?.toString(),
      client['email']?.toString(),
      client['name']?.toString(),
    ];

    for (final k in keys) {
      if (k != null && k.trim().isNotEmpty && k != 'null') {
        final keyStr = k.trim();
        clientStorybookMap[keyStr] = storybookId;
        await prefs.setString('latest_storybook_$keyStr', storybookId);
        debugPrint(">>> [CACHE STORYBOOK] Cached '$storybookId' under key '$keyStr'");
      }
    }
  }

  Future<String> _retrieveStorybookId(Map<String, dynamic> client) async {
    String storybookId = (client['storybook_id'] ?? client['latest_storybook_id'] ?? client['storybook']?['id'] ?? '').toString().trim();
    if (storybookId.isNotEmpty && storybookId != 'null' && storybookId != 'string') {
      debugPrint(">>> 📦 [SOURCE: CLIENT OBJECT PARAMETER] Storybook ID: '$storybookId'");
      return storybookId;
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String?> keys = [
      client['id']?.toString(),
      client['client_id']?.toString(),
      client['user_id']?.toString(),
      client['_id']?.toString(),
      client['uuid']?.toString(),
      client['client_uuid']?.toString(),
      client['email']?.toString(),
      client['name']?.toString(),
    ];

    for (final k in keys) {
      if (k != null && k.trim().isNotEmpty && k != 'null') {
        final keyStr = k.trim();
        final inMem = clientStorybookMap[keyStr];
        if (inMem != null && inMem.isNotEmpty) {
          debugPrint(">>> 💾 [SOURCE: IN-MEMORY CACHE] Found Storybook ID '$inMem' for key '$keyStr'");
          return inMem;
        }
        final inPrefs = prefs.getString('latest_storybook_$keyStr');
        if (inPrefs != null && inPrefs.isNotEmpty) {
          debugPrint(">>> 💿 [SOURCE: DISK CACHE (SharedPreferences)] Found Storybook ID '$inPrefs' for key '$keyStr'");
          return inPrefs;
        }
      }
    }
    return '';
  }

  String _findStorybookIdInJson(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      final priorityKeys = ['storybook_id', 'latest_storybook_id', 'story_id', 'storybookId', 'latest_storybook', 'storybook'];
      for (final key in priorityKeys) {
        final val = data[key];
        if (val is String && val.length >= 10 && val != 'null' && val != 'string') {
          return val.trim();
        }
        if (val is Map) {
          final nested = _findStorybookIdInJson(val);
          if (nested.isNotEmpty) return nested;
        }
      }
      for (final entry in data.entries) {
        if (entry.value is Map || entry.value is List) {
          final nested = _findStorybookIdInJson(entry.value);
          if (nested.isNotEmpty) return nested;
        }
      }
    } else if (data is List && data.isNotEmpty) {
      for (final item in data) {
        final nested = _findStorybookIdInJson(item);
        if (nested.isNotEmpty) return nested;
      }
    }
    return '';
  }

  Future<void> fetchAndOpenClientStorybook(Map<String, dynamic> client) async {
    debugPrint(">>> [FETCH STORYBOOK] Client Map: $client");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final String clientId = (client['id'] ?? client['client_id'] ?? client['user_id'] ?? client['_id'] ?? client['uuid'] ?? client['client_uuid'] ?? '').toString().trim();
    final String clientName = client['name'] ?? client['email'] ?? 'Client';

    String storybookId = await _retrieveStorybookId(client);

    // 1. Fetch storybookId directly from Server API profile: GET /coach/clients/$clientId/profile
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
        debugPrint(">>> [SERVER API 1] Client Profile Status: ${profileResp.statusCode}");
        debugPrint(">>> [SERVER API 1] Client Profile Body: ${profileResp.body}");
        if (profileResp.statusCode == 200) {
          final profileData = jsonDecode(profileResp.body);
          storybookId = _findStorybookIdInJson(profileData);
          debugPrint(">>> Extracted storybookId from SERVER API 1: '$storybookId'");
        }
      } catch (e) {
        debugPrint("Error fetching client profile from API: $e");
      }
    }

    // 2. Fetch storybookId directly from Server API User Storybooks: GET /storybook/user/$clientId
    if (storybookId.isEmpty && clientId.isNotEmpty && token != null) {
      try {
        final userStoryUrl = Uri.parse("${ApiServices.baseUrl}/storybook/user/$clientId");
        final storyResp = await http.get(
          userStoryUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        debugPrint(">>> [SERVER API 2] User Storybook Status: ${storyResp.statusCode}");
        debugPrint(">>> [SERVER API 2] User Storybook Body: ${storyResp.body}");
        if (storyResp.statusCode == 200) {
          final decoded = jsonDecode(storyResp.body);
          storybookId = _findStorybookIdInJson(decoded);
          debugPrint(">>> Extracted storybookId from SERVER API 2: '$storybookId'");
        }
      } catch (e) {
        debugPrint("Error fetching user storybook from API: $e");
      }
    }

    // 3. Fetch storybookId directly from Server API Storybook List: GET /storybook
    if (storybookId.isEmpty && clientId.isNotEmpty && token != null) {
      try {
        final listUrl = Uri.parse("${ApiServices.baseUrl}/storybook");
        final listResp = await http.get(
          listUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        debugPrint(">>> [SERVER API 3] All Storybooks Status: ${listResp.statusCode}");
        if (listResp.statusCode == 200) {
          final decoded = jsonDecode(listResp.body);
          if (decoded is List) {
            final clientMatch = decoded.firstWhere(
              (item) => item is Map && item['user_id']?.toString() == clientId,
              orElse: () => null,
            );
            if (clientMatch != null && clientMatch is Map) {
              storybookId = clientMatch['id']?.toString() ?? clientMatch['storybook_id']?.toString() ?? '';
              debugPrint(">>> Extracted matching storybookId for user $clientId from SERVER API 3: '$storybookId'");
            }
          } else {
            storybookId = _findStorybookIdInJson(decoded);
          }
        }
      } catch (e) {
        debugPrint("Error fetching storybook list from API: $e");
      }
    }

    // 4. Fetch storybookId directly from Server API Today Routine: GET /routines/today
    if (storybookId.isEmpty && token != null) {
      try {
        final routineUrl = Uri.parse(ApiServices.todayRoutine);
        final routineResp = await http.get(
          routineUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        debugPrint(">>> [SERVER API 4] Today Routine Status: ${routineResp.statusCode}");
        if (routineResp.statusCode == 200) {
          final decoded = jsonDecode(routineResp.body);
          storybookId = _findStorybookIdInJson(decoded);
          debugPrint(">>> Extracted storybookId from SERVER API 4: '$storybookId'");
        }
      } catch (e) {
        debugPrint("Error fetching today routine from API: $e");
      }
    }

    // 5. Fetch storybookId directly from Server API Client Weekly Summary: GET /coach/clients/$clientId/weekly-summary
    if (storybookId.isEmpty && clientId.isNotEmpty && token != null) {
      try {
        final summaryUrl = Uri.parse(ApiServices.coachClientWeeklySummary(clientId));
        final summaryResp = await http.get(
          summaryUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        debugPrint(">>> [SERVER API 5] Client Weekly Summary Status: ${summaryResp.statusCode}");
        if (summaryResp.statusCode == 200) {
          final decoded = jsonDecode(summaryResp.body);
          storybookId = _findStorybookIdInJson(decoded);
          debugPrint(">>> Extracted storybookId from SERVER API 5: '$storybookId'");
        }
      } catch (e) {
        debugPrint("Error fetching weekly summary from API: $e");
      }
    }

    if (storybookId.isNotEmpty) {
      await _cacheStorybookId(client, storybookId);
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
          final String sId = (storybookData['id'] ?? storybookData['storybook_id'] ?? storybookId).toString();
          final String uId = (storybookData['user_id'] ?? '').toString();
          if (sId.isNotEmpty) {
            await _cacheStorybookId(client, sId);
            if (uId.isNotEmpty) {
              clientStorybookMap[uId] = sId;
              await prefs.setString('latest_storybook_$uId', sId);
            }
          }
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