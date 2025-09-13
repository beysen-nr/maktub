import 'package:maktub/data/services/supabase/supabase_service.dart';
import '../models/employee.dart';

class EmployeeRepository {
  final _client = SupabaseService.client;

  Future<List<Employee>> getOrganizationEmployeees(int organizationId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('workplace_id', organizationId);

    return (response as List).map((json) => Employee.fromJson(json)).toList();
  }



  Future<void> deleteEmployee({required Employee employee}) async {
    await _client
        .from('profiles')
        .delete().
        eq('workplace_id',employee.workplaceId!)
        .eq('phone', employee.phone!);
  }

  Future<void> insertEmployee({required Employee employee}) async{
    await _client.from('profiles').insert(employee.toJson());
  }

   Future<void> updateEmployee({required Employee employee}) async{
    await _client.from('profiles').update(employee.toJson());
  }

}
