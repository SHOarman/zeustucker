import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin AuthBaseStateMixin on GetxController {
  var isLoading = false.obs;
  var selectedRole = 'user'.obs;
  var registeredEmail = ''.obs;
  final roleController = TextEditingController(text: 'user');

  String tempFullName = '';
  String tempEmail = '';
  String tempPassword = '';
  String tempConfirmPassword = '';
  String tempDateOfBirth = '';
  String tempRole = '';
  String tempOccupation = '';
  String tempFitnessGoal = '';
  String tempBio = '';
  String tempGender = '';
  String tempHeight = '';
  int? tempWeight;
  int? tempTargetWeight;
  String tempWakeUpTime = '';
  String tempBedTime = '';
  String tempFitnessMotivation = '';

  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final wakeUpTimeController = TextEditingController();
  final bedTimeController = TextEditingController();
  final fitnessMotivationController = TextEditingController();
  final rxSelectedGoal = RxnString();
  final rxSelectedGender = RxnString();

  bool isForgotPasswordFlow = false;
  String forgotPasswordCode = '';

  final profileData = <String, dynamic>{}.obs;
}
