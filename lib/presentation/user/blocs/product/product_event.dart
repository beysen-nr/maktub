part of 'product_bloc.dart';



abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int regionId;
  final int? brandId;
  final int? supplierId;
  final int? categoryId;
  final String? tag;
  final int limit;
  final int offset;
  final int organizationId;

  const LoadProducts({
    required this.regionId,
    this.brandId,
    this.supplierId,
    this.categoryId,
    this.tag,
    this.limit = 20,
    this.offset = 0,
    required this.organizationId 
  });

  @override
  List<Object?> get props => [
        regionId,
        brandId,
        supplierId,
        categoryId,
        tag,
        limit,
        offset,
      ];
}

class LoadProductsByTag extends ProductEvent {
  final String tag;
  final int regionId;

  const LoadProductsByTag({
    required this.tag,
    required this.regionId
  
  });

  @override
  List<Object?> get props => [
        tag,

      ];
}


class ClearProductSuggestions extends ProductEvent {}


class LoadProductByProductId extends ProductEvent {
  final int productId;


  const LoadProductByProductId({
    required this.productId,
  
  });

  @override
  List<Object?> get props => [
        productId,

      ];
}

class SupplierBrandLoad extends ProductEvent {
  final int regionId;


  const SupplierBrandLoad({
    required this.regionId,
  
  });

  @override
  List<Object?> get props => [
        regionId,

      ];
}

class AddToFavorites extends ProductEvent{
  final int regionId;
  final int organizationId;
  final int productId;

  const AddToFavorites({
    required this.regionId,
    required this.organizationId,
    required this.productId
  });


}


class DeleteFromFavorites extends ProductEvent{
  final int regionId;
  final int organizationId;
  final int productId;

  const DeleteFromFavorites({
    required this.regionId,
    required this.organizationId,
    required this.productId
  });


}



class LoadFavoriteProducts extends ProductEvent {
  final int regionId;
  final int organizationId;
  final int limit;
  final int offset;

  const LoadFavoriteProducts({
    required this.regionId,
    required this.organizationId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
        regionId,
        limit,
        offset,
      ];
}




class LoadBothProductAndSuppliers extends ProductEvent {
  final int regionId;
  final int productId;
  final int categoryId;


  const LoadBothProductAndSuppliers({
    required this.regionId,
    required this.productId,
    required this.categoryId


  });

  @override
  List<Object?> get props => [
        regionId,
        productId,
      ];
}


class LoadProductSuppliers extends ProductEvent {
  final int regionId;
  final int productId;


  const LoadProductSuppliers({
    required this.regionId,
    required this.productId,


  });

  @override
  List<Object?> get props => [
        regionId,
        productId,
      ];
}
