import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:vegesea/models/address_model.dart';
import 'package:vegesea/models/get_all_addresses_model.dart';
import 'package:vegesea/services/address_services.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());

  Future<void> addAddress(AddressModel address) async {
    try {
      emit(AddAddressLoading());

      await addAddressService(address);
      emit(AddAddressSuccess("Address Added Successfully"));
    } catch (e) {
      log("error add address==>>>${e.toString()}");
      emit(AddAddressFaluire(e.toString()));
    }
  }

  ////////////////////////////////////////////////////////////
  Future<void> getAllAddresess() async {
    try {
      emit(GetAddressLoading());
      final allAddresses = await fetchAllAddresses();
      emit(GetAddressSuccess(allAddresses));
    } catch (e) {
      emit(GetAddressFaluire(e.toString()));
    }
  }
  ////////////////////////////////////////////////////////////

  Future<void> deleteAddress(int id) async {
    try {
      emit(DeleteAddressLoading());

      await deleteAddressService(id);
      emit(DeleteAddressSuccess("Address Deleted Succefully"));
    } catch (e) {
      emit(DeleteAddressFaluire(e.toString()));
    }
  }
}
