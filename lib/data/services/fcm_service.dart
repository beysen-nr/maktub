import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Инициализация Firebase и получение FCM токена
  static Future<String?> getFCMToken() async {
    try {
      await Firebase.initializeApp();
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      throw Exception('No FCM token');
    }
  }
}
