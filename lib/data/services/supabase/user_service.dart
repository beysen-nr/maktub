// ignore_for_file: annotate_overrides

import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:maktub/config/supabase_config.dart';
import 'package:maktub/core/exceptions/app_exception.dart';
import 'package:maktub/data/services/crashlytics_service.dart';
import 'package:maktub/data/services/fcm_service.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class UserService extends SupabaseService {
  final SupabaseClient client = SupabaseService.client;

  // ignore: overridden_fields
  final FirebaseCrashlytics crashlytics = CrashlyticsService.crashlytics;

  Future<User?> signIn(String phone) async {
    return handleRequest(() async {
      final AuthResponse res = await client.auth.signInWithPassword(
        phone: phone,
        password: 'password',
      );
      return res.user;
    });
  }

  Future<User?> createUser(
    String phone,
    int role,
    String fullName,
    int regionId,
    String workplaceId,
  ) async {
    return handleRequest(() async {
      String? fcmToken = await FCMService.getFCMToken();
      await createUserEdgeFunction(
        phone,
        role,
        fullName,
        regionId,
        workplaceId,
        fcmToken!,
      );
      return null;
    });
  }

  Future<void> createUserEdgeFunction(
    String phone,
    int roleId,
    String fullName,
    int regionId,
    String workplaceId,
    String fcmToken,
  ) async {
    final url = Uri.parse(
      'https://zmnbmhkgdhijswyggghx.supabase.co/functions/v1/create-user',
    );
    try {
      final Map<String, dynamic> body = {
        'phone': phone,
        'full_name': fullName,
        'role_id': roleId,
        'fcm_token': fcmToken,
      };

      if (roleId == 1 || roleId == 2) {
        body['region'] = regionId; // Добавляем только если roleId = 1 или 2
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dataUID = data['user']?['user']?['id'];
        if (dataUID != null) {
          await confirmUserPhone(dataUID);
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? "Unknown server error";

        if (errorMessage.contains("Phone number already registered")) {
          throw UserAlreadyExistsException();
        }

        throw ServerException(
          "Ошибка сервера: $errorMessage",
        ); // 🔥 Теперь исключение содержит текст ошибки
      }
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      throw UnknownException(e.toString());
    }
  }

  Future<void> confirmUserPhone(String userId) async {
    final supabase = Supabase.instance.client;
    await supabase.rpc('confirm_user_phone', params: {'user_id': userId});
  }

  Future<List<User>> getUsersByWorkplace(int workplaceId, int roleInput) async {
    final response = await client.rpc(
      'get_users_by_workplace',
      params: {'workplace_input': workplaceId, 'role_input': roleInput},
    );

    if (response.error != null) {
      throw Exception('Ошибка: ${response.error!.message}');
    }

    return (response.data as List)
        .map((user) => User.fromJson(user))
        .where((user) => user != null) // Убираем null-значения
        .cast<User>() // Приводим к List<User>
        .toList();
  }

  Future<void> deleteUser(String requesterId, String targetId) async {
    final response = await client.rpc(
      'delete_user',
      params: {'requester_id': requesterId, 'target_id': targetId},
    );

    if (response.error != null) {
      throw Exception('Ошибка удаления: ${response.error!.message}');
    }

  }

  Future<void> updateUserRole(String targetId, int newRoleId) async {
    final response = await client.rpc(
      'update_user_role',
      params: {'target_id': targetId, 'new_role_id': newRoleId},
    );

    if (response.error != null) {
      throw Exception('Ошибка обновления роли: ${response.error!.message}');
    }

  }

  void _logError(dynamic error, StackTrace stackTrace) {
    crashlytics.recordError(error, stackTrace);
  }
}
