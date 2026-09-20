class SubProductsModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  SubProductsModel({this.status, this.code, this.msg, this.data});

  SubProductsModel.fromJson(Map<String, dynamic> json) {
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
  String? myTitlle;

  SubCategory(
      {this.id,
      this.titleEn,
      this.titleAr,
      this.photo,
      this.active,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.myTitlle});

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    photo = json['photo'];
    active = json['active'];
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    myTitlle = json['my_title'];
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
    data['my_title'] = myTitlle;
    return data;
  }
}

class Products {
  int? id;
  String? titleEn;
  String? titleAr;
  String? photo;
  String? price;
  String? realPrice;
  int? quantity;
  int? minimumOrder;
  int? order;
  String? code;
  int? amount;
  String? myTitle;
  String? descriptionEn;
  String? descriptionAr;
  int? subCategoryId;
  int? active;
  int? isPackaging;
  int? rate;
  int? unitId;
  int? categoryId;
  int? countryId;
  int? brandId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? packaging;

  SubCategory? subCategory;
  Unit? unit;

  Products({
    this.id,
    this.titleEn,
    this.titleAr,
    this.photo,
    this.price,
    this.realPrice,
    this.quantity,
    this.minimumOrder,
    this.order,
    this.code,
    this.amount,
    this.myTitle,
    this.descriptionEn,
    this.descriptionAr,
    this.subCategoryId,
    this.active,
    this.isPackaging,
    this.rate,
    this.unitId,
    this.categoryId,
    this.countryId,
    this.brandId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.packaging,
    this.subCategory,
    this.unit,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    photo = json['photo'];
    price = json['price'];
    realPrice = json['real_price'];
    quantity = json['quantity'];
    minimumOrder = json['minimum_order'];
    order = json['order'];
    code = json['code'];
    amount = json['amount'];
    myTitle = json['my_title'];
    descriptionEn = json['description_en'];
    descriptionAr = json['description_ar'];
    subCategoryId = json['sub_category_id'];
    active = json['active'];
    isPackaging = json['is_packaging'];
    rate = json['rate'];
    unitId = json['unit_id'];
    categoryId = json['category_id'];
    countryId = json['country_id'];
    brandId = json['brand_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    packaging = json['packaging'];
    subCategory = json['sub_category'] != null
        ? SubCategory.fromJson(json['sub_category'])
        : null;
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['photo'] = photo;
    data['price'] = price;
    data['real_price'] = realPrice;
    data['quantity'] = quantity;
    data['minimum_order'] = minimumOrder;
    data['order'] = order;
    data['code'] = code;
    data['amount'] = amount;
    data['my_title'] = myTitle;
    data['description_en'] = descriptionEn;
    data['description_ar'] = descriptionAr;
    data['sub_category_id'] = subCategoryId;
    data['active'] = active;
    data['is_packaging'] = isPackaging;
    data['rate'] = rate;
    data['unit_id'] = unitId;
    data['category_id'] = categoryId;
    data['country_id'] = countryId;
    data['brand_id'] = brandId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['packaging'] = packaging;
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    return data;
  }
}

class Unit {
  int? id;
  String? title;
  String? titleEn;
  String? titleAr;
  String? myTitle;

  Unit({this.id, this.title, this.titleEn, this.titleAr, this.myTitle});

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    myTitle = json['my_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['my_title'] = myTitle;
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
