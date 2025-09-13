import 'package:maktub/data/dto/order_item_create_dto.dart';

class OrderCreateDto {
  final int organizationId;
  final int supplierId;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final List<OrderItemCreateDto> items;
  final double totalAmount;
  final double finalPrice;
  final int otp;
  final int status;
  final List<double> addressPoint;
  final String nameOfPoint;
  final String? note;
  final int? usedPromocodeId;

  OrderCreateDto({
    required this.nameOfPoint,
    required this.organizationId,
    required this.supplierId,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.items,
    required this.totalAmount,
    required this.finalPrice,
    required this.otp,
    required this.status,
    required this.addressPoint,
    this.note,
    this.usedPromocodeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'supplier_id': supplierId,
      'delivery_address': deliveryAddress,
      'delivery_date': deliveryDate.toIso8601String(),
      'total_amount': totalAmount,
      'final_price': finalPrice,
     'name_of_point':nameOfPoint,
      'otp': otp,
       'address_point': {
        'type': 'Point',
        'coordinates': addressPoint,
      },
      'status': 1,
      if (note != null) 'note': note,
      if (usedPromocodeId != null) 'used_promocode_id': usedPromocodeId,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
