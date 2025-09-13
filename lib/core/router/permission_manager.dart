import 'package:maktub/presentation/blocs/auth/user_role.dart';

class PermissionManager {
  static bool canAccess(UserRole role, String screen) {
    final Map<String, List<UserRole>> accessMap = {

      'owner': [UserRole.owner],
      'employee':[UserRole.owner, UserRole.admin],
      'map': [UserRole.owner, UserRole.admin],
      'cart': [UserRole.owner, UserRole.admin],
      'favorite': [UserRole.owner],
      'addToCartFunction':[UserRole.admin, UserRole.owner],
      'acceptDelivery':[UserRole.admin, UserRole.owner, UserRole.receiver],
    };

    final allowedRoles = accessMap[screen];
    return allowedRoles?.contains(role) ?? true; // по умолчанию доступ есть
  }

}
