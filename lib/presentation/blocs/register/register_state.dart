abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}



class RegisterUserSuccess extends RegisterState {
  final String phone;
  final bool fromManualPhoneScreen;
    RegisterUserSuccess({
    required this.phone,
    this.fromManualPhoneScreen = false,
  });
}

class OrganizationRegisterSuccess extends RegisterState {
  final String phone;
  final String name;
  final bool fromManualPhoneScreen;
  final int organizationId;
  OrganizationRegisterSuccess({
    required this.organizationId,
    required this.phone,
    required this.name,
    this.fromManualPhoneScreen = false
  });
}


class RegisterInactive extends RegisterState {
  final String owner;
  final String name;

  RegisterInactive({
    required this.owner,
    required this.name,
  });
}

class RegisterPhoneExists extends RegisterState {
  final bool fromManualPhoneScreen;

  RegisterPhoneExists({
    this.fromManualPhoneScreen = false
  });

}

class RegisterPhoneNotFound extends RegisterState {
  final String phone;
  final bool fromManualPhoneScreen;
    RegisterPhoneNotFound({
    required this.phone,
    this.fromManualPhoneScreen = false,
  });
}





class RegisterNotIndividual extends RegisterState {
  final String owner;
  final String name;
  final String bin;

  RegisterNotIndividual({
    required this.owner,
    required this.name,
    required this.bin,
  });
}

class RegisterBusinessExists extends RegisterState {
  final String owner;
  final String name;

  RegisterBusinessExists({
    required this.owner,
    required this.name,
  });
}

class RegisterSuccess extends RegisterState {
  final String owner;
  final String name;

  RegisterSuccess({
    required this.owner,
    required this.name,
  });

}

class RegisterFailure extends RegisterState {
  final String message;

  RegisterFailure(this.message);
}
class RegisterFailureAitu extends RegisterState {
  final String message;

  RegisterFailureAitu(this.message);
}
class RegisterVerificationInProgress extends RegisterState {}

class RegisterVerificationSuccess extends RegisterState {
  final String phone;
  RegisterVerificationSuccess(this.phone);
}

class RegisterOtpSent extends RegisterState {
  final String otp;
  RegisterOtpSent(this.otp);
}

class RegisterVerificationFailed extends RegisterState {}

class RegisterPhoneChangedState extends RegisterState {}

class RegisterPhoneVerified extends RegisterState {}

class RegisterShowWebView extends RegisterState {

    final String iin;
    final String name;
  RegisterShowWebView(this.iin, this.name);
}
