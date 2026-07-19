class ApiServices{


  ApiServices._();

  static const String baseUrl = 'http://10.10.28.89:8000';

  //==============================auth===============================================
static const String reg ="$baseUrl/register";
static const String login ="$baseUrl/login";
static const String emailsend ="$baseUrl/email/send-verification";
static const String emailverfy="$baseUrl/email/verify";
static const String forgot_password ="$baseUrl/password/forgot";
  static const String resutandconfrom_password ="$baseUrl/password/reset";
  static const String onboding_information ="$baseUrl/auth/registration-info";
  static const String getProfile = "$baseUrl/profile";
  static const String updateSelfProfile = "$baseUrl/profile/self/settings";
  static const String updateCoachProfile = "$baseUrl/profile/coach/settings";
  static const String updateCoachPassword = "$baseUrl/profile/coach/password";
  static const String logout = "$baseUrl/profile/logout";
  static const String deleteAccount = "$baseUrl/profile/account";
  static const String coachClients = "$baseUrl/coach/clients";
  static String deleteCoachClient(String clientId) => "$baseUrl/coach/clients/$clientId";
  static String getCoachClientProfile(String clientId) => "$baseUrl/coach/clients/$clientId/profile";
  static const String coachClientRequests = "$baseUrl/coach/client-requests";
  static const String coachClientRequestsSent = "$baseUrl/coach/client-requests/sent";
  static String acceptClientRequest(String requestId) => "$baseUrl/coach/client-requests/$requestId/accept";
  static const String dashboard = "$baseUrl/dashboard";
  static const String coachNutritionPlans = "$baseUrl/coach/nutrition-plans";

  //==================================rutting===================================================
  static const String todayRoutine = "$baseUrl/routines/today";
  static const String routines = "$baseUrl/routines";
  static const String macroRecent = "$baseUrl/routines/macro-recent";
  static const String todayMacroLogs = "$baseUrl/routines/today/macro-logs";

  static String routineDetail(String routineId) => "$baseUrl/routines/$routineId";
  static String routineMacroLogs(String routineId) => "$baseUrl/routines/$routineId/macro-logs";

  //==================================storybook=================================================
  
  static const String generateStorybook = "$baseUrl/storybook/generate";

  static String storybookDetail(String storybookId) => "$baseUrl/storybook/$storybookId";
  static String storybookPage(String storybookId, int pageNumber) => "$baseUrl/storybook/$storybookId/page/$pageNumber";
  static String storybookStatus(String storybookId) => "$baseUrl/storybook/$storybookId/status";
  static String regenerateStoryText(String storybookId, int pageNumber) => "$baseUrl/storybook/$storybookId/page/$pageNumber/regenerate-story";
  static String regenerateStoryImage(String storybookId, int pageNumber) => "$baseUrl/storybook/$storybookId/page/$pageNumber/regenerate-image";
  static String regenerateStoryAndImage(String storybookId, int pageNumber) => "$baseUrl/storybook/$storybookId/page/$pageNumber/regenerate";
  static String storybookPdf(String storybookId) => "$baseUrl/storybook/$storybookId/pdf";

  //==================================workout-plans=============================================
  static const String workoutPlans = "$baseUrl/workout-plans";

  static String workoutPlanDetail(String planId) => "$baseUrl/workout-plans/$planId";
  static String assignWorkoutPlan(String planId) => "$baseUrl/workout-plans/$planId/assign";

  //==================================nutrition-plans=============================================
  static const String nutritionPlans = "$baseUrl/coach/nutrition-plans";
  static String nutritionPlanDetail(String planId) => "$baseUrl/coach/nutrition-plans/$planId";
}