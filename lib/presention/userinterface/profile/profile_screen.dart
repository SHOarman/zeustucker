import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/customwidget/custom_bottom_nav.dart';
import 'package:zeustucker/core/services/controller/profilecontroller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              onPressed: () {
                Navigator.pop(context);
                profileController.updateName(textController.text.trim());
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
              
              // Profile Image
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
                    final String imgStr = profileImgBase64.toString();
                    if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
                      imgProvider = NetworkImage(imgStr);
                    } else {
                      try {
                        imgProvider = MemoryImage(base64Decode(imgStr));
                      } catch (_) {
                        imgProvider = const AssetImage('assets/image/newprofile.png');
                      }
                    }
                  } else {
                    imgProvider = const AssetImage('assets/image/newprofile.png');
                  }
                  
                  return GestureDetector(
                    onTap: () => profileController.pickAndUpdateImage(context, false),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: imgProvider,
                      backgroundColor: Colors.white,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              // Name and Age
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

              // Reference Image Card
              Obx(() {
                final profile = profileController.profileData;
                final refImgBase64 = profile['reference_image'];
                final name = profile['name'] ?? 'John';
                final age = profile['age'] ?? '24';
                final occupation = profile['occupation'] ?? 'Software Developer';
                
                ImageProvider refImgProvider;
                if (refImgBase64 != null && refImgBase64.toString().isNotEmpty && refImgBase64 != 'string') {
                  final String refStr = refImgBase64.toString();
                  if (refStr.startsWith('http://') || refStr.startsWith('https://')) {
                    refImgProvider = NetworkImage(refStr);
                  } else {
                    try {
                      refImgProvider = MemoryImage(base64Decode(refStr));
                    } catch (_) {
                      refImgProvider = const AssetImage('assets/image/newprofile.png');
                    }
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
                            onTap: () => profileController.pickAndUpdateImage(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

              // Coach Requests Card
              Obx(() {
                if (profileController.coachRequests.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'PENDING COACH REQUESTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileController.coachRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final req = profileController.coachRequests[index];
                        debugPrint("COACH_REQUEST_ITEM: $req");
                        final reqId = req['id'] ?? '';
                        final message = req['personalized_message'];
                        
                        // Parse coach details with high robustness
                        String coachName = 'Coach Connection Request';
                        String? coachImg;
                        
                        final coachVal = req['coach'] ?? req['coach_detail'] ?? req['coach_details'];
                        if (coachVal is Map) {
                          final fName = coachVal['first_name'] ?? coachVal['firstName'];
                          final lName = coachVal['last_name'] ?? coachVal['lastName'];
                          if (fName != null || lName != null) {
                            coachName = "${fName ?? ''} ${lName ?? ''}".trim();
                          } else {
                            coachName = coachVal['name'] ?? coachVal['email'] ?? coachVal['username'] ?? 'Coach Connection Request';
                          }
                          coachImg = coachVal['profile_image'] ?? coachVal['image'] ?? coachVal['profile_image_path'];
                        } else if (coachVal is String) {
                          coachName = coachVal;
                        } else {
                          coachName = req['coach_name'] ?? req['coach_email'] ?? req['coach_username'] ?? req['name'] ?? req['email'] ?? 'Coach Connection Request';
                          coachImg = req['coach_image'] ?? req['image'] ?? req['profile_image'] ?? req['coach_profile_image'];
                        }
                        
                        ImageProvider coachImageProvider;
                        if (coachImg != null && coachImg.toString().isNotEmpty && coachImg.toString() != 'string') {
                          final String imgStr = coachImg.toString();
                          if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
                            coachImageProvider = NetworkImage(imgStr);
                          } else {
                            try {
                              coachImageProvider = MemoryImage(base64Decode(imgStr));
                            } catch (_) {
                              coachImageProvider = const AssetImage('assets/image/David Park.png');
                            }
                          }
                        } else {
                          coachImageProvider = const AssetImage('assets/image/David Park.png');
                        }
                        
                        final planVal = req['assign_initial_plan'] ?? req['plan'];
                        String planName = 'Pro Coaching Plan';
                        if (planVal is bool) {
                          planName = planVal ? 'Pro Coaching Plan' : 'Basic Plan';
                        } else if (planVal is String && planVal.isNotEmpty) {
                          planName = planVal;
                        }
                        
                        return _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: coachImageProvider,
                                    radius: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coachName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Plan: $planName',
                                          style: const TextStyle(
                                            color: Color(0xFF00A97D),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Pending response',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (message != null && message.toString().isNotEmpty && message.toString() != 'string') ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '"$message"',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => profileController.declineCoachRequest(reqId),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red.shade400,
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => profileController.acceptCoachRequest(reqId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00BFA5),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // Setting Card
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.settings),
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
