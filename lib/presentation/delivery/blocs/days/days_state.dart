import 'package:equatable/equatable.dart';

abstract class DeliveryDaysState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeliveryDaysInitial extends DeliveryDaysState {}

class DeliveryDaysLoading extends DeliveryDaysState {}

class DeliveryDaysLoaded extends DeliveryDaysState {
  final List<DateTime> days;

  DeliveryDaysLoaded(this.days);

  @override
  List<Object?> get props => [days];
}

class DeliveryDaysEmpty extends DeliveryDaysState {}

class DeliveryDaysError extends DeliveryDaysState {
  final String message;

  DeliveryDaysError(this.message);

  @override
  List<Object?> get props => [message];
}
