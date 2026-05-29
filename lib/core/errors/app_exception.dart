class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;

  factory AppException.fromFirebase(dynamic error) {
    final code = (error.toString());
    if (code.contains('invalid-credential')) {
      return const AppException('Correo o contraseña incorrectos', code: 'invalid-credential');
    }
    if (code.contains('email-already-in-use')) {
      return const AppException('Este correo ya está registrado', code: 'email-already-in-use');
    }
    if (code.contains('user-not-found')) {
      return const AppException('Usuario no encontrado', code: 'user-not-found');
    }
    if (code.contains('wrong-password')) {
      return const AppException('Contraseña incorrecta', code: 'wrong-password');
    }
    if (code.contains('weak-password')) {
      return const AppException('La contraseña debe tener al menos 6 caracteres', code: 'weak-password');
    }
    if (code.contains('invalid-email')) {
      return const AppException('Correo electrónico inválido', code: 'invalid-email');
    }
    if (code.contains('network-request-failed')) {
      return const AppException('Error de conexión. Verifica tu internet', code: 'network-error');
    }
    if (code.contains('too-many-requests')) {
      return const AppException('Demasiados intentos. Intenta más tarde', code: 'too-many-requests');
    }
    return AppException('Error inesperado: $error', code: 'unknown');
  }

  factory AppException.fromFirestore(dynamic error) {
    return AppException('Error de base de datos: $error', code: 'firestore-error');
  }

  factory AppException.fromRtdb(dynamic error) {
    return AppException('Error de sincronización: $error', code: 'rtdb-error');
  }
}
