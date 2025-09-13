import 'package:equatable/equatable.dart';
import 'package:maktub/data/models/order.dart';

abstract class DeliveryOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeliveryOrdersInitial extends DeliveryOrdersState {}

class DeliveryOrdersLoading extends DeliveryOrdersState {}

class DeliveryOrdersLoaded extends DeliveryOrdersState {
  final List<Order> orders;

  DeliveryOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class DeliveryOrdersEmpty extends DeliveryOrdersState {}

class DeliveryOrdersError extends DeliveryOrdersState {
  final String message;

  DeliveryOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
