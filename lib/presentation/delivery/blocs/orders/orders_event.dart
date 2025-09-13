import 'package:equatable/equatable.dart';

abstract class DeliveryOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDeliveryOrders extends DeliveryOrdersEvent {
  final DateTime day;

  FetchDeliveryOrders(this.day);

  @override
  List<Object?> get props => [day];
}