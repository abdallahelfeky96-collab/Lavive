class ProfileModel {
  bool? status;
  int? code;
  String? msg;
  Data? data;

  ProfileModel({this.status, this.code, this.msg, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    msg = json['msg'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? emailVerifiedAt;
  int? active;
  String? verifyCode;
  String? deviceToken;
  String? zipcode;
  Null address1;
  Null address2;
  int? cityId;
  Null rememberToken;
  String? createdAt;
  String? updatedAt;
  Null deletedAt;
  int? points;
  int? wallet;
  dynamic photo;

  Data(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.emailVerifiedAt,
      this.active,
      this.verifyCode,
      this.deviceToken,
      this.zipcode,
      this.address1,
      this.address2,
      this.cityId,
      this.rememberToken,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.points,
      this.wallet,
      this.photo});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    emailVerifiedAt = json['email_verified_at'];
    active = json['active'];
    verifyCode = json['verify_code'];
    deviceToken = json['device_token'];
    zipcode = json['zipcode'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    cityId = json['city_id'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    points = json['points'];
    wallet = json['wallet'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['email_verified_at'] = emailVerifiedAt;
    data['active'] = active;
    data['verify_code'] = verifyCode;
    data['device_token'] = deviceToken;
    data['zipcode'] = zipcode;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['city_id'] = cityId;
    data['remember_token'] = rememberToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['points'] = points;
    data['wallet'] = wallet;
    data['photo'] = photo;
    return data;
  }
}
