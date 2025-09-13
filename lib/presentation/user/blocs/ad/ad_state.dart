import 'package:equatable/equatable.dart';
import 'package:maktub/data/models/carousel.dart';

abstract class AdState extends Equatable {
  const AdState();

  @override
  List<Object?> get props => [];
}

class CarouselInitial extends AdState {}

class CarouselLoading extends AdState {}

class CarouselLoaded extends AdState {
  final List<CarouselModel> banners;

  const CarouselLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class CarouselError extends AdState {
  final String message;

  const CarouselError(this.message);

  @override
  List<Object?> get props => [message];
}
