import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/mock_repos/ad_repo.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_event.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final AdRepository repository;

  AdBloc(this.repository) : super(CarouselInitial()) {
    on<LoadCarousel>(_onLoad);
  }

  Future<void> _onLoad(LoadCarousel event, Emitter<AdState> emit) async {
    emit(CarouselLoading());
    try {
      final banners = await repository.fetchCarousels(event.regionId);
      emit(CarouselLoaded(banners));
    } catch (e) {
      emit(CarouselError(e.toString()));
    }
  }
}
