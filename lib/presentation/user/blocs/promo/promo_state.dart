import 'package:maktub/data/models/promo.dart';


abstract class PromoState {}

class PromoInitial extends PromoState {}

class PromoLoading extends PromoState {}

class PromoUpdated extends PromoState {}

class PromoLoaded extends PromoState {
  final PromoModel promo;

  PromoLoaded(this.promo);
}

class PromoError extends PromoState {
  final String code;
   PromoError({required this.code});

  @override
  List<Object?> get props => [code];
}
