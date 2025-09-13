import 'package:maktub/data/models/region.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import '../models/address.dart';

class AddressRepository {
  final _client = SupabaseService.client;

  Future<List<Address>> getOrganizationAddresses(int organizationId) async {
    final response = await _client
        .from('organization_addresses')
        .select()
        .eq('organization_id', organizationId);

    return (response as List).map((json) => Address.fromJson(json)).toList();
  }

  Future<List<Region>> getRegions() async {
    final response = await _client.rpc('get_regions');
    return (response as List).map((json) => Region.fromJson(json)).toList();
  }

  Future<void> deleteAddress(int addressId) async {
    await _client
        .from('organization_addresses')
        .delete()
        .eq('address_id', addressId);
  }

    Future<void> regionChanged(int regionId, String phone) async {
    
await _client
    .from('profiles')
    .update({'region_id': regionId})
    .eq('phone', phone);

  }

  Future<void> createOrUpdateAddress(Address address) async {
    final data = address.toJson();
    if(address.addressId == null) {
        data.remove('address_id');
      try{
      await _client.from('organization_addresses').insert(data);
      } catch (e) {
      }
      return;
    }
      await _client
          .from('organization_addresses')
          .update(data)
          .eq('address_id', address.addressId as int);
   
  }
}
