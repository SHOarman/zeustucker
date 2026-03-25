import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/userinterface/authscreen/createyouraccound.dart';
import 'package:zeustucker/presention/userinterface/authscreen/forgetpassword.dart';
import 'package:zeustucker/presention/userinterface/authscreen/verified.dart';
import 'package:zeustucker/presention/userinterface/authscreen/verifyyourrmailaddress.dart';
import 'package:zeustucker/presention/userinterface/authscreen/createnewpassword.dart';
import 'package:zeustucker/presention/userinterface/authscreen/login.dart';
import 'package:zeustucker/presention/userinterface/home/home_screen.dart';
import 'package:zeustucker/presention/userinterface/library/library_screen.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/onloding1.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/onlodingscreen2.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/onlodaing3.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/selectuser.dart';
import 'package:zeustucker/presention/userinterface/stats/stats_screen.dart';
import 'package:zeustucker/presention/userinterface/schedule/schedule_screen.dart';
import 'package:zeustucker/presention/userinterface/profile/profile_screen.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    //==========================authscreen============================
    GetPage(name: AppRoutes.login, page: () => Login()),
    GetPage(name: AppRoutes.createyouraccound, page: () => Createyouraccound()),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgetPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyYourEmailAddress(),
    ),
    GetPage(
      name: AppRoutes.createNewPassword,
      page: () => const CreateNewPassword(),
    ),
    GetPage(name: AppRoutes.verified, page: () => Verified()),

    //========================onloading==================================
    GetPage(name: AppRoutes.onloading1, page: () => Onloding1()),
    GetPage(name: AppRoutes.onloading2, page: () => const OnlodingScreen2()),
    GetPage(name: AppRoutes.onloading3, page: () => const Onlodaing3()),
    GetPage(name: AppRoutes.selectuser, page: ()=>Selectuser()),

    GetPage(
      name: AppRoutes.home,
      page: () =>  HomeScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.library,
      page: () => const LibraryScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.stats,
      page: () => const StatsScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.schedule,
      page: () => const ScheduleScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.noTransition,
    ),
  ];
}
