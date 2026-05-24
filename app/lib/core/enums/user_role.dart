/// Staff roles, matching the Django backend (`ADMIN`, `RECEPCIONISTA`).
enum UserRole {
  admin,
  recepcionista,
  unknown;

  static UserRole fromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'RECEPCIONISTA':
        return UserRole.recepcionista;
      default:
        return UserRole.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.recepcionista:
        return 'RECEPCIONISTA';
      case UserRole.unknown:
        return 'UNKNOWN';
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.recepcionista:
        return 'Recepcionista';
      case UserRole.unknown:
        return 'Sin rol';
    }
  }

  bool get isAdmin => this == UserRole.admin;
}
