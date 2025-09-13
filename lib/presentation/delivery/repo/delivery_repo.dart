import 'package:maktub/data/models/order.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryRepository {
  SupabaseClient client = SupabaseService.client;


Future<List<DateTime>> fetchDeliveryDates() async {
  final now = DateTime.now();
  final date7DaysAgo = now.subtract(Duration(days: 7));

  final userId = SupabaseService.client.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await SupabaseService.client
      .from('order')
      .select('delivery_date')
      .inFilter('status', [2, 3])
      .gte('delivery_date', date7DaysAgo).eq('deliver_id', userId);

  if (response == null || response.isEmpty) {
    return [];
  }

final List<DateTime> deliveryDates = (response as List)
    .cast<Map<String, dynamic>>()
    .map((order) => DateTime.parse(order['delivery_date']))
    .toSet()
    .toList()
  ..sort((a, b) => a.compareTo(b)); // от новых к старым

  return deliveryDates;
}


Future<List<Order>> fetchDeliveryOrders(DateTime date) async {
  final userId = SupabaseService.client.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await SupabaseService.client
      .from('order')
      .select('''
        *,
        organization (
          name, organization_id
        )
      ''')
      .eq('deliver_id', userId)
      .eq('delivery_date', date).inFilter('status', [2,3]); // DateTime напрямую

  if (response == null || response.isEmpty) return [];


  return (response as List)
      .cast<Map<String, dynamic>>()
      .map((json) => Order.fromJson(json))
      .toList();
}

Future<Order?> fetchOrderById(int orderId) async {
  final response = await SupabaseService.client
      .from('order')
      .select('''
        *,
        organization (
          name, organization_id
        )
      ''')
      .eq('id', orderId)
      .maybeSingle();

  if (response == null) return null;

  return Order.fromJson(response as Map<String, dynamic>);
}


}
