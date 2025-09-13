import 'package:maktub/data/models/order.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;


  OrderLoaded(this.orders);

  
}


class OrderCancelled extends OrderState {}

class OrderSuccess extends OrderState {}

class OrderFailure extends OrderState {
  final String message;

  OrderFailure(this.message);
}
