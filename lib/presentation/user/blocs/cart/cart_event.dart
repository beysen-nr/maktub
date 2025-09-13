part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}


class CheckPromoCode extends CartEvent {
  final String code;
  CheckPromoCode(this.code);
}


class PromoInitial extends CartState {}

class PromoChecking extends CartState {}

class PromoValid extends CartState {
  final double discountAmount;
  PromoValid(this.discountAmount);
}

class PromoInvalid extends CartState {
  final String message;
  PromoInvalid(this.message);
}


class LoadCart extends CartEvent {
  final int organizationId;
  final int regionid;
  const LoadCart(this.organizationId, this.regionid);
}

class AddCartItem extends CartEvent {
  final int regionId;
  final int organizationId;
  final CartItem item;
  const AddCartItem(this.item, this.organizationId, this.regionId);

  @override
  List<Object?> get props => [item];
}

class UpdateCartItemQuantity extends CartEvent {
  final int organizationId;
  final int regionId;
  final int cartItemId;
  final double newQuantity;
  const UpdateCartItemQuantity({required this.cartItemId, required this.newQuantity,required this.organizationId, required this.regionId});

  @override
  List<Object?> get props => [cartItemId, newQuantity];
}


class UpdateMultipleCartItemsQuantity extends CartEvent {
  final int organizationId;
  final int regionId;
  final List<Map<String, dynamic>> updates;

  const UpdateMultipleCartItemsQuantity({required this.updates, required this.organizationId, required this.regionId});

  @override
  List<Object> get props => [updates];
}


class RemoveSupplierItems extends CartEvent {
  final int organizationId;
  final int regionId;
  final int supplierId;
  const RemoveSupplierItems( {required this.supplierId,  required this.organizationId, required this.regionId});

  @override
  List<Object?> get props => [supplierId];
}


class RemoveCartItem extends CartEvent {
  final int organizationId;
  final int regionId;

  final int cartItemId;
  const RemoveCartItem( {required this.cartItemId,  required this.organizationId, required this.regionId});

  @override
  List<Object?> get props => [cartItemId];
}

class ClearCart extends CartEvent {
  final int organizationId;
  final int regionId;
  const ClearCart({required this.organizationId, required this.regionId});
}


class LoadPromo extends CartEvent {
  final int organizationId;
  const LoadPromo(this.organizationId);
}




