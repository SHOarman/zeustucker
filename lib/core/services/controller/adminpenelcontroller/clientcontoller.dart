import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ClientController extends GetxController {
  // --- Search & Daily Goals Logic ---
  var searchText = "".obs;
  var drinkWater = true.obs;
  var steps10k = true.obs;
  var noSugar = false.obs;
  var sleep8Hours = false.obs;

  final TextEditingController searchController = TextEditingController();


  var clientList = <Map<String, dynamic>>[
    {
      "name": "Sarah Jenkins",
      "image": "assets/image/image 9.png",
      "progress": 0.85,
      "hasNotification": false,
    },
    {
      "name": "Marcus Chen",
      "image": "assets/image/Panel 2.png",
      "progress": 0.62,
      "hasNotification": false,
    },
    {
      "name": "Elena Rodriguez",
      "image": "assets/image/Sarah.png",
      "progress": 0.40,
      "hasNotification": true,
    },
    {
      "name": "David Park",
      "image": "assets/image/Work Focus.png",
      "progress": 0.92,
      "hasNotification": false,
    },
  ].obs;


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
    clientList[index]['hasNotification'] = false;
    clientList.refresh();
  }
}