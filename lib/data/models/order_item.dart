class OrderItem {
  final int id;
  final int orderId;
  final double quantity;
  final double price;
  final double totalPrice;
  final String image;
  // final int spId;
  final String productName;
  final double supplierQuantity;
  final String barcode;
  final int? productId;
  final double? ndsPrice;
  final double? finalPrice;
  final int? status;
  final String? nomenclatureNumber;
  final int unit;
  

  OrderItem({
    // required this.spId,
    required this.barcode,
    required this.supplierQuantity,
    required this.productName,
    required this.image,
    required this.id,
    required this.orderId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.unit,
    this.nomenclatureNumber,
    this.productId,
    this.ndsPrice,
    this.finalPrice,
    this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      // spId: json['sp_id'],
      barcode: json['product']['barcode'],
      unit: json['product']['unit'],
      supplierQuantity: json['supplier_quantity'].toDouble(),
      productName: json['product']['name_kz'],
      image: (json['product']['image_url'] as List).cast<String>().first,
      id: json['id'],
      orderId: json['order_id'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      price: json['price']?.toDouble() ?? 0.0,
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
      productId: json['product_id'],
      ndsPrice: json['nds_price'] != null ? (json['nds_price'] as num).toDouble() : null,
      finalPrice: json['final_price']?.toDouble(),
      status: json['status'],
      nomenclatureNumber: json['nomenclature_number']

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      // 'sp_id':spId,
      if (productId != null) 'product_id': productId,
      if (ndsPrice != null) 'nds_price': ndsPrice,
      if (finalPrice != null) 'final_price': finalPrice,
      if (status != null) 'status': status,
    };
  }
}
