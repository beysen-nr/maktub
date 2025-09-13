  class CartSupplier {
    final String supplierName;//
    final int deliveryDay;//
    final double deliveryAmount;//
    final double deliveryFreeMinOrder;//
    final int supplierId;//
    
    final int minOrderAmount;//
    final int minOrderItem;
    final int ndsPercentage;

    CartSupplier({
      required this.supplierName,
      required this.deliveryDay,
      required this.deliveryAmount,
      required this.deliveryFreeMinOrder,
      required this.supplierId,
      required this.minOrderItem,
      required this.minOrderAmount,
      required this.ndsPercentage
    });
    
factory CartSupplier.fromJson(Map<String, dynamic> json) {
  return CartSupplier(
    supplierId: json['supplier_id'],
    supplierName: json['supplier_name'],
    deliveryDay: json['delivery_day'],
    minOrderAmount: json['min_order_amount'],
    minOrderItem: json['min_order_item'],
    ndsPercentage: json['nds_percentage'],
    deliveryAmount: (json['delivery_amount'] as num).toDouble(),
    deliveryFreeMinOrder: (json['delivery_free_min_order'] as num).toDouble(),
  );
}

    Map<String, dynamic> toJson() {
      return {
        'supplier_name': supplierName,
        'delivery_day': deliveryDay,
        'delivery_amount': deliveryAmount,
        'delivery_free_min_order': deliveryFreeMinOrder,
      };
    }
  }
