import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Below is a complete, clear, and app-ready content outline for your Privacy Policy section. This is written in simple, student-friendly language (not legal jargon) but still looks professional enough for an app.\nYou can use this exactly as text inside your app's \"Privacy Policy\" page.\nPrivacy Policy (App Version)",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            
            _buildSection(
              "1. Introduction",
              "We value your privacy and are committed to protecting your personal information. This policy explains what data we collect, how we use it, and the choices you have about your information.",
            ),
            
            _buildTitle("2. Information We Collect"),
            _buildBody("We may collect the following types of information:"),
            _buildSubtitle("a. Account Information"),
            _buildBulletPoints(["Name", "Email or phone number", "Password (encrypted)"]),
            
            _buildSubtitle("b. Academic & Task Information"),
            _buildBulletPoints(["Courses and subjects you add", "Tasks, assignments, and notes you create", "Study schedule details"]),
            
            _buildSubtitle("c. Device & Usage Data"),
            _buildBulletPoints(["Device model", "App version", "General usage analytics", "Crash reports (if enabled)"]),
            
            _buildSubtitle("d. Optional Data"),
            _buildBulletPoints(["Files you upload (notes, PDFs, documents)", "AI chat interactions (used to improve recommendations)"]),
            
            const SizedBox(height: 16),
            _buildTitle("3. How We Use Your Information"),
            _buildBody("Your data is used to provide and improve the app experience, including:"),
            _buildBulletPoints([
              "Creating personalized study plans",
              "Sending reminders & notifications",
              "Saving tasks, notes, and schedules",
              "Improving app performance",
              "Enhancing AI recommendations"
            ]),
            _buildBody("We do not sell your data to third parties."),
            
            const SizedBox(height: 16),
            _buildTitle("4. How Your Data is Stored & Protected"),
            _buildBulletPoints([
              "Passwords are encrypted.",
              "Data is stored securely on trusted servers.",
              "Access is restricted to authorized personnel only.",
              "Regular security checks are performed to protect your information."
            ]),
            
            const SizedBox(height: 16),
            _buildTitle("5. Sharing of Information"),
            _buildBody("We do not share your personal data except:"),
            const SizedBox(height: 8),
            _buildSubtitle("a. With your permission"),
            _buildBody("For example, when you request support."),
            const SizedBox(height: 8),
            _buildSubtitle("b. With service providers"),
            _buildBody("For features like payments or cloud storage."),
            const SizedBox(height: 8),
            _buildSubtitle("c. When required by law"),
            _buildBody("If a legal authority requires it.\nWe never share your academic notes, tasks, or study data with any advertiser."),
            
            const SizedBox(height: 16),
            _buildTitle("6. AI Data Usage"),
            _buildBody("When you use TaskBot or AI planning:"),
            _buildBulletPoints([
              "Your input is processed to generate responses",
              "Data may be used anonymously to improve AI accuracy",
              "We do not use your private notes or files to train external AI models"
            ]),
            
            const SizedBox(height: 16),
            _buildTitle("7. Cookies & Tracking"),
            _buildBody("If the app uses web features, basic cookies may be used to:"),
            _buildBulletPoints([
              "Maintain login sessions",
              "Improve performance",
              "Analyze user trends"
            ]),
            _buildBody("No tracking cookies for advertising are used."),
            
            const SizedBox(height: 16),
            _buildTitle("8. Your Rights"),
            _buildBody("You can:"),
            _buildBulletPoints([
              "Edit your profile information",
              "Modify or delete tasks and notes",
              "Request account deletion",
              "Disable notifications"
            ]),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title),
          _buildBody(body),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildBody(String body) {
    return Text(
      body,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• ", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                Expanded(
                  child: Text(p, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
