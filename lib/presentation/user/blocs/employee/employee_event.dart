import 'package:maktub/data/models/employee.dart';

abstract class EmployeeEvent {}

class LoadEmployeees extends EmployeeEvent {
  final int organizationId;
  LoadEmployeees(this.organizationId);
}

class DeleteEmployee extends EmployeeEvent {
  final Employee employee;
  DeleteEmployee({required this.employee});
}


class EmployeeAdded extends EmployeeEvent {
  EmployeeAdded();
}


class RegisterCheckPhoneExists extends EmployeeEvent {

  final String phone;
   RegisterCheckPhoneExists(this.phone);
}


class AddEmployee extends EmployeeEvent {
  final Employee employee;
  final String phone;
  AddEmployee({
    required this.phone,
    required this.employee,
  });
}




