abstract class AuthEvent {}

class AuthCheckPhoneExists extends AuthEvent {
  final String phone;

  AuthCheckPhoneExists(this.phone);
}

class IsDevMode extends AuthEvent {
  final String phone;

  IsDevMode(this.phone);
}

class AuthPhoneWasVerified extends AuthEvent {
}

class AuthPhoneChanged extends AuthEvent {
}


class AuthVerifyPhone extends AuthEvent {
  final String otp;
  AuthVerifyPhone(this.otp);
}

class AuthSendOtp extends AuthEvent {
  final String phone;
  AuthSendOtp(this.phone);
}

class AuthLogin extends AuthEvent {
  final String phone;
  AuthLogin(this.phone);
}

class AuthCheckSession extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}



class AuthDeleteRequested extends AuthEvent {
  final String phone;
  AuthDeleteRequested(this.phone);


}



class AppStarted extends AuthEvent {}


class AuthSignUp extends AuthEvent{
  final String phone;
  final String workplaceId;
  final int roleId;
  final String fullName;
  final int regionId;
  String? fcmToken;

  AuthSignUp({
    required this.phone,
    required this.workplaceId,
    required this.roleId,
    required this.fullName,
    required this.regionId,
    this.fcmToken,
  });
}

