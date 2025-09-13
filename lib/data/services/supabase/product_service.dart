import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> getProducts(
    int regionId, int limitNum, int offsetNum, {
    String? brand,
    String? supplier,
    int? categoryId,
  }) async {
    final response = await client.rpc(
      'get_products',
      params: {
        'region_input': regionId,
        if (brand != null) 'brand_input': brand,
        if (supplier != null) 'supplier_input': supplier,
        if (categoryId != null) 'category_input': categoryId,
        'limit_num': limitNum,
        'offset_num': offsetNum
      },
    );

    
    if (response is List) {
      return response.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  Future<List<Map<String, dynamic>>> getBrandSupplier(
    int regionId, int categoryId, ) async {
    final response = await client.rpc(
      'get_suppliers_and_brands_by_category_region',
      params: {
        'region_input': regionId,
        'category_input': categoryId,
      },
    );

    if (response is List) {
      return response.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }
}

//all products gets by region
//default region == astana
//get hit//products that hav more supppliers
