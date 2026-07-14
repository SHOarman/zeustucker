import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';
import 'package:zeustucker/core/services/controller/profilecontroller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _updateImage(BuildContext context, EditProfileController profileController, bool isReferenceImage) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        bool success;
        if (isReferenceImage) {
          success = await profileController.updateSelfProfileSettings(referenceImage: base64Image);
        } else {
          success = await profileController.updateSelfProfileSettings(profileImage: base64Image);
        }
        
        if (success) {
          await profileController.fetchAndSaveProfile();
        }
      } catch (e) {
        print("Error picking/updating profile image: $e");
      }
    }
  }

  void _showEditNameDialog(BuildContext context, EditProfileController profileController, String currentName) {
    final textController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  final success = await profileController.updateSelfProfileSettings(name: newName);
                  if (success) {
                    await profileController.fetchAndSaveProfile();
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(EditProfileController());
    
    // Fetch profile on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchAndSaveProfile();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Profile Image (Tapping updates main profile image)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(() {
                  final profile = profileController.profileData;
                  final profileImgBase64 = profile['profile_image'];
                  ImageProvider imgProvider;
                  if (profileImgBase64 != null && profileImgBase64.toString().isNotEmpty && profileImgBase64 != 'string') {
                    try {
                      imgProvider = MemoryImage(base64Decode(profileImgBase64));
                    } catch (e) {
                      imgProvider = const AssetImage('assets/image/newprofile.png');
                    }
                  } else {
                    imgProvider = const AssetImage('assets/image/newprofile.png');
                  }
                  
                  return GestureDetector(
                    onTap: () => _updateImage(context, profileController, false),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: imgProvider,
                      backgroundColor: Colors.white,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              // Name and Age (Tapping triggers name edit)
              Obx(() {
                final profile = profileController.profileData;
                final name = profile['name'] ?? 'John';
                final age = profile['age'] ?? '24';
                return GestureDetector(
                  onTap: () => _showEditNameDialog(context, profileController, name),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($age)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),

                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              
              Obx(() {
                final profile = profileController.profileData;
                final occupation = profile['occupation'] ?? 'Software Developer';
                return Text(
                  occupation,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
              const SizedBox(height: 32),

              Obx(() {
                final profile = profileController.profileData;
                final refImgBase64 = profile['reference_image'];
                final name = profile['name'] ?? 'John';
                final age = profile['age'] ?? '24';
                final occupation = profile['occupation'] ?? 'Software Developer';
                
                ImageProvider refImgProvider;
                if (refImgBase64 != null && refImgBase64.toString().isNotEmpty && refImgBase64 != 'string') {
                  try {
                    refImgProvider = MemoryImage(base64Decode(refImgBase64));
                  } catch (e) {
                    refImgProvider = const AssetImage('assets/image/newprofile.png');
                  }
                } else {
                  refImgProvider = const AssetImage('assets/image/newprofile.png');
                }
                
                return _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reference Image',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image(
                              image: refImgProvider,
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Age $age',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  occupation,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _updateImage(context, profileController, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Replace',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Subscription Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Icon(Icons.workspace_premium, color: Colors.orange.shade400, size: 18),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Subscription',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Plan: Basic',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00BFA5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '7 / 10',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Upgrade',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // About AI Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'AI',
                              style: TextStyle(
                                color: Color(0xFF7E57C2),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            Icon(Icons.auto_awesome, color: Colors.amber.shade400, size: 16),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'About AI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Text(
                      'Image consistency depends on AI model and\nreference quality.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Setting Card
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.settings);
                },
                child: _buildCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Setting',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectIndex: 4),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
