part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartLoading extends CartState {
}

class CartLoaded extends CartState {
  final List<ValidatedCartItem> items;
  final List<CartSupplier> suppliers;
  const CartLoaded(this.items, this.suppliers);

  @override
  List<Object?> get props => [items];
}

class CartEmpty extends CartState {
}


class CartError extends CartState {
  final String message;
  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class ValidatedCartItem {
  final CartItem item;
  final bool isInStock;

  ValidatedCartItem({required this.item, required this.isInStock});

    @override
  String toString() {
    return 'ValidatedCartItem(item: ${item.productName}, quantity: ${item.quantity}, inStock: $isInStock)';
  }
}







