class BrandId {
  final int brandId;
  final String brandName;

  BrandId({
    required this.brandId,
    required this.brandName,

  });

  factory BrandId.fromJson(Map<String, dynamic> json) {
    return BrandId(
      brandId: json['brand_id'],
      brandName: json['brand_name'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_name': brandName,
      'supplier_id': brandId,
    };
  }
}

class SupplierId {
  final int supplierId;
  final String supplierName;

  SupplierId({
    required this.supplierId,
    required this.supplierName,

  });

  factory SupplierId.fromJson(Map<String, dynamic> json) {
    return SupplierId(
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_name': supplierName,
      'supplier_id': supplierId,
    };
  }
}