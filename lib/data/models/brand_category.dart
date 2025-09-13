class BrandSupplier {
  final int supplierId;
  final int brandId;
  final String supplierName;
  final String brandName;

  BrandSupplier({
    required this.brandId,
    required this.brandName,
    required this.supplierId,
    required this.supplierName,
  });

  factory BrandSupplier.fromJson(Map<String, dynamic> json) {
    return BrandSupplier(
      brandId: json['brand_id'],
      brandName: json['brand_name'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_name': brandName,
      'brand_id': brandId,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
    };
  }
}
