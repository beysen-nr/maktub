import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/domain/repositories/order_repo.dart';
import 'package:maktub/presentation/user/blocs/order/order_event.dart';
import 'package:maktub/presentation/user/blocs/order/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;

  OrderBloc(this.repository) : super(OrderInitial()) {
    on<CreateOrderRequested>((event, emit) async {
      emit(OrderLoading());

      try {
        await repository.createOrder(event.order);
        emit(OrderSuccess());
      } catch (e) {
        emit(OrderFailure(e.toString()));
      }
    });

    on<CancelOrder>((event, emit) async {
      try {
        await repository.cancelOrder(
          orderId: event.orderId,
          reason: event.reasonValue,
          organizationId: event.organizationId,
          supplierId: event.supplierId,
        );
        emit(OrderCancelled());
      } catch (e) {
        emit(OrderFailure(e.toString()));
      }
    });

    on<LoadOrders>((event, emit) async {
      emit(OrderLoading());

      try {
        final orders = await repository.loadOrders(organizationId: event.orgainzationId, organizationName: event.organizationName);
        emit(OrderLoaded(orders));
      } catch (e) {
        emit(OrderFailure(e.toString()));
      }
    });
  }
}
