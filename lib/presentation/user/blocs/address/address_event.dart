import 'package:maktub/data/models/address.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class AddressEvent {}

class LoadAddresses extends AddressEvent {
  final int organizationId;
  LoadAddresses(this.organizationId);
}

class DeleteAddress extends AddressEvent {
  final int organizationId;
  final int addressId;
  DeleteAddress({required this.addressId, required this.organizationId});
}

class LoadRegions extends AddressEvent {
  LoadRegions();
}

class CreateOrUpdateAddress extends AddressEvent {
  final Address address;
  final int organizationId;
  CreateOrUpdateAddress(this.address, this.organizationId);
}

class SearchAddressChanged extends AddressEvent {
  final Geometry geometry;
  final String query;

  SearchAddressChanged(this.query, this.geometry);
}


class AddressAdded extends AddressEvent {

  AddressAdded();
}


class SearchAddressByPoint extends AddressEvent {
  final int regionId;
  final Point point;
  final Geometry geometry;

  SearchAddressByPoint(this.regionId, this.point, this.geometry);
}


class AddAddress extends AddressEvent {
  final Address address;
  final String phone;
  AddAddress({
    required this.phone,
    required this.address,
  });
}

class RegionChanged extends AddressEvent {
  final int regionId;
  final String phone;
  RegionChanged({
    required this.regionId,
    required this.phone
  });
}


