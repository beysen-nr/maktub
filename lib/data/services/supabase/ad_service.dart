import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdService extends SupabaseService {
  final SupabaseClient client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getCarouselAds() async {
    return handleRequest(() async {
      final today =
          DateTime.now().toIso8601String(); // 🔥 Текущая дата в формате ISO

      final response = await client
          .from('adCarousel')
          .select('*')
          .gte('till_date', today) // 🔥 till_date >= сегодня (ещё актуально)
          .lte(
            'from_date',
            today,
          ) // 🔥 from_date <= сегодня (уже можно показывать)
          .order('position', ascending: true); // 🔥 Сортировка по позиции

      return response;
    });
  }

  Future<List<Map<String, dynamic>>> getBannerAds(String category) async {
    return handleRequest(() async {
      final today =
          DateTime.now().toIso8601String(); // 🔥 Текущая дата в формате ISO

      final response = await client
          .from('adBanner')
          .select('*')
          .eq('category', category) // 🔥 Фильтр по категории
          .gte('till_date', today) // 🔥 till_date >= сегодня (ещё актуально)
          .lte(
            'from_date',
            today,
          ) // 🔥 from_date <= сегодня (уже можно показывать)
          .order('position', ascending: true); // 🔥 Сортировка по позиции

      return response;
    });
  }
}
