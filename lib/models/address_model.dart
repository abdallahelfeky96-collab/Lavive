class AddressModel {
  String? title, address, phone;
  int? id;
  AddressModel({this.address, this.phone, this.title, this.id});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      "address": address,
      'phone': phone,
    };
  }
}
