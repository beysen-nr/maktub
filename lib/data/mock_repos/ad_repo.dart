import 'package:maktub/data/models/carousel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdRepository {
  Future<List<CarouselModel>> fetchCarousels(int regionId) async {
    final now = DateTime.now().toIso8601String();

    final data =
        await Supabase.instance.client
            .rpc('get_active_ad_carousel', params: {'current_ts': now, 'in_region_id':regionId})
            .select();


    return (data as List).map((e) => CarouselModel.fromJson(e)).toList();
  }
}
