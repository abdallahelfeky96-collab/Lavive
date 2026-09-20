class VeriryPhoneModel {
  String? phone;
  String? code = "1234";

  VeriryPhoneModel({required this.phone, this.code});

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "code": code,
    };
  }
}
