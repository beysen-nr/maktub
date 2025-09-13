  class SupplierProduct {
    final int spId;
    final String supplierName;
    final double price;
    final int deliveryDay;
    final double deliveryAmount;
    final double deliveryFreeMinOrder;
    final double quantity;
    final int supplierId;
    final int minOrderAmount;

    SupplierProduct({
      required this.spId,
      required this.supplierName,
      required this.price,
      required this.quantity,
      required this.deliveryDay,
      required this.deliveryAmount,
      required this.deliveryFreeMinOrder,
      required this.supplierId,
      required this.minOrderAmount,

    });
    
factory SupplierProduct.fromJson(Map<String, dynamic> json) {
  return SupplierProduct(
    supplierId: json['supplier_id'],
    spId: json['sp_id'],
    quantity: (json['quantity'] as num).toDouble(), // ✅ фикс
    supplierName: json['supplier_name'],
    price: (json['price'] as num).toDouble(),
    deliveryDay: json['delivery_day'],
    minOrderAmount: json['min_order_amount'],
    deliveryAmount: (json['delivery_amount'] as num).toDouble(),
    deliveryFreeMinOrder: (json['delivery_free_min_order'] as num).toDouble(),
  );
}

    Map<String, dynamic> toJson() {
      return {
        'sp_id': spId,
        'supplier_name': supplierName,
        'price': price,
        'delivery_day': deliveryDay,
        'delivery_amount': deliveryAmount,
        'delivery_free_min_order': deliveryFreeMinOrder,
      };
    }
  }
