import 'dart:convert';

import 'package:maktub/config/supabase_config.dart';
import 'package:maktub/data/services/kit_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class AuthRepository {
  // final UserService userService;

  AuthRepository(
    // {required this.userService}
    );

  /// Отправка OTP по WhatsApp через KitService
  Future<bool> sendOtp(String phone, String otp) async {
    return await KitService.sendOtp(phone, otp);
  }

  /// Авторизация по номеру телефона и фиксированному паролю
  Future<void> signInWithPhonePassword(String phone) async {
    final response = await Supabase.instance.client.auth
        .signInWithPassword(phone: phone, password: 'somePassword');

    if (response.user == null) {
      throw Exception("Неверный номер или пароль");
    }
  }


Future<void> createUser(String phone, String workplaceId, int roleId, String fcmToken, int regionId, String fullName) async {
  String? dataUID;
  final url = Uri.parse('https://zmnbmhkgdhijswyggghx.supabase.co/functions/v1/create-user');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
    },
    body: jsonEncode({
      'phone': phone,
      'password': 'password',
      'role_id' : roleId,
      'workplace_id' : workplaceId,
      'fcm_token' : fcmToken,
      'region_id' : regionId,
      'full_name' : fullName
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);


    
      dataUID = data['user']?['user']?['id'];

      await confirmUserPhone(dataUID!);
   
    
  } 
  // else {
  //   setState(() {
  //     resultMessage = "Error: ${response.body}";
  //   });
  // }
}
  

Future<void> confirmUserPhone(String userId) async {
  final supabase = Supabase.instance.client;

   await supabase.rpc('confirm_user_phone', params: {
    'user_id': userId,
  });



}

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception("Сессия не найдена");
    }

    final data = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      throw Exception("Профиль пользователя не найден");
    }

    return data;
  }

  /// Выход из системы
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
