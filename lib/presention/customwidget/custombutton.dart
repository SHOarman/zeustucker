import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final String iconname;
  final Function ontap;
  final bool isLoading;
  const Custombutton({
    super.key,
    required this.iconname,
    required this.ontap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () {
        ontap();
      },
      child: Container(
        // width: 338,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xff00A97D),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  iconname,
                  style: const TextStyle(
                    color: Color(0xffFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
