import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/mock_repos/auth_repo.dart';
import 'package:maktub/data/services/dadata_service.dart';
import 'package:maktub/presentation/blocs/register/register_event.dart';
import 'package:maktub/presentation/blocs/register/register_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final DadataService dadataService;
  final SupabaseClient supabase;
  final AuthRepository repo;

  RegisterBloc({
    required this.repo,
    required this.dadataService,
    required this.supabase,
  }) : super(RegisterInitial()) {
    on<RegisterSendOtp>(_onSendOtp);
    on<RegisterCheckIin>(_onCheckIin);
    on<RegisterCheckPhoneExists>(_onCheckPhone);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    on<RegisterPhoneWasVerified>(_onPhoneVerified);
    on<RegisterOrganization>(_onRegisterOrg);
    on<RegisterUser>(_onRegisterUser);
    on<RegisterWebViewCompleted>(_onRegisterWebViewCompleted);
    on<RegisterWebViewCancelled>(_onRegisterWebViewCancelled);
    on<RegisterVerifyOwner>(_onVerifyUserViaWebView);
    on<RegisterFailureEvent>(_onRegisterFailureEvent);
    
  }
  
   Future<void> _onRegisterFailureEvent(
    RegisterFailureEvent event,
    Emitter<RegisterState> emit,
  ) async {

  emit(RegisterFailureAitu(event.error));
  }


    Future<void> _onRegisterWebViewCompleted(
    RegisterWebViewCompleted event,
    Emitter<RegisterState> emit,
  ) async {

 emit(RegisterPhoneExists());
  emit(RegisterVerificationSuccess(event.phone));
  }

      Future<void> _onRegisterWebViewCancelled(
    RegisterWebViewCancelled event,
    Emitter<RegisterState> emit,
  ) async {

  emit(RegisterVerificationFailed());
  }

  Future<void> _onVerifyUserViaWebView(
  RegisterVerifyOwner event,
  Emitter<RegisterState> emit,
) async {
  emit(RegisterVerificationInProgress());
  emit(RegisterShowWebView(event.iin, event.name));
}




Future<void> _onRegisterUser(RegisterUser event, Emitter<RegisterState> emit) async {
  emit(RegisterLoading());


    await repo.createUser(
      phone: event.phone,
      fullName: event.fullName,
      roleId: event.roleId,
      workplaceId: event.workplaceId,
      regionId: 1,
    );

    await Future.delayed(const Duration(seconds: 1));

    emit(RegisterUserSuccess(
      phone: event.phone,
      fromManualPhoneScreen: event.fromManualPhoneScreen,
    ));

}


    String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // от 1000 до 9999
  }

  Future<void> _onRegisterOrg(RegisterOrganization event, Emitter<RegisterState> emit) async{
    emit(RegisterLoading());
    
      final response = await supabase
          .from('organization')
          .insert({
            'organization_id': event.organizationId,
            'name': event.name,
            'phone_number': event.phoneNumber,
            'owner_name':event.ownerName
          }).select();

        final data = response[0];
        final id = data['id'];

        
        emit(OrganizationRegisterSuccess(phone: event.phoneNumber, name: event.name, fromManualPhoneScreen: event.fromManualPhoneScreen, organizationId: id));
    
      }

    
    
  
  
    Future<void> _onSendOtp(RegisterSendOtp event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());

    String otp = generateOtp();

    try {
      final result = await repo.sendOtp(event.phone, otp);
      if (result) {
        emit(RegisterOtpSent(otp));
      } else {
        emit(RegisterFailure("OTP жіберу мүмкін болмады"));
      }
    } catch (e) {
      emit(RegisterFailure("Қате: ${e.toString()}"));
    }
  }


    Future<void> _onPhoneChanged(
    RegisterPhoneChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterPhoneChangedState());
  }

  

  Future<void> _onPhoneVerified(
    RegisterPhoneWasVerified event,
    Emitter<RegisterState> emit,
  ) async {

    emit(RegisterPhoneVerified());
  }


  Future<void> _onCheckPhone(
    RegisterCheckPhoneExists event, 
    Emitter<RegisterState> emit,
  )async{
    emit(RegisterLoading());

    try {
      final data = await supabase
          .from('profiles')
          .select('phone, full_name')
          .eq('phone', event.phone)
          .maybeSingle();

      if (data != null) {
        emit(RegisterPhoneExists(fromManualPhoneScreen: event.fromManualPhoneScreen));
        return;
      }else {
        emit(RegisterPhoneNotFound(phone: event.phone, fromManualPhoneScreen: event.fromManualPhoneScreen));
      }

    } catch (e) {
      emit(RegisterFailure("Қате: ${e.toString()}"));
    }
  }

  Future<void> _onCheckIin(
    RegisterCheckIin event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      final data = await dadataService.checkBusinessExistence(event.iin);

      final status = data['businessStatus']?.toString().toUpperCase() ?? '';
      final type = data['businessType']?.toString().toUpperCase() ?? '';
      final owner = data['businessOwner'] ?? '';
      final name = data['businessName'] ?? '';

      if (status != 'ACTIVE') {
        emit(RegisterInactive(
          owner: owner,
          name: name
        ));
        return;
      }

      if (type != 'INDIVIDUAL') {
        emit(RegisterNotIndividual(
          owner: owner,
          name:name,
          bin: event.iin
        ));
        return;
      }

      final exists = await supabase
          .from('organization')
          .select('organization_id')
          .eq('organization_id', event.iin)
          .maybeSingle();

      if (exists != null) {
        emit(RegisterBusinessExists(owner: owner, name: name));
        return;
      }

      emit(RegisterSuccess(owner: owner, name: name));
    } catch (e) {
      emit(RegisterFailure("Қате: ${e.toString()}"));
    }
  }



}


