class CartProduct {
  final int productId;
  final String productNameKz;
  final String productNameRu;
  final String productNameUs;
  final int categoryId;
  final int brandId;
  final List<String> imageUrl;
  final String description;
  final String netContent;
  final int unit;

  CartProduct({
    required this.productId,
    required this.productNameKz,
    required this.productNameRu,
    required this.productNameUs,
    required this.categoryId,
    required this.brandId,
    required this.imageUrl,
    required this.description,
    required this.netContent,
    required this.unit
  });

factory CartProduct.fromJson(Map<String, dynamic> json) {
  return CartProduct(
    unit: json['unit'],
    productId: json['product_id'],
    productNameKz: json['name_kz'],
    productNameRu: json['name_ru'],
    productNameUs: json['name_us'],
    categoryId: json['category_id'],
    brandId: json['brand_id'],
    imageUrl: List<String>.from(json['image_url']),
    description: json['description'],
    netContent: json['net_content'],
  );
}


  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name_kz': productNameKz,
      'product_name_ru': productNameRu,
      'product_name_us': productNameUs,
      'category_id': categoryId,
      'brand_id': brandId,
      'image_url': imageUrl,
      'description': description,
    };
  }
}
