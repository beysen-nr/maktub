import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maktub/config/dadata_config.dart';
import 'package:maktub/core/exceptions/app_exception.dart';

class DadataService {
  final Dio _dio = Dio();
  final String apiKey = DadataConfig.dadataApiKey; // 🔥 Твой API-ключ

  /// Проверяет бизнес по BIN/IIN
  Future<Map<String, dynamic>> checkBusinessExistence(String bin) async {
    final String url = "http://suggestions.dadata.ru/suggestions/api/4_1/rs/findById/party_kz";

    try {
      Response response = await _dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Token $apiKey", // Dadata требует "Token" в заголовке
          },
        ),
        data: {"query": bin}, // Передаём IIN/BIN в body
      );
     

      if (response.statusCode == 200) {
        final List suggestions = response.data["suggestions"];
        if (suggestions.isNotEmpty) {
          final data = suggestions.first["data"];
        
          return {
            "businessOwner": data["fio"] ?? "",
            "businessName": data["name_kz"] ?? "",
            "businessStatus": data["status"] ?? "",
            "businessType": data["type"] ?? ""
          };
          
        } else {
          throw OrganizationException("Организация не найдена");
        }
      } else {
        throw DadataException("Ошибка API: ${response.statusMessage}");
      }
    } catch (e) {

      throw Exception("Ошибка запроса: $e");
    }
  }
}
