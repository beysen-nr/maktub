// lib/data/repositories/order_repository.dart

import 'package:intl/intl.dart';
import 'package:maktub/data/dto/order_create_dto.dart';
import 'package:maktub/data/models/order.dart';
import 'package:maktub/data/models/order_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final SupabaseClient client;

  OrderRepository({required this.client});

  // Future<void> createOrder(OrderCreateDto order) async {
  //   // Сначала создаём сам заказ (order)
  //   final orderInsert = await client.from('order').insert({
  //     'organization_id': order.organizationId,
  //     'supplier_id': order.supplierId,
  //     'delivery_address': order.deliveryAddress,
  //     'delivery_date': order.deliveryDate.toIso8601String(),
  //     'total_amount': order.totalAmount,
  //     'final_price': order.finalPrice,
  //     'otp': order.otp,
  //     'status': order.status,
  //     'address_point': order.addressPoint,
  //     if (order.usedPromocodeId != null)
  //       'used_promocode_id': order.usedPromocodeId,
  //     if (order.note != null) 'note': order.note,
  //   }).select('id').single();

  //   final orderId = orderInsert['id'] as int;

  //   // Затем создаём связанные order_item записи
  //   final items = order.items.map((item) => {
  //         'order_id': orderId,
  //         'product_id': item.productId,
  //         'quantity': item.quantity,
  //         'price': item.price,
  //         'total_price': item.totalPrice,
  //         if (item.ndsPrice != null) 'nds_price': item.ndsPrice,
  //         if (item.finalPrice != null) 'final_price': item.finalPrice,
  //         if (item.status != null) 'status': item.status,
  //       });

  //   await client.from('order_item').insert(items.toList());
  // }

  Future<void> createOrder(OrderCreateDto order) async {
    // Вставляем заказ
    final orderInsert = await client
        .from('order')
        .insert(order.toJson()..remove('items')) // удаляем 'items' из JSON
        .select('id')
        .single();

    final orderId = orderInsert['id'] as int;

    // Вставляем позиции заказа
    // final items = order.items.map((item) {
    //   final json = item.toJson();
    //   return {
    //     ...json,
    //     'order_id': orderId,
    //   };
    // }).toList();
    final spIds = order.items.map((e) => e.spId).toList();
    final newQuantities = order.items.map((e) => e.quantity).toList();

    final spRecords = await client
        .from('supplier_product')
        .select('id, nomenclature_number')
        .inFilter('id', spIds);

    final spIdToNomenclature = {
      for (var sp in spRecords) sp['id']: sp['nomenclature_number'],
    };

    final items = order.items.map((item) {
      final json = item.toJson();
      return {
        ...json,
        'order_id': orderId,
        'nomenclature_number': spIdToNomenclature[item.spId],
      };
    }).toList();

    await client.rpc(
      'update_supplier_quantities',
      params: {'sp_ids': spIds, 'new_quantities': newQuantities},
    );

    await client.from('order_item').insert(items);
  }

  Future<void> cancelOrder({
    required int orderId,
    required String reason,
    required int organizationId,
    required int supplierId,
  }) async {
    if (reason == 'As per the customer’s desire.') {
      await client.rpc(
        'increment_cancel_count',
        params: {'org_id': organizationId},
      );
    }
    {
      await client.rpc(
        'increment_cancel_count_supplier',
        params: {'sup_id': supplierId},
      );
    }
    await client
        .from('order')
        .update({'status': 4, 'cancelled_reason': reason})
        .eq('id', orderId);
  }

  Future<List<OrderItem>> loadOrderItems(int orderId) async {
    final response = await client
        .from('order_item')
        .select('''
        *,
        product (
          image_url, name_kz, barcode, unit
        )
      ''')
        .eq('order_id', orderId);

    return (response as List).map((e) => OrderItem.fromJson(e)).toList();
  }

  Future<void> leaveReview({
    required int orderId,
    required int rating,
    required String review,
  }) async {
    await client
        .from('order')
        .update({'rating': rating, 'feedback': review})
        .eq('id', orderId);
  }

    Future<void> orderDelivered({
    required int orderId,
  }) async {
    await client
        .from('order')
        .update({'status': 3})
        .eq('id', orderId);
  }

  Future<List<Order>> loadOrders({
    required int organizationId,
    required String organizationName,
  }) async {
    final now = DateTime.now();
    final date45DaysAgo = now.subtract(Duration(days: 45));
    final dateFilter = DateFormat('yyyy-MM-dd').format(date45DaysAgo);

    final organizationOrders = await client
        .from('order')
        .select('''
    *,
    supplier (
      name, supplier_id
    )
  ''')
        .eq('organization_id', organizationId)
        .gte('delivery_date', dateFilter);

    final orders = (organizationOrders as List)
        .map((e) => Order.fromJson(e))
        .toList();

    if (orders.isEmpty) return [];

    return orders.map((order) {
      return Order(
        deliveryName: order.deliveryName,
        supplierBin: order.supplierBin,
        supplierName: order.supplierName,
        id: order.id,
        organizationId: order.organizationId,
        supplierId: order.supplierId,
        createdAt: order.createdAt,
        status: order.status,
        totalAmount: order.totalAmount,
        deliveryAddress: order.deliveryAddress,
        deliveryDate: order.deliveryDate,
        otp: order.otp,
        note: order.note,
        orderDate: order.orderDate,
        finalPrice: order.finalPrice,
        addressPoint: order.addressPoint,
        deliveryTransferedTimes: order.deliveryTransferedTimes,
        usedPromocodeId: order.usedPromocodeId,
        items:
            // groupedItems[order.id] ??
            [],
        organizationName: organizationName,
        rating: order.rating,
      );
    }).toList();
  }
}
