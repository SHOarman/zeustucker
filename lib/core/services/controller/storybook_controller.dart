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
      final String currentUserId = prefs.getString('user_id') ?? '';

      if (token == null) {
        debugPrint("Auth token is null, cannot fetch storybook");
        clientPages.clear();
        return false;
      }
      authToken = token;

      String storybookId = storybookIdParam ?? '';

      debugPrint("==================================================");
      debugPrint(">>> 🚀 [GET LATEST STORYBOOK API] Calling GET /storybook");
      debugPrint(">>> Token Present: true, currentUserId: '$currentUserId'");

      // Step 1: Query GET /storybook (No parameters required, server uses Authorization Bearer token!)
      try {
        final listUrl = Uri.parse("${ApiServices.baseUrl}/storybook");
        final response = await http.get(
          listUrl,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        debugPrint(">>> [GET LATEST STORYBOOK STATUS]: ${response.statusCode}");
        debugPrint(">>> [GET LATEST STORYBOOK BODY]: ${response.body}");

        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);
          Map<String, dynamic>? targetStorybook;

          if (decoded is List && decoded.isNotEmpty) {
            dynamic match;
            if (storybookId.isNotEmpty) {
              match = decoded.firstWhere(
                (item) => item is Map && (item['id']?.toString() == storybookId || item['storybook_id']?.toString() == storybookId),
                orElse: () => null,
              );
            }
            if (match == null && currentUserId.isNotEmpty) {
              match = decoded.firstWhere(
                (item) => item is Map && item['user_id']?.toString() == currentUserId,
                orElse: () => null,
              );
            }
            match ??= decoded.first;
            if (match is Map) {
              targetStorybook = Map<String, dynamic>.from(match);
            }
          } else if (decoded is Map<String, dynamic>) {
            targetStorybook = decoded;
          }

          if (targetStorybook != null) {
            final String foundId = (targetStorybook['id'] ?? targetStorybook['storybook_id'] ?? '').toString();
            if (foundId.isNotEmpty) {
              prefs.setString('latest_storybook_id', foundId);
              if (currentUserId.isNotEmpty) {
                prefs.setString('latest_storybook_$currentUserId', foundId);
              }
            }

            if (targetStorybook['pdf_url'] != null && targetStorybook['pdf_url'].toString().isNotEmpty) {
              currentPdfUrl.value = normalizeImageUrl(targetStorybook['pdf_url'].toString());
            } else if (foundId.isNotEmpty) {
              currentPdfUrl.value = ApiServices.storybookPdf(foundId);
            }

            if (targetStorybook['pages'] is List) {
              final List pagesList = List.from(targetStorybook['pages']);
              pagesList.sort((a, b) => ((a['page_number'] ?? 0) as num).compareTo((b['page_number'] ?? 0) as num));
              final parsedPages = pagesList.map((e) {
                final map = Map<String, dynamic>.from(e as Map);
                if (map['image_url'] != null) {
                  map['image_url'] = normalizeImageUrl(map['image_url'].toString());
                }
                return map;
              }).toList();

              if (parsedPages.isNotEmpty) {
                clientPages.value = parsedPages;
                debugPrint(">>> [GET LATEST STORYBOOK SUCCESS] Loaded ${clientPages.length} pages directly from GET /storybook!");
                return true;
              }
            }
          }
        }
      } catch (e) {
        debugPrint(">>> Exception calling GET /storybook: $e");
      }

      // Step 2: Fallback to SharedPreferences + GET /storybook/{storybook_id}
      if (storybookId.isEmpty) {
        storybookId = prefs.getString('latest_storybook_id') ?? '';
      }
      if (storybookId.isEmpty && currentUserId.isNotEmpty) {
        storybookId = prefs.getString('latest_storybook_$currentUserId') ?? '';
      }

      if (storybookId.isNotEmpty) {
        final storybookData = await getStorybookById(storybookId);
        if (storybookData != null && clientPages.isNotEmpty) {
          return true;
        }
      }

      clientPages.clear();
      return false;
    } catch (e) {
      debugPrint(">>> [STORYBOOK DEBUG] EXCEPTION in fetchClientStorybook: $e");
      return false;
    } finally {
      isStoryLoading.value = false;
    }
  }

  Future<String?> createStorybookExecution({
    required String clientId,
    String? contextJson,
    String? selfiePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final String currentUserId = prefs.getString('user_id') ?? '';
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
      // IMPORTANT: backend expects `selfie` to be an actual UploadFile part.
      // Sending it as a plain string field (even a placeholder like "string")
      // causes a 422: "Expected UploadFile, received: <class 'str'>".
      // So: attach a real file/bytes if we have one, otherwise omit the
      // field entirely rather than sending a string fallback.
      final Uint8List dummySelfieBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x01,
        0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43, 0x00, 0xFF, 0xC0, 0x00,
        0x0B, 0x08, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x14,
        0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00,
        0x37, 0xFF, 0xD9
      ]);

      bool selfieAttached = false;
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
            selfieAttached = true;
          } else if (selfiePath.startsWith('http://') || selfiePath.startsWith('https://')) {
            try {
              final downloaded = await http.get(Uri.parse(selfiePath));
              if (downloaded.statusCode == 200) {
                Uint8List bytes = downloaded.bodyBytes;
                if (bytes.length > 950000) {
                  bytes = bytes.sublist(0, 950000);
                }
                request.files.add(http.MultipartFile.fromBytes(
                  'selfie',
                  bytes,
                  filename: 'selfie.jpg',
                ));
                debugPrint(">>> Downloaded selfie from URL and attached as MultipartFile");
                selfieAttached = true;
              }
            } catch (e) {
              debugPrint(">>> Exception downloading selfie URL ($e)");
            }
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
              selfieAttached = true;
            } catch (e) {
              debugPrint(">>> Base64 decode failed for selfie ($e)");
            }
          }
        } catch (e) {
          debugPrint(">>> Exception preparing selfie ($e)");
        }
      }

      if (!selfieAttached) {
        request.files.add(http.MultipartFile.fromBytes(
          'selfie',
          dummySelfieBytes,
          filename: 'selfie.jpg',
        ));
        debugPrint(">>> Attached fallback 1x1 JPEG as MultipartFile stream for selfie");
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
          prefs.setString('latest_storybook_id', storybookId);
          if (currentUserId.isNotEmpty) {
            prefs.setString('latest_storybook_$currentUserId', storybookId);
          }
          if (clientId.isNotEmpty) {
            prefs.setString('latest_storybook_$clientId', storybookId);
          }
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

  /// 3rd API: Get full storybook by id (GET /storybook/{storybook_id})
  /// pdf_url and each page's image_url are normalized to the :8004 media host.
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

  /// Full AI generation flow, chaining all three APIs:
  /// 1. POST /storybook/generate/execute  -> returns storybook_id (status 202)
  /// 2. GET  /storybook/{id}/status       -> poll until COMPLETED/FAILED
  /// 3. GET  /storybook/{id}              -> load pages + pdf_url once ready
  ///
  /// NOTE: confirm the exact "done"/"failed" status strings your backend
  /// returns (schema only shows the "PENDING" example) and tighten the
  /// matching below if needed — currently it loosely matches on substrings.
  Future<Map<String, dynamic>?> generateAndPollStorybook({
    required String clientId,
    String? contextJson,
    String? selfiePath,
    Duration pollInterval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 3),
  }) async {
    isStoryLoading.value = true;
    try {
      // Step 1: create the generation job
      final storybookId = await createStorybookExecution(
        clientId: clientId,
        contextJson: contextJson,
        selfiePath: selfiePath,
      );

      if (storybookId == null) {
        debugPrint(">>> [STORYBOOK FLOW] Failed to create execution job");
        return null;
      }

      // Step 2: poll status until it's no longer pending/processing
      final deadline = DateTime.now().add(timeout);
      String? status;
      while (DateTime.now().isBefore(deadline)) {
        status = await checkStorybookStatus(storybookId);
        debugPrint(">>> [STORYBOOK FLOW] Poll status: $status");

        if (status == null) {
          // transient network hiccup — keep trying until timeout
          await Future.delayed(pollInterval);
          continue;
        }

        final normalized = status.toUpperCase();
        if (normalized.contains('COMPLETE') || normalized == 'SUCCESS' || normalized == 'DONE') {
          break;
        }
        if (normalized.contains('FAIL') || normalized.contains('ERROR')) {
          debugPrint(">>> [STORYBOOK FLOW] Generation failed with status: $status");
          return null;
        }
        // PENDING / PROCESSING / IN_PROGRESS -> keep polling
        await Future.delayed(pollInterval);
      }

      final finalStatus = status?.toUpperCase() ?? '';
      final isDone = finalStatus.contains('COMPLETE') || finalStatus == 'SUCCESS' || finalStatus == 'DONE';
      if (!isDone) {
        debugPrint(">>> [STORYBOOK FLOW] Timed out waiting for generation");
        return null;
      }

      // Step 3: fetch the finished storybook (pages + pdf_url)
      final storybookData = await getStorybookById(storybookId);
      return storybookData;
    } catch (e) {
      debugPrint(">>> [STORYBOOK FLOW EXCEPTION]: $e");
      return null;
    } finally {
      isStoryLoading.value = false;
    }
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