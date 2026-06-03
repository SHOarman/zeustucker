class ApiServices{


  ApiServices._();

  static const String baseUrl = 'http://10.10.20.57:8004';

  //==============================auth===============================================
static const String reg ="$baseUrl/auth/register/";
static const String login ="$baseUrl/auth/login/";
static const String verifyemail ="$baseUrl/auth/verify-email/";
static const String forgot_password="$baseUrl/auth/forgot-password/";
static const String reset_password ="$baseUrl/auth/reset-password/";

static const String refreshtoken= "$baseUrl/auth/refresh/";



//============================profile===============================================
static const String get_profile="$baseUrl/auth/profile/";



}