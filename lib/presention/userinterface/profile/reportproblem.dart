import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:zeustucker/core/services/controller/profilecontroller.dart';

class ReportProblem extends StatefulWidget {
  const ReportProblem({super.key});

  @override
  State<ReportProblem> createState() => _ReportProblemState();
}

class _ReportProblemState extends State<ReportProblem> {
  bool _isChecked = false;
  // Controller initialize
  final EditProfileController controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Report a Problem",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("First name"),
            _buildTextField("Your name"),
            const SizedBox(height: 16),

            _buildLabel("Last name"),
            _buildTextField("Your last name"),
            const SizedBox(height: 16),

            _buildLabel("Email"),
            _buildTextField("name@example.com"),
            const SizedBox(height: 16),

            _buildLabel("Phone number"),
            _buildTextField("+(12) 345 6789"),
            const SizedBox(height: 16),

            // --- Country Picker ---
            _buildLabelWithIcon("Country", Icons.public),
            Obx(() => _buildPickerField(
                controller.selectedCountry.value,
                    () => _showPickerPopup("Select Country", controller.countries, (val) => controller.updateCountry(val))
            )),
            const SizedBox(height: 16),

            // --- Language Picker ---
            _buildLabelWithIcon("Select language", Icons.language),
            Obx(() => _buildPickerField(
                controller.selectedLanguage.value,
                    () => _showPickerPopup("Select Language", controller.languages, (val) => controller.updateLanguage(val))
            )),
            const SizedBox(height: 16),

            _buildLabel("Your message"),
            _buildTextField("Type your message here...", maxLines: 5),
            const SizedBox(height: 20),

            _buildTermsSection(),
            const SizedBox(height: 24),

            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildLabelWithIcon(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black, fontSize: 14), // Input text black
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.5)),
      ),
    );
  }

  Widget _buildPickerField(String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // --- POPUP MODAL ---
  void _showPickerPopup(String title, List<String> items, Function(String) onSelect) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const Divider(),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index], style: const TextStyle(color: Colors.black)),
                    onTap: () {
                      onSelect(items[index]);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTermsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isChecked,
            activeColor: const Color(0xFF00BFA5),
            onChanged: (val) => setState(() => _isChecked = val ?? false),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: "By submitting this form, you confirm that you have read and agree to ",
              style: TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                TextSpan(text: "Terms of Service", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                TextSpan(text: " and "),
                TextSpan(text: "Privacy Statement", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Add your logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text("Send message", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}