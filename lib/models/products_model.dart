class ProductsModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  ProductsModel({this.status, this.code, this.msg, this.data});

  ProductsModel.fromJson(Map<String, dynamic> json) {
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
  SubCategory? subCategory;
  List<Products>? products;

  Data({this.subCategory, this.products});

  Data.fromJson(Map<String, dynamic> json) {
    subCategory = json['sub_category'] != null
        ? SubCategory.fromJson(json['sub_category'])
        : null;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubCategory {
  int? id;
  String? titleEn;
  String? titleAr;
  String? photo;
  int? active;
  int? categoryId;
  String? createdAt;
  String? updatedAt;

  SubCategory(
      {this.id,
      this.titleEn,
      this.titleAr,
      this.photo,
      this.active,
      this.categoryId,
      this.createdAt,
      this.updatedAt});

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    photo = json['photo'];
    active = json['active'];
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['photo'] = photo;
    data['active'] = active;
    data['category_id'] = categoryId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Products {
  int? id;
  String? titleEn;
  String? titleAr;
  String? descriptionEn;
  String? descriptionAr;
  int? subCategoryId;
  int? active;
  int? isPackaging;
  String? photo;
  SubCategory? subCategory;

  Products(
      {this.id,
      this.titleEn,
      this.titleAr,
      this.descriptionEn,
      this.descriptionAr,
      this.subCategoryId,
      this.active,
      this.isPackaging,
      this.photo,
      this.subCategory});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    descriptionEn = json['description_en'];
    descriptionAr = json['description_ar'];
    subCategoryId = json['sub_category_id'];
    active = json['active'];
    isPackaging = json['is_packaging'];
    photo = json['photo'];
    subCategory = json['sub_category'] != null
        ? SubCategory.fromJson(json['sub_category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['description_en'] = descriptionEn;
    data['description_ar'] = descriptionAr;
    data['sub_category_id'] = subCategoryId;
    data['active'] = active;
    data['is_packaging'] = isPackaging;
    data['photo'] = photo;
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    return data;
  }
}

class SubCategory2 {
  int? id;
  String? title;

  SubCategory2({this.id, this.title});

  SubCategory2.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
