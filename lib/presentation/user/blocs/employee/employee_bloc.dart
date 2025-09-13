import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/data/mock_repos/auth_repo.dart';
import 'package:maktub/data/mock_repos/employee_repo.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/main.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_event.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repository;

  EmployeeBloc(this.repository) : super(EmployeeInitial()) {
    on<LoadEmployeees>(_onLoad);
    on<DeleteEmployee>(_onDelete);
    on<RegisterCheckPhoneExists>(_onCheckPhone);

  AuthRepository authRepo = AuthRepository();

    on<AddEmployee>((event, emit) async {
      emit(EmployeeAdding());
      try {

           await authRepo.createUser(
      phone: event.employee.phone!,
      fullName: event.employee.fullName!,
      roleId: event.employee.roleId!,
      workplaceId: event.employee.workplaceId!,
      regionId: event.employee.regionId,
    );
        // await repository.insertEmployee(employee: event.employee);
        add(LoadEmployeees(event.employee.workplaceId!));
   
        emit(EmployeeAddedSuccess());
      } catch (e) {
        emit(EmployeeFailure('Қате орын алды: $e'));
      }
    });

  }

  final SupabaseClient _client = SupabaseService.client;

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  Future<void> _onLoad(LoadEmployeees event, Emitter emit) async {
    emit(EmployeeLoading());
    try {
      final employees = await repository.getOrganizationEmployeees(
        event.organizationId,
      );



         final filtered = employees.where((e) => e.roleId != 1).toList();

      emit(EmployeeLoaded(filtered));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

    Future<void> _onCheckPhone(
    RegisterCheckPhoneExists event, 
    Emitter<EmployeeState> emit,
  )async{
    emit(EmployeeLoading());

    try {
      final data = await _client
          .from('profiles')
          .select('phone, full_name')
          .eq('phone', event.phone)
          .maybeSingle();

      if (data != null) {
        emit(RegisterPhoneExists());
        return;
      }else {
        emit(RegisterPhoneNotFound(phone: event.phone));
      }

    } catch (e) {
      emit(EmployeeError("Қате: ${e.toString()}"));
    }
  }


  Future<void> _onDelete(DeleteEmployee event, Emitter emit) async {
    if (state is! EmployeeLoaded) return;
    await authRepository.deleteUser(phone: event.employee.phone!);
    add(LoadEmployeees(event.employee.workplaceId!));
  }
}
