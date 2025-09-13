import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/mock_repos/product_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:maktub/data/models/brand_category.dart';
import 'package:maktub/data/models/brand_supplier.dart';
import 'package:maktub/data/models/cart_product.dart';
import 'package:maktub/data/models/product.dart';
import 'package:maktub/data/models/product_by_tag.dart';
import 'package:maktub/data/models/supplier_product.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  List<BrandId>? _cachedBrands;
  List<SupplierId>? _cachedSuppliers;
  int? _cachedRegionId;

  ProductBloc({required this.repository}) : super(ProductLoading()) {
    on<LoadProductByProductId>((event, emit) async {
      emit(CartProductLoading());
      try {
        final product = await repository.fetchProductById(
          productId: event.productId,
        );

        emit(ProductLoadedById(cartProduct: product));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<ClearProductSuggestions>((event, emit) async{
      emit(ProductsLoadedByTag(tagProducts: []));
    });

    on<LoadProductsByTag>((event, emit) async {
      emit(CartProductLoading());
      try {

        final products = await repository.getProductByTag(
          regionId: event.regionId,
          tag: event.tag,
        );
        emit(ProductsLoadedByTag(tagProducts: products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<LoadBothProductAndSuppliers>((event, emit) async {
      try {
        final data = await repository.fetchProducts(
          regionId: event.regionId,
          categoryId: event.categoryId,
          limit: 10,
        );

        final products = data.map((json) => Product.fromJson(json)).toList();

        final suppliers = await repository.fetchProductSuppliers(
          regionId: event.regionId,
          productId: event.productId,
        );

        final supplierProduct =
            suppliers.map((json) => SupplierProduct.fromJson(json)).toList();

        emit(
          ProductCombinedLoaded(products: products, suppliers: supplierProduct),
        );
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<LoadProducts>(_onLoadProducts);
    on<LoadProductSuppliers>(_onLoadProductSuppliers);
    on<SupplierBrandLoad>(_onSupplierBrandLoaded);
  }

  List<BrandId>? get cachedBrands => _cachedBrands;
  List<SupplierId>? get cachedSuppliers => _cachedSuppliers;
  int? get cachedRegionId => _cachedRegionId;

  Future<void> _onSupplierBrandLoaded(
    SupplierBrandLoad event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final response = await repository.fetchBrands(regionId: event.regionId);

      final secondResponse = await repository.fetchSuppliers(
        regionId: event.regionId,
      );

      final brands = response.map((json) => BrandId.fromJson(json)).toList();

      final suppliers =
          secondResponse.map((json) => SupplierId.fromJson(json)).toList();

      _cachedBrands = brands;
      _cachedSuppliers = suppliers;
      _cachedRegionId = event.regionId;
      emit(BrandSupplierLoaded(brands: brands, suppliers: suppliers));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductSuppliers(
    LoadProductSuppliers event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final response = await repository.fetchProductSuppliers(
        regionId: event.regionId,
        productId: event.productId,
      );

      final supplierProduct =
          response.map((json) => SupplierProduct.fromJson(json)).toList();
          
      emit(SupplierProductLoaded(supplierProduct: supplierProduct));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    if (event.offset == 0) {
      emit(ProductLoading());
    }

    try {
      final response = await repository.fetchProducts(
        regionId: event.regionId,
        brandId: event.brandId,
        supplierId: event.supplierId,
        categoryId: event.categoryId,
        tag: event.tag,
        limit: event.limit,
        offset: event.offset,
      );

      final secondResponse = await repository.fetchBrandCategory(
        regionId: event.regionId,
        categoryId: event.categoryId,
      );
      final brandSuppliers =
          secondResponse.map((json) => BrandSupplier.fromJson(json)).toList();

      final newProducts =
          response.map((json) => Product.fromJson(json)).toList();
      List<Product> allProducts = [];

      if (currentState is ProductLoaded && event.offset > 0) {
        allProducts = [...currentState.products, ...newProducts];
      } else {
        allProducts = newProducts;
      }

      emit(
        ProductLoaded(
          products: allProducts,
          brandSuppliers: brandSuppliers,
          selectedBrandId: event.brandId,
          selectedSupplierId: event.supplierId,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
