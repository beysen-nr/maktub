class Address {
  final int? addressId;
  final String nameOfPoint;
  final List<double> point;
  final String commentForDelivery;
  final int organizationId;
  final int regionId;
  final String? cityName;
  final String address;
  Address({
    this.cityName,
     this.addressId,
    required this.address,
    required this.nameOfPoint,
    required this.point,
    required this.commentForDelivery,
    required this.organizationId,
    required this.regionId,
  });
factory Address.fromJson(Map<String, dynamic> json) {
  final pointJson = json['point'];
  List<double> parsedPoint = [];

  if (pointJson != null && pointJson['coordinates'] != null) {
    parsedPoint = List<double>.from(pointJson['coordinates'].map((coord) => coord.toDouble()));
  }

  return Address(
    address: json['address'] as String,
    addressId: json['address_id'] as int?,
    nameOfPoint: json['name_of_point'] as String,
    point: parsedPoint,
    commentForDelivery: json['comment_for_delivery'] as String? ?? '',
    organizationId: json['organization_id'] as int,
    regionId: json['region_id'] as int,
  );
}

Map<String, dynamic> toJson() => {
      'address': address,
      'address_id': addressId,
      'name_of_point': nameOfPoint,
      'point': {
        'type': 'Point',
        'coordinates': point,
      },
      'comment_for_delivery': commentForDelivery,
      'organization_id': organizationId,
      'region_id': regionId,
    };


  Address copyWith({
    int? addressId,
    String? nameOfPoint,
    List<double>? point,
    String? commentForDelivery,
    int? organizationId,
    int? regionId,
  }) {
    return Address(
      address: address,
      addressId: addressId ?? this.addressId,
      nameOfPoint: nameOfPoint ?? this.nameOfPoint,
      point: point ?? this.point,
      commentForDelivery: commentForDelivery ?? this.commentForDelivery,
      organizationId: organizationId ?? this.organizationId,
      regionId: regionId ?? this.regionId,
    );
  }
}
