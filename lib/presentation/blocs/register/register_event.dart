import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterWebViewCompleted extends RegisterEvent {
  final String phone;
  const RegisterWebViewCompleted(this.phone);
}

class RegisterWebViewCancelled extends RegisterEvent {}


class RegisterCheckIin extends RegisterEvent {
  final String iin;

  const RegisterCheckIin(this.iin);

  @override
  List<Object> get props => [iin];
}

class RegisterVerifyOwner extends RegisterEvent {
  final String iin;
  final String name;
  const RegisterVerifyOwner(this.iin, this.name);

  @override
  List<Object> get props => [iin];
}

class RegisterPhoneWasVerified extends RegisterEvent {}

class RegisterUser extends RegisterEvent {
  final String phone;
  final int workplaceId;
  final int roleId;
  final String fullName;
  final int regionId;
  final bool fromManualPhoneScreen;

   RegisterUser({
    required this.regionId,
    required this.phone,
    required this.workplaceId,
    required this.roleId,
    required this.fullName,
    this.fromManualPhoneScreen = false,

  });
}





class RegisterOrganization extends RegisterEvent {
  final String organizationId;
  final String ownerName;
  final String name;
  final String phoneNumber;
   final bool fromManualPhoneScreen;

  const RegisterOrganization({
    required this.ownerName,
    required this.organizationId,
    required this.name,
    required this.phoneNumber,
    this.fromManualPhoneScreen = false
  });
}

class RegisterSendOtp extends RegisterEvent {
  final String phone;
  const RegisterSendOtp(this.phone);
}

class RegisterPhoneChanged extends RegisterEvent {}

class RegisterCheckPhoneExists extends RegisterEvent {
  final bool fromManualPhoneScreen;

  final String phone;
  const RegisterCheckPhoneExists(this.phone, {this.fromManualPhoneScreen = false});
}


class RegisterFailureEvent extends RegisterEvent {
    final String error;
  const RegisterFailureEvent(this.error);
}
