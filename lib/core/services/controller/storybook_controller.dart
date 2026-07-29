import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/api_services.dart';

class StorybookController extends GetxController {
  var clientPages = <Map<String, dynamic>>[].obs;
  var isStoryLoading = false.obs;
  var currentPdfUrl = ''.obs;
  var currentIndex = 0.obs;
  String authToken = "";

  final PageController pageController = PageController();

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp);
  }

  String normalizeImageUrl(String url) {
    return ApiServices.normalizeImageUrl(url);
  }

  Future<bool> fetchClientStorybook({String? storybookIdParam}) async {
    isStoryLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        debugPrint("Auth token is null, cannot fetch storybook");
        return false;
      }
      authToken = token;

      String storybookId = storybookIdParam ?? '';

      debugPrint("==================================================");
      debugPrint(">>> [STORYBOOK DEBUG] Starting fetchClientStorybook()");
      debugPrint(">>> [STORYBOOK DEBUG] Initial storybookId from API/Param: '$storybookId'");

      // 1. If storybookId is not passed, query server API for user storybook directly
      if (storybookId.isEmpty) {
        final routineUrl = Uri.parse(ApiServices.todayRoutine);
        debugPrint(">>> [STORYBOOK DEBUG] Querying Server API (Today Routine)...");
        final routineResponse = await http.get(
          routineUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (routineResponse.statusCode == 200) {
          final Map<String, dynamic> routineData = jsonDecode(routineResponse.body);
          final todayStorybook = routineData['today_storybook'] ?? routineData['storybook'];
          if (todayStorybook != null && todayStorybook is Map) {
            storybookId = todayStorybook['id']?.toString() ?? todayStorybook['storybook_id']?.toString() ?? '';
          } else if (routineData['storybook_id'] != null) {
            storybookId = routineData['storybook_id'].toString();
          }
        }
      }

      if (storybookId.isEmpty) {
        final assignedUrl = Uri.parse(ApiServices.assignedWorkoutPlan);
        debugPrint(">>> [STORYBOOK DEBUG] Querying Server API (Assigned Plan)...");
        final assignedResponse = await http.get(
          assignedUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (assignedResponse.statusCode == 200) {
          final Map<String, dynamic> assignedData = jsonDecode(assignedResponse.body);
          final sb = assignedData['storybook'] ?? assignedData['today_storybook'];
          if (sb != null && sb is Map) {
            storybookId = sb['id']?.toString() ?? sb['storybook_id']?.toString() ?? '';
          } else if (assignedData['storybook_id'] != null) {
            storybookId = assignedData['storybook_id'].toString();
          }
        }
      }

      if (storybookId.isEmpty) {
        debugPrint(">>> [STORYBOOK DEBUG] No storybookId returned from API endpoints.");
        clientPages.clear();
        return false;
      }

      final detailUrl = Uri.parse(ApiServices.storybookDetail(storybookId));
      debugPrint(">>> [STORYBOOK DEBUG] Requesting Detail API (Port 8000): $detailUrl");
      final detailResponse = await http.get(
        detailUrl,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(">>> [STORYBOOK DEBUG] Detail API Status: ${detailResponse.statusCode}");
      if (detailResponse.statusCode == 200) {
        final dynamic decoded = jsonDecode(detailResponse.body);
        List<dynamic> pages = [];

        if (decoded is Map<String, dynamic>) {
          pages = decoded['pages'] ?? [];
          if (decoded['pdf_url'] != null && decoded['pdf_url'].toString().isNotEmpty) {
            currentPdfUrl.value = normalizeImageUrl(decoded['pdf_url'].toString());
          } else {
            currentPdfUrl.value = ApiServices.storybookPdf(storybookId);
          }
        } else if (decoded is List) {
          pages = decoded
              .where((item) => item is Map && item['storybook_id']?.toString() == storybookId)
              .toList();
          pages.sort((a, b) => ((a['page_number'] ?? 0) as num).compareTo((b['page_number'] ?? 0) as num));
          currentPdfUrl.value = ApiServices.storybookPdf(storybookId);
        }

        if (pages.isNotEmpty) {
          final parsedPages = pages.map((e) => Map<String, dynamic>.from(e)).toList();
          clientPages.value = parsedPages;
          debugPrint(">>> [STORYBOOK DEBUG] SUCCESS! Loaded ${clientPages.length} pages via Detail API. PDF URL: ${currentPdfUrl.value}");
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint(">>> [STORYBOOK DEBUG] EXCEPTION in fetchClientStorybook: $e");
      return false;
    } finally {
      isStoryLoading.value = false;
    }
  }

  /// 1st API: Execute Storybook Generation (POST /storybook/generate/execute)
  /// Returns the generated storybook_id directly from the server API response
  Future<String?> createStorybookExecution({
    required String clientId,
    String? contextJson,
    String? selfiePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        debugPrint(">>> [STORYBOOK EXECUTE] Auth token is null");
        return null;
      }

      final url = Uri.parse(ApiServices.executeStorybookGeneration);
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['client_id'] = clientId;
      if (contextJson != null && contextJson.isNotEmpty) {
        request.fields['context_json'] = contextJson;
      }
      if (selfiePath != null && selfiePath.isNotEmpty && selfiePath != 'string') {
        try {
          final file = File(selfiePath);
          if (file.existsSync()) {
            final int fileLength = await file.length();
            if (fileLength <= 950000) {
              request.files.add(await http.MultipartFile.fromPath('selfie', selfiePath));
              debugPrint(">>> Attached selfie as MultipartFile from path: $selfiePath");
            } else {
              final bytes = await file.readAsBytes();
              request.files.add(http.MultipartFile.fromBytes(
                'selfie',
                bytes.sublist(0, 950000),
                filename: 'selfie.jpg',
              ));
              debugPrint(">>> Truncated selfie file to 950KB and attached as MultipartFile");
            }
          } else if (selfiePath.startsWith('http://') || selfiePath.startsWith('https://')) {
            request.fields['selfie'] = selfiePath;
            debugPrint(">>> Attached selfie as URL String: $selfiePath");
          } else {
            try {
              String cleanBase64 = selfiePath.replaceAll(RegExp(r'^data:image\/[a-z]+;base64,'), '').trim();
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
              debugPrint(">>> Successfully attached Base64 selfie as MultipartFile (byte size: ${bytes.length} bytes)");
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
      debugPrint(">>> 🚀 [CREATE STORYBOOK EXECUTE - REQUEST]");
      debugPrint(">>> URL: $url");
      debugPrint(">>> Headers: ${request.headers}");
      debugPrint(">>> Fields: ${request.fields}");
      debugPrint("==================================================");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("==================================================");
      debugPrint(">>> 📩 [CREATE STORYBOOK EXECUTE - RESPONSE]");
      debugPrint(">>> Status Code: ${response.statusCode}");
      debugPrint(">>> Body: ${response.body}");
      debugPrint("==================================================");

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? storybookId = data['storybook_id']?.toString();
        if (storybookId != null && storybookId.isNotEmpty) {
          return storybookId;
        }
      }
    } catch (e) {
      debugPrint(">>> [STORYBOOK EXECUTE EXCEPTION]: $e");
    }
    return null;
  }

  /// 2nd API: Check Storybook Status (GET /storybook/{storybook_id}/status)
  Future<String?> checkStorybookStatus(String storybookId) async {
    if (storybookId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse(ApiServices.storybookStatus(storybookId));
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint(">>> [STORYBOOK STATUS] Status: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['status']?.toString();
      }
    } catch (e) {
      debugPrint(">>> [STORYBOOK STATUS EXCEPTION]: $e");
    }
    return null;
  }

  /// 3rd API: Get Storybook by ID (GET /storybook/{storybook_id})
  /// Converts PDF URL & Page image URLs to port 8004 automatically
  Future<Map<String, dynamic>?> getStorybookById(String storybookId) async {
    if (storybookId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse(ApiServices.storybookDetail(storybookId));
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint(">>> [STORYBOOK DETAIL] Status: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          Map<String, dynamic> storybookData = Map<String, dynamic>.from(decoded);
          
          // PDF URL normalization to port 8004
          if (storybookData['pdf_url'] != null && storybookData['pdf_url'].toString().isNotEmpty) {
            storybookData['pdf_url'] = normalizeImageUrl(storybookData['pdf_url'].toString());
          } else {
            storybookData['pdf_url'] = ApiServices.storybookPdf(storybookId);
          }
          currentPdfUrl.value = storybookData['pdf_url'];

          if (storybookData['pages'] is List) {
            final List pagesList = List.from(storybookData['pages']);
            pagesList.sort((a, b) => ((a['page_number'] ?? 0) as num).compareTo((b['page_number'] ?? 0) as num));
            final parsedPages = pagesList.map((e) {
              final map = Map<String, dynamic>.from(e);
              if (map['image_url'] != null) {
                map['image_url'] = normalizeImageUrl(map['image_url'].toString());
              }
              return map;
            }).toList();
            storybookData['pages'] = parsedPages;
            clientPages.value = parsedPages;
          }
          return storybookData;
        }
      }
    } catch (e) {
      debugPrint(">>> [STORYBOOK DETAIL EXCEPTION]: $e");
    }
    return null;
  }

  Future<String?> fetchStorybookPdfUrl(String storybookId) async {
    if (storybookId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse(ApiServices.storybookPdf(storybookId));
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['pdf_url'] != null && data['pdf_url'].toString().isNotEmpty) {
          return normalizeImageUrl(data['pdf_url'].toString());
        }
      }
    } catch (e) {
      debugPrint(">>> [STORYBOOK PDF] Exception: $e");
    }
    return ApiServices.storybookPdf(storybookId);
  }

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < clientPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

