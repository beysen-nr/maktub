class TagProduct {
  final int productId;
  final String productNameKz;
  final String productNameRu;
  

  TagProduct({
    required this.productId,
    required this.productNameKz,
    required this.productNameRu,
  });

factory TagProduct.fromJson(Map<String, dynamic> json) {
  return TagProduct(
    productId: json['product_id'],
    productNameKz: json['name_kz'],
    productNameRu: json['name_ru'],
  );
}


  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name_kz': productNameKz,
      'name_ru': productNameRu,
    };
  }
}
