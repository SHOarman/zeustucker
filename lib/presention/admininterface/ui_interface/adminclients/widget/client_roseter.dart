import 'package:flutter/foundation.dart';
// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/controller/adminpenelcontroller/clientcontoller.dart';

class Clientroseter extends StatelessWidget {
  Clientroseter({super.key});

  final ClientController controller = Get.put(ClientController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back Button, Title and Filter Icon
          Row(
            children: [
              const SizedBox(width: 12),

              // Title
              const Expanded(
                child: Text(
                  'Client Roster',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Filter Button
              _buildFilterButton(),
            ],
          ),
          SizedBox(height: 5,),
         Row(
           children: [
             Text("Total Clients: ", style: TextStyle(fontSize: 16, color: Colors.black54),),
             Text("10", style: TextStyle(fontSize: 16, color: Color(0xff06D7A0), fontWeight: FontWeight.bold),),
           ],
         ),

           SizedBox(height: 24),

          // Reactive Search Bar
          TextField(
            controller: controller.searchController,
            style: const TextStyle(color: Colors.black),
            onChanged: (value) => controller.updateSearch(value),
            onSubmitted: (value) => controller.updateSearch(value),
            decoration: InputDecoration(
              hintText: 'Search Clients...',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: controller.clearSearch,
              )
                  : const SizedBox.shrink()),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onTap: (){
          debugPrint("Filter button tapped");
        },
          
          
          child: Image.asset("assets/image/Icon (5).png", width: 40, height: 40, color: Colors.black))
      
    );
  }
}