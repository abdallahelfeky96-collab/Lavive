import 'package:vegesea/models/one_product_model.dart';

class BannersModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  BannersModel({this.status, this.code, this.msg, this.data});

  BannersModel.fromJson(Map<String, dynamic> json) {
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
  String? titleEn;
  String? titleAr;
  String? descriptionEn;
  String? descriptionAr;
  dynamic link;
  String? photo;
  String? createdAt;
  String? updatedAt;
  String? myTitle;
  String? myDescription;
  String? price;
  int? rate;
  int? isPackaging;
  String? packaging;
  Unit? unit;

  Data({
    this.id,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.link,
    this.photo,
    this.createdAt,
    this.updatedAt,
    this.myTitle,
    this.myDescription,
    this.price,
    this.rate,
    this.isPackaging,
    this.packaging,
    this.unit,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    descriptionEn = json['description_en'];
    descriptionAr = json['description_ar'];
    link = json['link'];
    photo = json['photo'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    myTitle = json['my_title'];
    myDescription = json['my_description'];
    price = json['price']?.toString();
    rate = json['rate'];
    isPackaging = json['is_packaging'];
    packaging = json['packaging']?.toString();
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['description_en'] = descriptionEn;
    data['description_ar'] = descriptionAr;
    data['link'] = link;
    data['photo'] = photo;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['my_title'] = myTitle;
    data['my_description'] = myDescription;
    data['price'] = price;
    data['rate'] = rate;
    data['is_packaging'] = isPackaging;
    data['packaging'] = packaging;
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    return data;
  }
}
