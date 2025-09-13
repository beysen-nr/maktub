class CartItem {
  // final int id;
  final int? id;
  final String? productName;
  final double? price;
  final int organizationId;
  final String? imageUrl;
  final int? productId;
  final int supplierProductId;
  final double quantity;
  late final double? cartQuantity;
  final String? supplierName;
  final int? supplierId;
  final double? stockQuantity;
  final DateTime? addedAt;
  final int unit;


  CartItem({
    required this.unit,
    this.cartQuantity,
    this.id,
    this.productName,
    this.price,
    this.imageUrl,
    required this.organizationId,
    this.productId,
    required this.supplierProductId,
    required this.quantity,
    this.supplierName,
    this.supplierId,
    this.stockQuantity,
    this.addedAt,

  });
factory CartItem.fromJson(Map<String, dynamic> json) {
  return CartItem(
    id: json['cart_item_id'],
    unit: json['unit'],
    supplierId: json['supplier_id'],
    cartQuantity: (json['cart_quantity'] as num?)?.toDouble(),
    productName: json['product_name'],
    stockQuantity: (json['stock_quantity'] as num?)?.toDouble(),
    supplierName: json['supplier_name'],
    imageUrl: json['image_url'],
    price: (json['price'] as num?)?.toDouble(),
    organizationId: json['organization_id'],
    productId: json['product_id'],
    supplierProductId: json['sp_id'],
    quantity: (json['quantity'] as num).toDouble(),
    addedAt: json['added_at'] != null
        ? DateTime.parse(json['added_at'])
        : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'organization_id': organizationId,
      'product_id': productId,
      'sp_id': supplierProductId,
      'quantity': quantity,
      'added_at': addedAt?.toIso8601String(),

    };
  }


  @override
String toString() {
  return '''
CartItem(
  id: $id,
  productName: $productName,
  price: $price,
  imageUrl: $imageUrl,
  organizationId: $organizationId,
  productId: $productId,
  supplierProductId: $supplierProductId,
  quantity: $quantity,
  supplierName: $supplierName,
  supplierId: $supplierId,
  stockQuantity: $stockQuantity,
  addedAt: $addedAt
)
''';
}

}
