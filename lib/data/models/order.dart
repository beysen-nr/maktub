import 'package:maktub/data/models/order_item.dart';

class Order {
  final int id;
  final int organizationId;
  final int supplierId;
  String? organizationName;
  final DateTime? createdAt;
  final int? rating;
  final int? status;
  final double totalAmount;
  final String? deliveryAddress;
  final DateTime? deliveryDate;
  final int otp;
  final String? note;
  final DateTime? orderDate;
  final double? finalPrice;
  final List<double>? addressPoint;
  final int? deliveryTransferedTimes;
  final int? usedPromocodeId;
  List<OrderItem> items; // ✅ Новое поле
  final String supplierName;
  final String supplierBin;
  final String? deliveryName;
  final String? nameOfPoint;

  Order({
    required this.supplierBin,
    required this.id,
    required this.organizationId,
    required this.supplierId,
    required this.totalAmount,
    required this.otp,
    required this.items,
    required this.supplierName,
    this.deliveryName,
    this.nameOfPoint,

    this.organizationName,
    this.rating,
    this.createdAt,
    this.status,
    this.deliveryAddress,
    this.deliveryDate,
    this.note,
    this.orderDate,
    this.finalPrice,
    this.addressPoint,
    this.deliveryTransferedTimes,
    this.usedPromocodeId,

  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
     organizationName: json['organization']?['name'] ?? '',
      deliveryName: json['delivery_name'],
      supplierBin: json['supplier']?['supplier_id']?.toString() ?? '',
      id: json['id'],
      rating: json['rating'],
      organizationId: json['organization_id'],
      supplierId: json['supplier_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      status: json['status'],
      totalAmount: double.parse(json['total_amount'].toString()),
      deliveryAddress: json['delivery_address'],
      deliveryDate: json['delivery_date'] != null ? DateTime.parse(json['delivery_date']) : null,
      otp: json['otp'],
      note: json['note'],
      orderDate: json['order_date'] != null ? DateTime.parse(json['order_date']) : null,
      finalPrice: json['final_price']?.toDouble(),
      addressPoint: json['address_point'] != null
          ? List<double>.from(json['address_point']['coordinates'])
          : null,
      deliveryTransferedTimes: json['delivery_transfered_times'],
      usedPromocodeId: json['used_promocode_id'],
      items: [], // по умолчанию пусто, будет присвоено после
supplierName: json['supplier']?['name'] ?? '',
nameOfPoint: json['name_of_point']??''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'supplier_id': supplierId,
      'created_at': createdAt?.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress,
      'delivery_date': deliveryDate?.toIso8601String(),
      'otp': otp,
      'note': note,
      'order_date': orderDate?.toIso8601String(),
      'final_price': finalPrice,
      if (addressPoint != null)
        'address_point': {
          'type': 'Point',
          'coordinates': addressPoint,
        },
      'delivery_transfered_times': deliveryTransferedTimes,
      'used_promocode_id': usedPromocodeId,
      
      'items': items.map((i) => i.toJson()).toList(), // ✅ сериализация
    };
  }
}
