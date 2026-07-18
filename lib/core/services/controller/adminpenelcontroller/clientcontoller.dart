import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchClients();
  }

  Future<void> fetchClients() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

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
      }
    } catch (e) {
      debugPrint("Error fetching clients in ClientController: $e");
    } finally {
      isLoading.value = false;
    }
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
}