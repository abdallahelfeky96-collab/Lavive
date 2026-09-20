class GetAllAddressesModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  GetAllAddressesModel({this.status, this.code, this.msg, this.data});

  GetAllAddressesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? phone;
  String? title;
  String? address;
  int? clientId;

  Data({this.id, this.phone, this.title, this.address, this.clientId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    title = json['title'];
    address = json['address'];
    clientId = json['client_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['title'] = title;
    data['address'] = address;
    data['client_id'] = clientId;
    return data;
  }
}
