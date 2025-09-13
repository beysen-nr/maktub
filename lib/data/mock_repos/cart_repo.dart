import 'package:maktub/data/models/cart_supplier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';

class CartRepository {
  final SupabaseClient supabase;

  CartRepository({required this.supabase});

  Future<List<CartItem>> getCartItems(int organizationId, int regionId) async {
  final response = await supabase
      .rpc('get_cart_items', params: {'org_id': organizationId, 'lang': 'kz', 'region_input': regionId});

  return (response as List)
      .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
      .toList();
  }


  Future<List<CartSupplier>> getCartSuppliers(int organizationId, int regionId) async {
  final response = await supabase
      .rpc('get_cart_suppliers', params: {'org_id': organizationId, 'region_input': regionId});

  return (response as List)
      .map((item) => CartSupplier.fromJson(item as Map<String, dynamic>))
      .toList();
  }


    Future<bool> checkSupplier(String supplierId) async {
  final response = await supabase
      .from('supplier').select().eq('supplier_id', supplierId);

  return response.isEmpty;
  }



    Future<void> addToCart(CartItem item) async {
      await supabase.rpc('add_to_cart', params: {
      'p_organization_id': item.organizationId,
      'p_sp_id': item.supplierProductId,
      'p_quantity': item.quantity,
      'p_supplier_id': item.supplierId
    });

  }

  Future<void> updateCartItemQuantity(int cartItemId, double newQuantity) async {
     await supabase.rpc('update_cart_item_quantity', params: {
    'cart_item_id': cartItemId,
    'new_quantity': newQuantity,
  });
  }

  Future<void> removeCartItem(int cartItemId) async {
    await supabase
        .from('cart_item')
        .delete()
        .eq('id', cartItemId);
  }

  Future<void> clearCart(int organizationId) async {
  await supabase.rpc('clear_cart', params: {
    'org_id': organizationId,
  });
  }

    Future<void> clearCartSupplier(int organizationId, int supplierId) async {
  await supabase.from('cart_item').delete().eq('supplier_id', supplierId);
  }

}
