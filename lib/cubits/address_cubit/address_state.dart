part of 'address_cubit.dart';

sealed class AddressState {
  const AddressState();
}

final class AddressInitial extends AddressState {}

final class AddAddressLoading extends AddressState {}

final class AddAddressSuccess extends AddressState {
  final String addAddressSuccessMessage;
  AddAddressSuccess(this.addAddressSuccessMessage);
}

final class AddAddressFaluire extends AddressState {
  final String addAddressFaluireMessage;
  AddAddressFaluire(this.addAddressFaluireMessage);
}

final class GetAddressLoading extends AddressState {}

final class GetAddressSuccess extends AddressState {
  GetAllAddressesModel allAdresess;
  GetAddressSuccess(this.allAdresess);
}

final class GetAddressFaluire extends AddressState {
  final String getAddressFaluireMessage;
  GetAddressFaluire(this.getAddressFaluireMessage);
}

final class UpdateAddressLoading extends AddressState {}

final class UpdateAddressSuccess extends AddressState {}

final class UpdateAddressFaluire extends AddressState {}

final class DeleteAddressLoading extends AddressState {}

final class DeleteAddressSuccess extends AddressState {
  final String deleteAddressSuccessMessage;
  DeleteAddressSuccess(this.deleteAddressSuccessMessage);
}

final class DeleteAddressFaluire extends AddressState {
  final String deleteAddressFaluireMessage;
  DeleteAddressFaluire(this.deleteAddressFaluireMessage);
}
