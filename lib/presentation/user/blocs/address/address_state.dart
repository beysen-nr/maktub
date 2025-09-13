import 'package:maktub/data/models/address.dart';
import 'package:maktub/data/models/region.dart';
import 'package:maktub/presentation/user/blocs/address/address_bloc.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Address> addresses;
  AddressLoaded(this.addresses);
}

class RegionsLoaded extends AddressState {
  final List<Region> regions;
  RegionsLoaded(this.regions);
}


class AddressAddedState extends AddressState {

  AddressAddedState();
}


class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}


class SearchInitial extends AddressState {}

class SearchLoading extends AddressState {}



class AddressAddedSuccess extends AddressState {}
class AddressAdding extends AddressState {}



class AddressFailure extends AddressState {  final String message;

AddressFailure(this.message);
  }



class SearchFailure extends AddressState {
  final String message;

  SearchFailure(this.message);
}


class SearchSuccess extends AddressState {
  final List<AddressSuggestion> addresses;

  SearchSuccess(this.addresses);
}

class PointSearchSuccess extends AddressState {
  final List<AddressSuggestion> addresses;

   PointSearchSuccess(this.addresses);
}



