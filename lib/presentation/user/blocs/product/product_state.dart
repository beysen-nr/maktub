part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductLoading extends ProductState {}


class ProductCombinedLoaded extends ProductState {
  final List<Product> products;
  final List<SupplierProduct> suppliers;
  ProductCombinedLoaded({
    required this.products,
    required this.suppliers,
  });
}

class ProductLoadedById extends ProductState{
  final CartProduct  cartProduct;

  ProductLoadedById({
    required this.cartProduct
  });

}

class CartProductLoading extends ProductState {}


class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<BrandSupplier> brandSuppliers;
  final int? selectedBrandId;
  final int? selectedSupplierId;
    final bool hasMore;

  const ProductLoaded({
    required this.products,
    required this.brandSuppliers,
    this.selectedBrandId,
    this.selectedSupplierId,
      this.hasMore = true,
  });

  @override
  List<Object?> get props => [
        products,
        brandSuppliers,
        selectedBrandId,
        selectedSupplierId,
                hasMore,
      ];
}

class ProductsLoadedByTag extends ProductState {
  final List<TagProduct> tagProducts;


  const ProductsLoadedByTag({
    required this.tagProducts,
  });

  @override
  List<Object?> get props => [
        tagProducts,

      ];
}



class BrandSupplierLoaded extends ProductState {
  final List<BrandId> brands;
  final List<SupplierId> suppliers;


  const BrandSupplierLoaded({
    required this.brands,
    required this.suppliers,
  });

  @override
  List<Object?> get props => [
        brands,
        suppliers,

      ];
}


class FavoriteProductLoading extends ProductState {}


class FavoriteProductLoaded extends ProductState {
  final List<Product> products;
  const FavoriteProductLoaded({
    required this.products,
  });

  @override
  List<Object?> get props => [
        products,
        
      ];
}


class SupplierProductLoaded extends ProductState {
  final List<SupplierProduct> supplierProduct;


  const SupplierProductLoaded({
    required this.supplierProduct,

  });

  @override
  List<Object?> get props => [
        supplierProduct,
];
}



class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
