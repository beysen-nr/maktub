import 'package:equatable/equatable.dart';

abstract class AdEvent extends Equatable {
  const AdEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarousel extends AdEvent {
  final int regionId;
  LoadCarousel(this.regionId);
}
