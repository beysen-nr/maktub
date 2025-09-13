import 'dart:math';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/mock_repos/auth_repo.dart';
import 'package:maktub/presentation/blocs/auth/auth_event.dart';
import 'package:maktub/presentation/blocs/auth/auth_state.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final prefix.SupabaseClient supabase;
  final AuthRepository repo;

  AuthBloc({required this.supabase, required this.repo})
    : super(AuthInitial()) {
    on<AuthCheckPhoneExists>(_onCheckPhone);
    on<AuthDeleteRequested>(_onDeleteAccount);

    on<AuthSendOtp>(_onSendOtp);
    on<AuthPhoneChanged>(_onPhoneChanged);
    on<AuthPhoneWasVerified>(_onPhoneVerified);
    on<AuthLogin>(_onLogin);
    // on<AuthCheckSession>(_onCheckSession);
    on<AuthLogoutRequested>(_onLogout);
    on<AppStarted>(_onAppStarted);
    on<IsDevMode>(_isDevMode);
  }

  Future<void> _isDevMode(IsDevMode event, Emitter<AuthState> emit) async {
    bool isDevMode = await repo.getDevModeStatus();
    if (isDevMode) {
      emit(DevMode());
    } else {
      emit(AuthPhoneNotFound());
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repo.signOut();

    emit(AuthGuest());
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await repo.signInWithPhonePassword(event.phone);
      if (result) {
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('phone', event.phone)
            .maybeSingle();
        if (profile == null) {
          emit(AuthGuest());
          return;
        }
  

        if (profile['role_id'] != 4) {

          final regionId = profile['region_id'];
          if (regionId == null) {
            emit(AuthFailure("region_id is null"));
            return;
          }

          final cityData = await supabase
              .from('region')
              .select('name')
              .eq('id', regionId)
              .maybeSingle();

          final isActiveData = await supabase
              .from('organization')
              .select('is_active, name, owner_name')
              .eq('id', profile['workplace_id'])
              .maybeSingle();

          final isActive = isActiveData?['is_active'] as bool? ?? true;

          final cityName = cityData?['name'] as String? ?? '';

          final roleId = profile['role_id'] as int? ?? 99;
          final role = UserRole.values.asMap().containsKey(roleId)
              ? UserRole.values[roleId]
              : UserRole.guest;

          emit(
            AuthSuccess(
              ownerName: isActiveData?['owner_name'],
              organizationName: isActiveData?['name'],
              isActive: isActive,
              regionId: profile['region_id'] ?? 777,
              phone: profile['phone'] ?? '',
              fullName: profile['full_name'] ?? '',
              workplaceId: profile['workplace_id'] ?? 2,
              role: role,
              cityName: cityName as String? ?? '',
            ),
          );
        } else if (profile['role_id'] == 4) {
          final regionId = profile['region_id'];
          if (regionId == null) {
            emit(AuthFailure("region_id is null"));
            return;
          }
          

          final isActiveData = await supabase
              .from('supplier')
              .select('active, name')
              .eq('id', profile['workplace_id'])
              .maybeSingle();

          final isActive = isActiveData?['active'] as bool? ?? true;

          final cityName = '';

          final roleId = profile['role_id'] as int? ?? 99;
          final role = UserRole.values.asMap().containsKey(roleId)
              ? UserRole.values[roleId]
              : UserRole.guest;

          emit(
            AuthSuccess(
              ownerName: '',
              organizationName: '',
              isActive: isActive,
              regionId: profile['region_id'] ?? 777,
              phone: profile['phone'] ?? '',
              fullName: profile['full_name'] ?? '',
              workplaceId: profile['workplace_id'],
              role: role,
              cityName: cityName as String? ?? '',
            ),
          );
        }
      } else {
        emit(AuthFailure("кіру мүмкін болмады"));
      }
    } catch (e) {}
  }

  Future<void> _onCheckPhone(
    AuthCheckPhoneExists event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final exists = await supabase
          .from('profiles')
          .select('phone, full_name, workplace_id')
          .eq('phone', event.phone)
          .maybeSingle();

      if (exists != null) {
        final isBlocked = await supabase
            .from('organization')
            .select('is_active')
            .eq('id', exists['workplace_id'])
            .maybeSingle();
        if (isBlocked?['is_active'] == false) {
          emit(
            AuthFailure(
              'Сіздің аккаунтыңыз бұғатталған, анығырақ білу үшін @maktubSupport телеграм желісіне жазыңыз',
              isBlocked: false,
            ),
          );
          return;
        }
        emit(AuthPhoneExists(exists['full_name']));
        return;
      }

      emit(AuthPhoneNotFound());
    } catch (e) {
      emit(AuthFailure("Қате: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteAccount(
    AuthDeleteRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repo.deleteAccount(phoneNumber: event.phone);

    emit(AuthGuest());
  }

  String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // от 1000 до 9999
  }

  Future<void> _onPhoneChanged(
    AuthPhoneChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPhoneChangedState());
  }

  Future<void> _onPhoneVerified(
    AuthPhoneWasVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPhoneVerified());
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthOtpSending());

    String otp = generateOtp();

    try {
      final result = await repo.sendOtp(event.phone, otp);
      if (result) {
        emit(AuthOtpSent(otp));
      } else {
        emit(AuthFailure("OTP жіберу мүмкін болмады"));
      }
    } catch (e) {
      emit(AuthFailure("Қате: ${e.toString()}"));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final user = supabase.auth.currentUser;

    if (user == null || user.phone == null) {
      emit(AuthGuest());
      return;
    }

    final phone = user.phone;

    if (phone == null) {
      emit(AuthGuest());
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (profile == null) {
        emit(AuthGuest());
        return;
      }
      if(profile['role_id']!=4){
      final regionId = profile['region_id'];
      if (regionId == null) {
        emit(AuthFailure("region_id is null"));
        return;
      }

      final cityData = await supabase
          .from('region')
          .select('name')
          .eq('id', regionId)
          .maybeSingle();

      final isActiveData = await supabase
          .from('organization')
          .select('is_active, name, owner_name')
          .eq('id', profile['workplace_id'])
          .maybeSingle();

      final isActive = isActiveData?['is_active'] as bool? ?? false;

      final cityName = cityData?['name'] as String? ?? '';

      final roleId = profile['role_id'] as int? ?? 99;
      final role = UserRole.values.asMap().containsKey(roleId)
          ? UserRole.fromId(roleId)
          : UserRole.guest;

      emit(
        AuthAuthenticated(
          ownerName: isActiveData?['owner_name'],
          organizationName: isActiveData?['name'],
          isActive: isActive,
          regionId: profile['region_id'] ?? 777,
          phone: profile['phone'] ?? '',
          fullName: profile['full_name'] ?? '',
          workplaceId: profile['workplace_id'] ?? '',
          role: role,
          cityName: cityName,
        ),
      );}else{

      final regionId = profile['region_id'];
      if (regionId == null) {
        emit(AuthFailure("region_id is null"));
        return;
      }

      final cityData = await supabase
          .from('region')
          .select('name')
          .eq('id', regionId)
          .maybeSingle();

      final isActiveData = await supabase
          .from('supplier')
          .select('active, name')
          .eq('id', profile['workplace_id'])
          .maybeSingle();

      final isActive = isActiveData?['active'] as bool? ?? false;

      final cityName = cityData?['name'] as String? ?? '';

      final roleId = profile['role_id'] as int? ?? 99;
      final role = UserRole.values.asMap().containsKey(roleId)
          ? UserRole.fromId(roleId)
          : UserRole.guest;

      emit(
        AuthAuthenticated(
          ownerName: '',
          organizationName: '',
          isActive: isActive,
          regionId: profile['region_id'] ?? 777,
          phone: profile['phone'] ?? '',
          fullName: profile['full_name'] ?? '',
          workplaceId: profile['workplace_id'] ?? '',
          role: role,
          cityName: cityName,
        ),
      );
      }


    } catch (e) {
      emit(AuthFailure('Қате: ${e.toString()}'));
    }
  }
}
