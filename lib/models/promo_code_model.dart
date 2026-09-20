class PromoCodeModel {
  final bool status;
  final int code;
  final String msg;
  final PromoCodeData? data;

  PromoCodeModel({
    required this.status,
    required this.code,
    required this.msg,
    this.data,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      status: json['status'],
      code: json['code'],
      msg: json['msg'],
      data: json['data'] != null ? PromoCodeData.fromJson(json['data']) : null,
    );
  }
}

class PromoCodeData {
  final int id;
  final String name;
  final String code;
  final String discountType;
  final String discountValue;
  final String expirationDate;

  PromoCodeData({
    required this.id,
    required this.name,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expirationDate,
  });

  factory PromoCodeData.fromJson(Map<String, dynamic> json) {
    return PromoCodeData(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      discountType: json['discount_type'],
      discountValue: json['discount_value'],
      expirationDate: json['expiration_date'],
    );
  }
}
