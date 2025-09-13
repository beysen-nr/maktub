import 'package:maktub/data/dto/order_create_dto.dart';

abstract class OrderEvent {}

class CreateOrderRequested extends OrderEvent {
  final OrderCreateDto order;

  CreateOrderRequested(this.order);
}

class CancelOrder extends OrderEvent {
  final int organizationId;
  final int supplierId;
  final String reasonValue;
  final int orderId;
  CancelOrder({required this.reasonValue, required this.orderId,
  required this.organizationId, required this.supplierId
  });
}





class LoadOrders extends OrderEvent {
  final int orgainzationId;
  final String organizationName;
  LoadOrders({required this.orgainzationId, required this.organizationName});
}

