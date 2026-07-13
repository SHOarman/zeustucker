class ApiServices{


  ApiServices._();

  static const String baseUrl = 'http://10.10.28.89:8000';

  //==============================auth===============================================
static const String reg ="$baseUrl/register/";
static const String login ="$baseUrl/login/";
static const String emailsend ="$baseUrl/email/send-verification/";
static const String emailverfy="$baseUrl/email/verify/";
static const String forgot_password ="$baseUrl/password/forgot/";
  static const String resutandconfrom_password ="$baseUrl/password/reset/";





}