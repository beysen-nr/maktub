import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/presentation/delivery/blocs/days/days_event.dart';
import 'package:maktub/presentation/delivery/blocs/days/days_state.dart';
import 'package:maktub/presentation/delivery/repo/delivery_repo.dart';

class DeliveryDaysBloc extends Bloc<DeliveryDaysEvent, DeliveryDaysState> {
  final DeliveryRepository repository;

  DeliveryDaysBloc({required this.repository}) : super(DeliveryDaysInitial()) {
    on<FetchDeliveryDays>(_onFetchDeliveryDays);
  }

  Future<void> _onFetchDeliveryDays(
    FetchDeliveryDays event,
    Emitter<DeliveryDaysState> emit,
  ) async {
    emit(DeliveryDaysLoading());

    try {
      final dates = await repository.fetchDeliveryDates();

      if (dates.isEmpty) {
        emit(DeliveryDaysEmpty());
      } else {
        emit(DeliveryDaysLoaded(dates));
      }
    } catch (e) {
      emit(DeliveryDaysError(e.toString()));
    }
  }
}
