import 'package:dio/dio.dart';
import 'package:maktub/core/exceptions/app_exception.dart';

class AituPassportService {
  final Dio dio = Dio();

  // 🔥 Константы (замени на свои)
  final String clientId = "0551da04-dd66-4511-854f-fd7355c56861";
  final String redirectUri = "kz.maktub.test-main";
  final String baseUrl = "https://passport.aitu.io";
  final String state = "state";
  final String iinSignature = "iin_signature";


 
  String extractPhoneNumber(String redirectUrl) {
    Uri uri = Uri.parse(redirectUrl);
     return uri.queryParameters["phone"] ?? ''; // Aitu Passport возвращает phone в `scope`
  }
}
