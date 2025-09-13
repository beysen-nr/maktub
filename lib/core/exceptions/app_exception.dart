class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, {this.details});

  @override
  String toString() {
    return 'AppException: $message${details != null ? " ($details)" : ""}';
  }
}

class NetworkException extends AppException {
  NetworkException([super.message = "Ошибка сети"]);
}

class ServerException extends AppException {
  ServerException([super.message = "Ошибка сервера"]);
}

class UnknownException extends AppException {
  UnknownException([super.message = "Неизвестная ошибка"]);
}

class WrongPasswordException extends AppException {
  WrongPasswordException() : super("Неверный пароль");
}

class UserNotFoundException extends AppException {
  UserNotFoundException() : super("Пользователь с таким номером не найден");
}

class UserAlreadyExistsException extends AppException {
  UserAlreadyExistsException() : super("Пользователь с таким номером уже зарегистрирован");
}

class UnauthorizedException extends AppException {
  UnauthorizedException(jsonDecode) : super("Ошибка авторизации: неверный API-ключ или токен.");
}

class ContentTypeException extends AppException {
  ContentTypeException(jsonDecode) : super("Ошибка: не указан Content-Type в запросе.");
}

class ServiceProviderException extends AppException {
  ServiceProviderException(String s) : super("Сервис провайдера недоступен, попробуйте позже.");
}

class AituPassException extends AppException {
  AituPassException([super.message = "AituPass Authentication failed"]);
}

class DadataException extends AppException {
  DadataException([super.message = "Dadata Exception"]);
}

class OrganizationException extends AppException {
  OrganizationException([super.message = "Такой организации не существует"]);
}

