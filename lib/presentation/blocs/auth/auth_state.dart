import 'package:maktub/presentation/blocs/auth/user_role.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthCheckingPhone extends AuthState {}


class AuthLoading extends AuthState {}

class AuthPhoneNotFound extends AuthState {}

class AuthOtpSending extends AuthState {}

class AuthPhoneExists extends AuthState {
  final String name;
  AuthPhoneExists(this.name);
}

class AuthOtpSent extends AuthState {
  final String otp;
  AuthOtpSent(this.otp);
}

class AuthVerifying extends AuthState {}


class AuthFailure extends AuthState {
  final String message;
  final bool? isBlocked;
  AuthFailure(this.message, {this.isBlocked = false});
}

class AuthPhoneChangedState extends AuthState {}

class AuthPhoneVerified extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String organizationName;
  final String ownerName;
  final bool isActive;
  final int regionId;
  final String phone;
  final String fullName;
  final int workplaceId;
  final UserRole role;
  final String cityName;

   AuthAuthenticated({
    required this.ownerName,
    required this.organizationName,
    required this.isActive,
    required this.regionId,
    required this.phone,
    required this.cityName,
    required this.fullName,
    required this.workplaceId,
    required this.role,
  });

  List<Object?> get props => [phone, fullName, workplaceId, role];
}
class AuthSuccess extends AuthState {
  
  final String organizationName;
  final String ownerName;
  final bool isActive;
  final int regionId;
  final String phone;
  final String fullName;
  final int workplaceId;
  final UserRole role;
  final String cityName;

   AuthSuccess({
    required this.ownerName,
    required this.organizationName,
    required this.isActive,
    required this.regionId,
    required this.phone,
    required this.fullName,
    required this.workplaceId,
    required this.role,
    required this.cityName
  });

  List<Object?> get props => [phone, fullName, workplaceId, role];
}

class AuthGuest extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthLogout extends AuthState {}

class DevMode extends AuthState {}