import 'package:maktub/data/models/cart_product.dart';
import 'package:maktub/data/models/product_by_tag.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  final SupabaseClient supabase;

  ProductRepository({required this.supabase});

  Future<int> getStockQuantity(int supplierProductId) async {
    final response = await supabase.rpc(
      'get_stock_quantity',
      params: {'supplier_product_id': supplierProductId},
    );

    if (response != null && response['stock_quantity'] != null) {
      return response['stock_quantity'] as int;
    } else {
      return 0;
    }
  }


Future<void> addToFavorites({
    required int regionId,
    required int organizationId,
    required int productId

  }) async {
     await SupabaseService.client.from('favorite_products').insert({'product_id':productId, 'region_id': regionId, 'organization_id': organizationId});
  }



Future<List<Map<String, dynamic>>> fetchFavoriteProducts({
    required int regionId,
    required int organizationId,

    int? limit,
    int? offset,
  }) async {
    final List data = await SupabaseService.client.from('favorite_products')
  .select()
  .eq('organization_id', organizationId).eq('region_id', regionId);
  
    return data.map((e) => e as Map<String, dynamic>).toList();
  }




Future<List<TagProduct>> getProductByTag({
  required int regionId,
  required String tag,
}) async {
  final List data = await SupabaseService.client.rpc(
    'get_products_by_tag_and_region',
    params: {
      'input_region_id': regionId,
      'search_tag': tag,
    },
  );
  return data
      .map((e) => TagProduct.fromJson(e as Map<String, dynamic>))
      .toList();
}



Future<void> deleteFromFavorites({
    required int regionId,
    required int organizationId,
    required int productId

  }) async {
     await SupabaseService.client.from('favorite_products').delete().eq('organization_id', organizationId).eq('product_id', productId).eq('region_id', regionId);
  }




  Future<List<Map<String, dynamic>>> fetchProducts({
    required int regionId,
    int? brandId,
    int? supplierId,
    int? categoryId,
    String? tag,
    int? limit,
    int? offset,
  }) async {
    final List data = await SupabaseService.client.rpc(
      'get_products',
      params: {
        'region_input': regionId,
        'brand_input': brandId,
        'supplier_input': supplierId,
        'category_input': categoryId,
        'tag_input': tag,
        'limit_num': limit,
        'offset_num': offset,
      },
    );
  
    return data.map((e) => e as Map<String, dynamic>).toList();
  }



  Future<List<Map<String, dynamic>>> fetchBrands({
    required int regionId,
  }) async {
    final List data = await SupabaseService.client.rpc(
      'get_brands',
      params: {
        'region_input': regionId,

      },
    );
  
    // ✅ Тут response.data — это List<dynamic>
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

   Future<CartProduct> fetchProductById({
    required int productId,
  }) async {
    final  data = await SupabaseService.client
  .from('product')
  .select()
  .eq('product_id', productId)
  .limit(1);
    return CartProduct.fromJson(data[0]);
  }





  Future<List<Map<String, dynamic>>> fetchSuppliers({
    required int regionId,
  }) async {
    final List data = await SupabaseService.client.rpc(
      'get_suppliers',
      params: {
        'region_input': regionId,

      },
    );
  
    return data.map((e) => e as Map<String, dynamic>).toList();
  }



    Future<List<Map<String, dynamic>>> fetchBrandCategory({
    required int regionId,
    required int? categoryId,
  }) async {
    final List data = await SupabaseService.client.rpc(
      'get_suppliers_and_brands_by_category_region',
      params: {
        'region_input': regionId,
        'category_input': categoryId,
      },
    );

    // ✅ Тут response.data — это List<dynamic>
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

   Future<List<Map<String, dynamic>>> fetchProductSuppliers({
    required int regionId,
    required int productId,
  }) async {
    final List data = await SupabaseService.client.rpc(
      'get_product_suppliers',
      params: {
        'region_input': regionId,
        'product_input': productId,
      },
    );

    // ✅ Тут response.data — это List<dynamic>
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
