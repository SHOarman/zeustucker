import 'package:get/get.dart';
import 'package:zeustucker/core/routes/app_routes.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/adminclient.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/clientaddnew.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminclients/clientdetels.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/addnewclient.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/editruting.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/magaeclients.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/accoundperferences.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/adminstory.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminsetting/adminsetting.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminhome/adminhome.dart';
import 'package:zeustucker/presention/admininterface/ui_interface/adminstory/blukreview.dart';
import 'package:zeustucker/presention/userinterface/authscreen/createyouraccound.dart';
import 'package:zeustucker/presention/userinterface/authscreen/forgetpassword.dart';
import 'package:zeustucker/presention/userinterface/authscreen/verified.dart';
import 'package:zeustucker/presention/userinterface/authscreen/verifyyourrmailaddress.dart';
import 'package:zeustucker/presention/userinterface/authscreen/createnewpassword.dart';
import 'package:zeustucker/presention/userinterface/authscreen/login.dart';
import 'package:zeustucker/presention/userinterface/home/home_screen.dart';
import 'package:zeustucker/presention/userinterface/library/libaraydetels.dart';
import 'package:zeustucker/presention/userinterface/library/library_screen.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/onloding1.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/onlodingscreen2.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/onlodaing3.dart';
import 'package:zeustucker/presention/userinterface/onlodingscreen/selectuser.dart';
import 'package:zeustucker/presention/userinterface/profile/contactsupport.dart';
import 'package:zeustucker/presention/userinterface/profile/privacypolicy.dart';
import 'package:zeustucker/presention/userinterface/profile/reportproblem.dart';
import 'package:zeustucker/presention/userinterface/profile/setting.dart';

import 'package:zeustucker/presention/userinterface/schedule/meals.dart';
import 'package:zeustucker/presention/userinterface/schedule/taks.dart';
import 'package:zeustucker/presention/userinterface/schedule/workout.dart';
import 'package:zeustucker/presention/userinterface/stats/stats_screen.dart';
import 'package:zeustucker/presention/userinterface/schedule/schedule_screen.dart';
import 'package:zeustucker/presention/userinterface/profile/profile_screen.dart';

import '../../presention/admininterface/ui_interface/adminhome/viewstory.dart';
import '../../presention/admininterface/ui_interface/adminsetting/clientmanagementlimirs.dart';
import '../../presention/admininterface/ui_interface/adminstory/regenerateall.dart';
import '../../presention/userinterface/profile/editprofile.dart';
import '../../presention/userinterface/profile/supportandhelp.dart';
import '../../presention/userinterface/profile/termsconditions.dart';


class AppPages {
  static const initial = AppRoutes.adminhome;

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

    GetPage(name: AppRoutes.librarydetails, page: () => const Libaraydetels()),
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

    //=========================================weekly========================================
    GetPage(name: AppRoutes.workout, page: ()=>Workout()),
    GetPage(name: AppRoutes.meal, page: ()=>Meals()),
    GetPage(name: AppRoutes.task, page: ()=>Taks()),


    //==========================================profile========================================
    GetPage(name: AppRoutes.settings, page: ()=>const Setting()),
    GetPage(name: AppRoutes.editprofile, page: ()=>const EditProfile()),
    GetPage(name: AppRoutes.support$help, page: ()=>Supportandhelp()),
    GetPage(name: AppRoutes.contactus, page: ()=>ContactSupport()),
    GetPage(name: AppRoutes.reportproblem, page: ()=>ReportProblem()),
    GetPage(name: AppRoutes.privacy, page: ()=>PrivacyPolicy()),
     GetPage(name: AppRoutes.terms, page: ()=>TermsConditions()),

    //==========================================Admin========================================
     GetPage(name: AppRoutes.adminhome, page: ()=>Adminhome( ), transition: Transition.noTransition),
     GetPage(name: AppRoutes.adminclient, page: ()=>const Adminclient(), transition: Transition.noTransition),
     GetPage(name: AppRoutes.adminstory, page: ()=>const Adminstory(), transition: Transition.noTransition),
     GetPage(name: AppRoutes.adminsettings, page: ()=>const Adminsetting(), transition: Transition.noTransition),



    //=======================admincontroller===============================================
    GetPage(name: AppRoutes.mageclient, page: ()=>Magaeclients(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.addnewclient, page: ()=>Addnewclient(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.editroutine, page: ()=>Editruting(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.viewstory, page: ()=>const Viewstory(), transition: Transition.noTransition),



    //==============================adminclient====================================
    GetPage(name: AppRoutes.clientaddnew, page: ()=>Clientaddnew(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.clientdetails, page: ()=>Clientdetels(), transition: Transition.noTransition),



    //===========================================adminstory================================================

    GetPage(name: AppRoutes.blukreview, page: ()=>const Blukreview(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.regenerateall, page: ()=>const Regenerateall(), transition: Transition.noTransition),



    //==============================================adminsetting================================================
    GetPage(name: AppRoutes.accoundperferences, page: ()=>const Accoundperferences(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.clientmanagementlimits, page: ()=>const Clientmanagementlimirs(), transition: Transition.noTransition),



  ];
}
