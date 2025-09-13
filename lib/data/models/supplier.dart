class Supplier {
  final String supplierId;
  final String name;
  final String address;
  final String mainPhone;
  final String? optionalPhone;
  final String email;
  final String? description;
  final int? cancelCount;
  final bool? active;
  final DateTime? createdAt;
  final double? averageRating;
  final int id;
  final int? minOrderAmount;
  final int? minOrderItem;
  final String? imageLink;

  Supplier({
    required this.supplierId,
    required this.name,
    required this.address,
    required this.mainPhone,
    this.optionalPhone,
    required this.email,
    this.description,
    this.cancelCount,
    this.active,
    this.createdAt,
    this.averageRating,
    required this.id,
    this.minOrderAmount,
    this.minOrderItem,
    this.imageLink,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: json['supplier_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      mainPhone: json['main_phone'] as String,
      optionalPhone: json['optional_phone'] as String?,
      email: json['email'] as String,
      description: json['description'] as String?,
      cancelCount: json['cancel_count'] as int?,
      active: json['active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      id: json['id'] as int,
      minOrderAmount: json['min_order_amount'] as int?,
      minOrderItem: json['min_order_item'] as int?,
      imageLink: json['image_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'name': name,
      'address': address,
      'main_phone': mainPhone,
      'optional_phone': optionalPhone,
      'email': email,
      'description': description,
      'cancel_count': cancelCount,
      'active': active,
      'created_at': createdAt?.toIso8601String(),
      'average_rating': averageRating,
      'id': id,
      'min_order_amount': minOrderAmount,
      'min_order_item': minOrderItem,
      'image_link': imageLink,
    };
  }
}
