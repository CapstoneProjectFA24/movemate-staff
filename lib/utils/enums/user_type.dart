enum UserRole {
  reviewer('Reviewer'),
  driver('Driver'),
  admin('Admin'),
  poster('Poster'),
  customer('Customer');

  final String type;
  const UserRole(this.type);

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.type.toLowerCase() == role.toLowerCase(),
      orElse: () => UserRole.reviewer, 
    );
  }
}

extension ConvertUserRole on String {
  UserRole toUserRoleEnum() {
    switch (this) {
      case 'Driver':
        return UserRole.driver;
      case 'Reviewer':
        return UserRole.reviewer;
      case 'Poster':
        return UserRole.poster;
      case 'Admin':
        return UserRole.poster;
      case 'Customer':
        return UserRole.customer;
      default:
        return UserRole.reviewer;
    }
  }
}
