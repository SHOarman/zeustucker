import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ===============================================================
// PROFILE CONTROLLER
// ===============================================================
class EditProfileController extends GetxController {



  //==================================Report PROBLEM CONTROLLER===========================
  var selectedCountry = "United States".obs;
  var selectedLanguage = "English (US)".obs;
  final List<String> countries = ["United States", "Bangladesh", "United Kingdom", "Canada", "Germany"];
  final List<String> languages = ["English (US)", "Bengali", "Spanish", "French", "German"];

  void updateCountry(String value) => selectedCountry.value = value;
  void updateLanguage(String value) => selectedLanguage.value = value;

  //==================================Profile CONTROLLER===========================


  var nameController = TextEditingController(text: 'James');
  var emailController = TextEditingController(text: 'james@gmail.com');
  var professionController = TextEditingController(text: 'Software Developer');

  var selectedImagePath = ''.obs;
  var selectedGender = 'Male'.obs;
  var dob = '12/11/2001'.obs;
  var age = 24.obs;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
    }
  }

  Future<void> chooseDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 11, 12),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00A97D)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dob.value = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      int calculatedAge = DateTime.now().year - pickedDate.year;
      if (DateTime.now().month < pickedDate.month ||
          (DateTime.now().month == pickedDate.month && DateTime.now().day < pickedDate.day)) {
        calculatedAge--;
      }
      age.value = calculatedAge;
    }
  }

  void showGenderSelection(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  "Select Gender",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const Divider(height: 1),
            _buildGenderTile("Male"),
            _buildGenderTile("Female"),
            _buildGenderTile("Other"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderTile(String gender) {
    return ListTile(
      title: Text(
        gender,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
      ),
      onTap: () {
        selectedGender.value = gender;
        Get.back();
      },
    );
  }
}