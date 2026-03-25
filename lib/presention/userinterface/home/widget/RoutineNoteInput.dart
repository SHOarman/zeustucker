import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoutineNoteInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPost;

  const RoutineNoteInput({
    super.key,
    required this.controller,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(fontSize: 14

              ,color: Colors.black,),
              decoration: InputDecoration(
                hintText: "Add a quick note for your routine...",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: onPost,
           child: Image.asset("assets/image/Container.png",height: 20,width: 20,),
          ),
        ],
      ),
    );
  }
}