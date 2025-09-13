class PromoModel {
  final int id;
  final DateTime createdAt;
  final int? supplierId;
  final int? organizationId;
  final int? regionId;
  final String? promocode;
  final int? usedTimes;
  final int? useCount;
  final bool? isActive;
  final DateTime? tillDate;
  final int? discount;
  final int? minOrder;
  final bool? fixedDiscount;

  PromoModel({
    required this.id,
    required this.createdAt,
    this.supplierId,
    this.organizationId,
    this.regionId,
    this.promocode,
    this.usedTimes,
    this.useCount,
    this.isActive,
    this.tillDate,
    this.discount,
    this.minOrder,
    this.fixedDiscount,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      supplierId: json['supplier_id'],
      organizationId: json['organization_id'],
      regionId: json['region_id'],
      promocode: json['promocode'],
      usedTimes: json['used_times'],
      useCount: json['use_count'],
      isActive: json['is_active'],
      tillDate: json['till_date'] != null ? DateTime.parse(json['till_date']) : null,
      discount: json['discount'],
      minOrder: json['min_order'],
      fixedDiscount: json['fixed_discount'],
    );
  }


  @override
  String toString() {
    return 'PromoModel(promocode: $promocode, organizationId: $organizationId, discount: $discount, fixedDiscount: $fixedDiscount)';
  }
}
