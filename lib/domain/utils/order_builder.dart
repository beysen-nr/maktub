import 'package:maktub/data/dto/order_create_dto.dart';
import 'package:maktub/data/dto/order_item_create_dto.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';


OrderCreateDto buildOrderFromCart({
  required List<ValidatedCartItem> cartItems,
  required int organizationId,
  required int supplierId,
  required String deliveryAddress,
  required DateTime deliveryDate,
  required double deliveryFee,
  required int otp,
  required int status,
  required int ndsPercentage,
  required List<double> addressPoint,
  required String nameOfPoint,
  String? note,
  int? usedPromocodeId,
  Map<int, double>? itemDiscounts,
}) {
  final items = cartItems.map((validated) {
    final item = validated.item;
    final discount = itemDiscounts?[item.id] ?? 0;
    return OrderItemCreateDto.fromCartItem(item, discount: discount, ndsPercentage: ndsPercentage);
  }).toList();

  final totalAmount = items.fold(0.0, (sum, i) => sum + i.totalPrice);
final finalPrice = double.parse(
  (items.fold(0.0, (sum, i) => sum + (i.finalPrice ?? i.totalPrice)) + deliveryFee)
      .toStringAsFixed(2),
);

  return OrderCreateDto(
    nameOfPoint: nameOfPoint,
    addressPoint: addressPoint,
    organizationId: organizationId,
    supplierId: supplierId,
    deliveryAddress: deliveryAddress,
    deliveryDate: deliveryDate,
    items: items,
    totalAmount: totalAmount,
    finalPrice: finalPrice,
    otp: otp,
    status: 1,
    
    note:  note,
    usedPromocodeId: usedPromocodeId,
  );
}

