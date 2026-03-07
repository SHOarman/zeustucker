import 'package:flutter/cupertino.dart';

class Custombutton extends StatelessWidget {
  final String iconname;
  final Function ontap;
  const Custombutton({super.key, required this.iconname, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
       ontap();
      },
      child: Container(
        width: 338,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xff00A97D),
        ),
        child: Center(
          child: Text(
           iconname,
            style: TextStyle(
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
