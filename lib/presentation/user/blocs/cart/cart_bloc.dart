import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maktub/data/mock_repos/cart_repo.dart';
import 'package:maktub/data/mock_repos/product_repo.dart';
import 'package:maktub/data/models/cart_item.dart';
import 'package:maktub/data/models/cart_supplier.dart';
import 'package:maktub/data/models/promo.dart';
import 'package:maktub/data/services/dadata_service.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:rxdart/rxdart.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;
  final ProductRepository pRepository;
  DadataService dadataService = DadataService();

  CartBloc({required this.repository, required this.pRepository})
    : super(CartLoading()) {
    on<LoadCart>(_onLoadCart);
    on<AddCartItem>(_onAddItem);
    on<UpdateCartItemQuantity>(
      _onUpdateQty,
      transformer: debounce(const Duration(milliseconds: 1000)),
    );
    on<RemoveCartItem>(_onRemoveItem);
    on<ClearCart>(_onClearCart);
    on<RemoveSupplierItems>(_onRemoveSupplierItems);
    on<UpdateMultipleCartItemsQuantity>(_onUpdateMultipleCartItemsQuantity);
    //     // ... другие обработчики ...
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  Future<void> _onRemoveSupplierItems(
    RemoveSupplierItems event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await repository.clearCartSupplier(
        event.organizationId,
        event.supplierId,
      );
      add(LoadCart(event.organizationId, event.regionId));
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('${e}onclear'));
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await repository.getCartItems(
        event.organizationId,
        event.regionid,
      );
      final suppliers = await repository.getCartSuppliers(
        event.organizationId,
        event.regionid,
      );
      await Future.delayed(
        const Duration(milliseconds: 700),
      ); 
      final validatedItems = <ValidatedCartItem>[];

      for (final item in items) {
        final stock = item.stockQuantity; // ← используем напрямую


        validatedItems.add(
          ValidatedCartItem(item: item, isInStock: item.cartQuantity! <= stock!),
        );
      }

      if (validatedItems.isEmpty) {
        emit(CartEmpty());
      } else {
        emit(CartLoaded(validatedItems, suppliers));
      }
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('$e onload'));
    }
  }

  Future<void> _onAddItem(AddCartItem event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await repository.addToCart(event.item);

      add(LoadCart(event.organizationId, event.regionId));
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('$e onadd'));
    }
  }

  Future<void> _onUpdateQty(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoaded) return;

    try {
      emit(CartLoading());
      if (event.newQuantity == 0) {
        await repository.removeCartItem(event.cartItemId);
      } else {
        await repository.updateCartItemQuantity(
          event.cartItemId,
          event.newQuantity,
        );
      }
      add(LoadCart(event.organizationId, event.regionId));
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('$e onupdate'));
    }
  }

  Future<void> _onUpdateMultipleCartItemsQuantity(
    UpdateMultipleCartItemsQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoaded) return;

    try {
      for (var update in event.updates) {
        final cartItemId = update['cartItemId'] as int;
        final newQuantity = update['newQuantity'] as double;
        await repository.updateCartItemQuantity(cartItemId, newQuantity);
      }

      add(LoadCart(event.organizationId, event.regionId));
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('$e onupdate'));
    }
  }

  Future<void> _onRemoveItem(
    RemoveCartItem event,
    Emitter<CartState> emit,
  ) async {
    // if (state is! CartLoaded) return;

    try {
      emit(CartLoading());
      await repository.removeCartItem(event.cartItemId);

      add(LoadCart(event.organizationId, event.regionId));
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('${e}onremove'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await repository.clearCart(event.organizationId);
      add(LoadCart(event.organizationId, event.regionId));
    } on SocketException catch (e) {
      emit(CartError('Желі қатесі'));
    } catch (e) {
      emit(CartError('${e}onclear'));
    }
  }
}
