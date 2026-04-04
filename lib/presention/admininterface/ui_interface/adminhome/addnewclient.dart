import 'package:flutter/material.dart';

import 'homewidget/ClientInvitationCard.dart';
import 'homewidget/Customadminbutton.dart';

class Addnewclient extends StatefulWidget {
  const Addnewclient({super.key});

  @override
  State<Addnewclient> createState() => _AddnewclientState();
}

class _AddnewclientState extends State<Addnewclient> {
  String _selectedPlan = 'Pro Coaching Plan';
  
  final Color _backgroundColor = const Color(0xFFF7F8FA);
  final Color _labelColor = const Color(0xFF9CA3AF);
  final Color _textColor = const Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2F33),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Invite New Client',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2F33),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Email Address Field
              Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'client@example.com',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 24),

              // Assign Initial Plan Field
              Text(
                'ASSIGN INITIAL PLAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPlan,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.workspace_premium_outlined, 
                        color: Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    ),
                    items: <String>['Pro Coaching Plan', 'Basic Plan', 'Premium Plan']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color: _textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPlan = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personalized Message Field
              Text(
                'PERSONALIZED MESSAGE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  maxLines: 5,
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Hi! I\'ve set up your personalized daily storybook routine. Can\'t wait for you to start...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      height: 1.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              SizedBox(height:20 ,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomIconButton(title: "Send Invitation", iconPath: "assets/image/Container (8).png", onTap: (){}),
                
              ),
              
              SizedBox(height: 20,),
              Text("Recent Invitations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _labelColor),),
              SizedBox(height: 12,),
              ClientInvitationCard(email: "julie.chen@gmail.com", timeText: "Sent 2 hours ago", status: "SENT"),
              SizedBox(height: 12,),
              ClientInvitationCard(email: "julie.chen@gmail.com", timeText: "Sent 2 hours ago", status: "Accepted"),
              SizedBox(height: 12,),

              ClientInvitationCard(email: "julie.chen@gmail.com", timeText: "Sent 2 hours ago", status: "Expired"),




            ],
          ),
        ),
      ),
    );
  }
}
