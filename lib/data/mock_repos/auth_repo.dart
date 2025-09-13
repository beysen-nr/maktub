import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:maktub/config/supabase_config.dart';
import 'package:maktub/data/services/kit_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class AuthRepository {

  AuthRepository(
  );

  Future<bool> sendOtp(String phone, String otp) async {
return await KitService.sendOtp(phone, otp);
  }

  Future<bool> getDevModeStatus() async {
  final data = await Supabase.instance.client
      .from('devmode')
      .select('enabled')
      .limit(1)
      .single();

  return data['enabled'] as bool;
}


    Future<bool> signInWithPhonePassword(String phone) async {
    final response = await Supabase.instance.client.auth
        .signInWithPassword(phone: phone, password: 'password');

    return response.user != null;
  }
    Future<void> deleteAccount( {
    required String phoneNumber}) async {
      await Supabase.instance.client
          .from('profiles')
          .delete().eq('phone', phoneNumber);
  }



    Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> createOrganization(
    {required  organizationId,
    required name, 
    required String phoneNumber}) async{
      
      await Supabase.instance.client
          .from('organization')
          .insert({
            'organization_id': organizationId,
            'name': name,
            'phone_number': phoneNumber,
          });
    }



Future<void> deleteUser({
  required String phone,
}) async {
  final url = Uri.parse(
    'https://zmnbmhkgdhijswyggghx.supabase.co/functions/v1/hyper-processor',
  );

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
    },
    body: jsonEncode({
      'phone': phone,

    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode != 200) {

    final errorMessage =
        data['error'] ?? data['message'] ?? 'Неизвестная ошибка';
    throw Exception(errorMessage);
  }
}


Future<void> createUser({
  String? fcmToken,
  int? regionId,
  required String fullName,
  required String phone,
  required int workplaceId,
  required int roleId,
}) async {
  final url = Uri.parse(
    'https://zmnbmhkgdhijswyggghx.supabase.co/functions/v1/create-user',
  );

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
    },
    body: jsonEncode({
      'phone': phone,
      'password': 'password',
      'role_id': roleId,
      'workplace_id': workplaceId,
      'fcm_token': fcmToken,
      'region_id': regionId,
      'full_name': fullName,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final userId = data['user_id'];

    if (userId != null) {
      await Supabase.instance.client.rpc(
        'confirm_user_phone',
        params: {'user_id': userId},
      );
    }

  } else {
    final errorMessage =
        data['error'] ?? data['message'] ?? 'Неизвестная ошибка';
    throw Exception(errorMessage);
  }
}

  // else {
  //   setState(() {
  //     resultMessage = "Error: ${response.body}";
  //   });
  // }
}

