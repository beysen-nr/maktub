class Employee {
  final String? phone;
  final String? fullName;
  final int? regionId;
  final int? roleId;
  final int? workplaceId;
  final String? fcmToken;
  final bool? isBlocked;

  Employee({
    this.phone,
    this.fullName,
    this.regionId,
    this.roleId,
    this.workplaceId,
    this.fcmToken,
    this.isBlocked,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      regionId: json['region_id'] as int?,
      roleId: json['role_id'] as int?,
      workplaceId: json['workplace_id'] as int?,
      fcmToken: json['fcm_token'] as String?,
      isBlocked: json['is_blocked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'full_name': fullName,
      'region_id': regionId,
      'role_id': roleId,
      'workplace_id': workplaceId,
      'fcm_token': fcmToken,
      'is_blocked': isBlocked,
    };
  }
}
