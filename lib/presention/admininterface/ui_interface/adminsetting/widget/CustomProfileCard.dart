import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomProfileCard extends StatelessWidget {
  final String label;
  final RxString value;

  CustomProfileCard({
    super.key,
    required this.label,
    required this.value,
  });

  // Edit Popup Function
  void _showEditPopup() {
    final TextEditingController controller = TextEditingController(text: value.value);

    Get.defaultDialog(
      title: "Edit $label",
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new $label",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06D7A0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          value.value = controller.text; // Value update
          Get.back(); // Popup close
        },
        child: const Text("Save", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                // Obx use kora hoyeche jate value change holei ekhane update hoy
                Obx(() => Text(
                  value.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                )),
              ],
            ),
          ),
          // Edit Icon Button
          GestureDetector(
            onTap: _showEditPopup,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}