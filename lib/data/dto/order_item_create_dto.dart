import 'package:maktub/data/models/cart_item.dart';

class OrderItemCreateDto {
  final int productId;
  final double quantity;
  final int spId;
  final double price;
  final double totalPrice;
  final double supplierQuantity;
  final double? ndsPrice;
  final double? finalPrice;
  final int? status;

  OrderItemCreateDto({
    required this.spId,
    required this.supplierQuantity,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.ndsPrice,
    this.finalPrice,
    this.status,
  });

  factory OrderItemCreateDto.fromCartItem(CartItem cartItem, {double? discount, int? ndsPercentage}) {
    final baseTotal = (cartItem.price ?? 0) * (cartItem.cartQuantity ?? 0);
  final finalTotal = double.parse(
  (discount != null ? baseTotal - discount : baseTotal).toStringAsFixed(2),
);

    final ndsPrice = double.parse(
      (finalTotal - finalTotal/(1+ndsPercentage!/100)).toStringAsFixed(2));
    return OrderItemCreateDto(
      spId:  cartItem.supplierProductId,
      supplierQuantity: cartItem.quantity,
      productId: cartItem.productId!,
      quantity: cartItem.cartQuantity ?? 0,
      price: cartItem.price ?? 0,
      totalPrice: baseTotal,
      finalPrice: finalTotal,
      ndsPrice: ndsPrice
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'nds_price': ndsPrice,
      'supplier_quantity': supplierQuantity,
      if (finalPrice != null) 'final_price': finalPrice,
      if (status != null) 'status': status,
    };
  }
}
