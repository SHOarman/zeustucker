import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeustucker/core/services/controller/homecontroller.dart';
import 'package:zeustucker/core/services/controller/adminpenelcontroller/clientcontoller.dart';

class Libaraydetels extends StatelessWidget {
  const Libaraydetels({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    final String storybookId = args?['storybook_id'] ?? '';
    debugPrint("Reviewing storybook ID: $storybookId");
    final int pageNumber = args?['page_number'] ?? 3;
    final String storyText = args?['story'] ?? '';
    final String imageUrl = args?['image_url'] ?? '';
    final bool isNetwork = imageUrl.isNotEmpty;
    final rawTitle = args?['title'];
    final String titleText = (rawTitle != null && rawTitle.toString() != 'null')
        ? rawTitle.toString()
        : '';

    String authToken = "";
    if (Get.isRegistered<HomeController>()) {
      authToken = Get.find<HomeController>().authToken;
    } else if (Get.isRegistered<ClientController>()) {
      authToken = Get.find<ClientController>().authToken;
    }

    final String displayChapter = isNetwork ? "PAGE $pageNumber" : "CHAPTER 3";
    final String displayTitle = isNetwork ? titleText : "Finding Your Rhythm";
    final String quoteText = isNetwork
        ? storyText
        : "This week felt different. You didn't just show up; you dominated the morning sessions. Like a character in a graphic novel, you've unlocked a new tier of consistency that's starting to define your story.";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chapter Review',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Card
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Background Image
                  Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: isNetwork
                            ? NetworkImage(
                                imageUrl,
                                headers: authToken.isNotEmpty
                                    ? {'Authorization': 'Bearer $authToken'}
                                    : null,
                              ) as ImageProvider
                            : const AssetImage('assets/image/bakround.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Overlapping Text Card
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayChapter.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF00BFA5),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'serif',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quote Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -30,
                    left: -20,
                    child: Text(
                      '99',
                      style: TextStyle(
                        fontSize: 40,
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      '"$quoteText"',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Heading
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                'STATS FROM THIS CHAPTER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Two Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 145,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00BFA5,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF00BFA5),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '12',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'WORKOUTS',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 145,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.orange.shade600,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '85',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '85%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NUTRITION',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),




            const SizedBox(height: 52),

            // Action Buttons
            // SizedBox(
            //   width: double.infinity,
            //   height: 52,
            //   child: ElevatedButton.icon(
            //     onPressed: () {},
            //     icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            //     label: const Text(
            //       'Regenerate this Chapter',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 15,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: const Color(0xFF00BFA5),
            //       elevation: 0,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: const Text(
                  'Back to Library',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Footer Text
            Center(
              child: Text(
                'This story is generated based on your real activity data.',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
