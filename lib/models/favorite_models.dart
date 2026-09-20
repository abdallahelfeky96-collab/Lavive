class AddToFavoriteModel {
  String? product_id;
  AddToFavoriteModel({this.product_id});

  Map<String, dynamic> toJson() {
    return {
      'product_id': product_id,
    };
  }
}

class GetAllFavoritesModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  GetAllFavoritesModel({this.status, this.code, this.msg, this.data});

  GetAllFavoritesModel.fromJson(Map<String, dynamic> json) {
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
  String? photo;
  int? minimumOrder;
  int? order;
  int? isActive;
  String? price;
  String? realPrice;
  String? code;
  int? amount;
  String? descriptionEn;
  String? descriptionAr;
  int? active;
  int? unitId;
  int? categoryId;
  String? createdAt;
  String? updatedAt;
  Null deletedAt;
  int? countryId;
  int? brandId;
  int? typeId;
  int? manufactureId;
  int? isPackaging;
  int? rate;
  int? subCategoryId;
  Pivot? pivot;
  SubCategory? subCategory;
  Unit? unit;
  String? myTitle;

  Data(
      {this.id,
      this.titleEn,
      this.titleAr,
      this.photo,
      this.minimumOrder,
      this.order,
      this.isActive,
      this.price,
      this.realPrice,
      this.code,
      this.amount,
      this.descriptionEn,
      this.descriptionAr,
      this.active,
      this.unitId,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.countryId,
      this.brandId,
      this.typeId,
      this.manufactureId,
      this.isPackaging,
      this.rate,
      this.subCategoryId,
      this.pivot,
      this.subCategory,
      this.unit,
      this.myTitle});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    photo = json['photo'];
    minimumOrder = json['minimum_order'];
    order = json['order'];
    isActive = json['is_active'];
    price = json['price'];
    realPrice = json['real_price'];
    code = json['code'];
    amount = json['amount'];
    descriptionEn = json['description_en'];
    descriptionAr = json['description_ar'];
    active = json['active'];
    unitId = json['unit_id'];
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    countryId = json['country_id'];
    brandId = json['brand_id'];
    typeId = json['type_id'];
    manufactureId = json['manufacture_id'];
    isPackaging = json['is_packaging'];
    rate = json['rate'];
    myTitle = json['my_title'];
    subCategoryId = json['sub_category_id'];

    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
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
    data['minimum_order'] = minimumOrder;
    data['order'] = order;
    data['is_active'] = isActive;
    data['price'] = price;
    data['real_price'] = realPrice;
    data['code'] = code;
    data['amount'] = amount;
    data['description_en'] = descriptionEn;
    data['description_ar'] = descriptionAr;
    data['active'] = active;
    data['unit_id'] = unitId;
    data['category_id'] = categoryId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['country_id'] = countryId;
    data['brand_id'] = brandId;
    data['type_id'] = typeId;
    data['manufacture_id'] = manufactureId;
    data['is_packaging'] = isPackaging;
    data['rate'] = rate;
    data['sub_category_id'] = subCategoryId;
    data['my_title'] = myTitle;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? clientId;
  int? productId;

  Pivot({this.clientId, this.productId});

  Pivot.fromJson(Map<String, dynamic> json) {
    clientId = json['client_id'];
    productId = json['product_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_id'] = clientId;
    data['product_id'] = productId;
    return data;
  }
}

class SubCategory {
  int? id;
  String? title;
  String? photo;

  SubCategory({this.id, this.title, this.photo});

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['photo'] = photo;
    return data;
  }
}

class Unit {
  int? id;
  String? title;

  Unit({this.id, this.title});

  Unit.fromJson(Map<String, dynamic> json) {
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
