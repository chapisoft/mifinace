/// User roles supported within the BMF mobile platform.
enum UserRole {
  creditOfficer('CREDIT_OFFICER'),
  agent('AGENT'),
  branchManager('BRANCH_MANAGER'),
  customerMember('CUSTOMER_MEMBER'),
  admin('ADMIN');

  final String code;
  const UserRole(this.code);

  static UserRole fromCode(String? code) {
    if (code == null) return UserRole.creditOfficer;
    for (final role in UserRole.values) {
      if (role.code == code || role.name.toUpperCase() == code.toUpperCase()) {
        return role;
      }
    }
    return UserRole.creditOfficer;
  }
}
