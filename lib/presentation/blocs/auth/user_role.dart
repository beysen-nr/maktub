enum UserRole {
  owner,
  admin,
  receiver,
  supplier,
  delivery,
  guest;

  static UserRole fromId(int? id) {
    switch (id) {
      case 1:
        return UserRole.owner;
      case 2:
        return UserRole.admin;
      case 3:
        return UserRole.receiver;
      case 4:
        return UserRole.supplier;
      case 5:
        return UserRole.delivery;
      default:
        return UserRole.guest;
    }
  }
}