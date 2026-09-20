import 'package:vegesea/models/sub_products_model.dart';

class SubCategoriesModel {
  bool? status;
  int? code;
  String? msg;
  Data? data;

  SubCategoriesModel({this.status, this.code, this.msg, this.data});

  SubCategoriesModel.fromJson(Map<String, dynamic> json) {
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
  String? titleEn;
  String? titleAr;
  String? photo;
  String? backgroundPhoto;
  String? color;
  int? active;
  int? displayOrder;
  String? createdAt;
  String? updatedAt;
  Null deletedAt;
  int? timeLimit;
  String? myTitle;
  List<SubCategories>? subCategories;
  List<Products>? products;

  Data({
    this.id,
    this.titleEn,
    this.titleAr,
    this.photo,
    this.backgroundPhoto,
    this.color,
    this.active,
    this.displayOrder,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.timeLimit,
    this.myTitle,
    this.subCategories,
    this.products,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    photo = json['photo'];
    backgroundPhoto = json['background_photo'];
    color = json['color'];
    active = json['active'];
    displayOrder = json['display_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    timeLimit = json['time_limit'];
    myTitle = json['my_title'];
    if (json['sub_categories'] != null) {
      subCategories = <SubCategories>[];
      json['sub_categories'].forEach((v) {
        subCategories!.add(SubCategories.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['photo'] = photo;
    data['background_photo'] = backgroundPhoto;
    data['color'] = color;
    data['active'] = active;
    data['display_order'] = displayOrder;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['time_limit'] = timeLimit;
    data['my_title'] = myTitle;
    if (subCategories != null) {
      data['sub_categories'] = subCategories!.map((v) => v.toJson()).toList();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubCategories {
  int? id;
  String? title;
  String? myTitle;
  String? photo;
  int? categoryId;

  SubCategories(
      {this.id, this.title, this.photo, this.categoryId, this.myTitle});

  SubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    photo = json['photo'];
    myTitle = json['my_title'];
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['photo'] = photo;
    data['category_id'] = categoryId;
    data['my_title'] = myTitle;
    return data;
  }
}
