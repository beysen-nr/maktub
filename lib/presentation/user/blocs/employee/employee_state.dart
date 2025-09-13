import 'package:maktub/data/models/employee.dart';
import 'package:maktub/data/models/region.dart';

abstract class EmployeeState {}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  EmployeeLoaded(this.employees);
}


class RegisterPhoneExists extends EmployeeState {}



class RegisterPhoneNotFound extends EmployeeState {
  final String phone;
    RegisterPhoneNotFound({
    required this.phone,
  });
}

class EmployeeAddedState extends EmployeeState {

  EmployeeAddedState();
}


class EmployeeError extends EmployeeState {
  final String message;
  EmployeeError(this.message);
}





class EmployeeAddedSuccess extends EmployeeState {}
class EmployeeAdding extends EmployeeState {}



class EmployeeFailure extends EmployeeState {  final String message;

EmployeeFailure(this.message);
  }






