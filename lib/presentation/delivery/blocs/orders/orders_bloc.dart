import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/models/order.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_event.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_state.dart';
import 'package:maktub/presentation/delivery/repo/delivery_repo.dart';

class DeliveryOrdersBloc extends Bloc<DeliveryOrdersEvent, DeliveryOrdersState> {
  final DeliveryRepository repository;

  DeliveryOrdersBloc({required this.repository}) : super(DeliveryOrdersInitial()) {
    on<FetchDeliveryOrders>(_onFetchDeliveryOrders);
  }

  Future<void> _onFetchDeliveryOrders(
    FetchDeliveryOrders event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    emit(DeliveryOrdersLoading());

    try {
      final orders = await repository.fetchDeliveryOrders(event.day);

      if (orders.isEmpty) {
        emit(DeliveryOrdersEmpty());
      } else {
        emit(DeliveryOrdersLoaded(orders));
      }
    } catch (e) {
      emit(DeliveryOrdersError(e.toString()));
    }
  }
}
