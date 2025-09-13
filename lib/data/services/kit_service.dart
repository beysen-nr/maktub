import 'dart:convert';
import 'package:http/http.dart' as http;

class KitService {
  static const String _apiUrl = 'https://kazinfoteh.org/wasender/sendwamsg'; // Убедитесь, что URL верный
  static const Map<String, String> _headers = {
    'X-API-KEY': 'sk_DFBA38BCF2C74B6DBD15B79DCEDB3B69',
    'Content-Type': 'application/json',
  };

  /// Отправка OTP-кода через WhatsApp
  static Future<bool> sendOtp(String phoneNumber, String otpCode) async {

    var body = json.encode({
      "requestId": "test-${DateTime.now().millisecondsSinceEpoch}",
      "to": phoneNumber,
      "content": {
        "whatsappContent": {
          "contentType": "AUTHENTICATION",
          "name": "codekz",
          "code": otpCode
        }
      }
    });

    try {
      var response = await http.post(
        Uri.parse(_apiUrl),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
