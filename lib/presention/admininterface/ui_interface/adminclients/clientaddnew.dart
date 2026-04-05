import 'package:flutter/material.dart';
import '../adminhome/homewidget/ClientInvitationCard.dart';
import '../adminhome/homewidget/Customadminbutton.dart';

class Clientaddnew extends StatefulWidget {
  const Clientaddnew({super.key});

  @override
  State<Clientaddnew> createState() => _Clientaddnew();
}

class _Clientaddnew extends State<Clientaddnew> {
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
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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

              _buildLabel('EMAIL ADDRESS'),
              const SizedBox(height: 8),
              _buildFieldContainer(
                child: TextField(
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                  decoration: _buildInputDecoration('client@example.com', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('ASSIGN INITIAL PLAN'),
              const SizedBox(height: 8),
              _buildFieldContainer(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPlan,
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
                  decoration: _buildInputDecoration('', Icons.workspace_premium_outlined),
                  items: ['Pro Coaching Plan', 'Basic Plan', 'Premium Plan']
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 16, color: _textColor, fontWeight: FontWeight.w500)),
                  ))
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) setState(() => _selectedPlan = newValue);
                  },
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('PERSONALIZED MESSAGE'),
              const SizedBox(height: 8),
              _buildFieldContainer(
                child: TextField(
                  maxLines: 4,
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Hi! I've set up your personalized routine...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, height: 1.5),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              CustomIconButton(
                title: "Send Invitation",
                iconPath: "assets/image/Container (8).png",
                onTap: () => debugPrint('Sent: $_selectedPlan'),
              ),

              const SizedBox(height: 30),
              Text("Recent Invitations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _labelColor)),
              const SizedBox(height: 12),
              ClientInvitationCard(email: "julie.chen@gmail.com", timeText: "Sent 2 hours ago", status: "SENT"),
              const SizedBox(height: 12),
              ClientInvitationCard(email: "mike.ross@outlook.com", timeText: "Sent 2 hours ago", status: "Accepted"),
              const SizedBox(height: 12),
              ClientInvitationCard(email: "sarah.v@company.io", timeText: "Sent 3 days ago", status: "Expired"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _labelColor, letterSpacing: 0.5));
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }
}