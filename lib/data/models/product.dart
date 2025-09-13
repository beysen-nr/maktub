class Product {
  final int regionId;
  final int productId;
  final String productNameKz;
  final String productNameRu;
  final String productNameUs;
  final int categoryId;
  final int brandId;
  final List<String> imageUrl;
  final int supplierId;
  final String supplierName;
  final String description;
  final double price;
  final double quantity;
  final String netContent;
  final int unit;
  bool? isInFavorites;
  

  Product({
    required this.regionId,
    required this.productId,
    required this.productNameKz,
    required this.productNameRu,
    required this.productNameUs,
    required this.categoryId,
    required this.brandId,
    required this.imageUrl,
    required this.supplierId,
    required this.supplierName,
    required this.description,
    required this.price,
    required this.quantity,
    required this.netContent,
    required this.unit,
    this.isInFavorites = false
  });

factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'],
    regionId: json['region_id'],
    productId: json['product_id'],
    productNameKz: json['product_name_kz'],
    productNameRu: json['product_name_ru'],
    productNameUs: json['product_name_us'],
    categoryId: json['category_id'],
    brandId: json['brand_id'],
    imageUrl: List<String>.from(json['image_url']),
    supplierId: json['supplier_id'],
    supplierName: json['supplier_name'],
    description: json['description'],
    netContent: json['net_content'],
    price: (json['price'] as num).toDouble(),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'region_id': regionId,
      'product_id': productId,
      'product_name_kz': productNameKz,
      'product_name_ru': productNameRu,
      'product_name_us': productNameUs,
      'category_id': categoryId,
      'brand_id': brandId,
      'image_url': imageUrl,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'description': description,
      'price': price,
    };
  }
}
