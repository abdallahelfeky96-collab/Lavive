import 'package:hive/hive.dart';

part 'one_product_model.g.dart';

@HiveType(typeId: 0) // Define Hive type
class ProductModel extends HiveObject {
  @HiveField(0) // Field 0
  bool? status;

  @HiveField(1) // Field 1
  int? code;

  @HiveField(2)
  String? msg;

  @HiveField(3)
  Data? data;

  ProductModel({this.status, this.code, this.msg, this.data});

  // Factory for parsing JSON response
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      status: json['status'],
      code: json['code'],
      msg: json['msg'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
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

@HiveType(typeId: 1)
class Data extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? photo;

  @HiveField(2)
  String? price;

  @HiveField(3)
  String? realPrice;

  @HiveField(4)
  int? rate;

  @HiveField(5)
  String? code;

  @HiveField(6)
  int? amount;

  @HiveField(7)
  String? description;

  @HiveField(8)
  SubCategory? subCategory;

  @HiveField(9)
  double? quantity;

  @HiveField(10)
  int? id;

  @HiveField(11)
  String? myTitle;

  @HiveField(12)
  String? myDescription;

  @HiveField(13)
  String? packaging; // New field for packaging price

  @HiveField(14)
  int? isPackaging;

  @HiveField(15)
  Unit? unit;

  Data({
    this.title,
    this.id,
    this.photo,
    this.price,
    this.realPrice,
    this.rate,
    this.code,
    this.amount,
    this.description,
    this.subCategory,
    this.quantity,
    this.myTitle,
    this.myDescription,
    this.packaging, // Include packaging price
    this.isPackaging,
    this.unit,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      title: json['title'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      id: json['id'],
      photo: json['photo'],
      price: json['price'],
      realPrice: json['real_price'],
      rate: json['rate'],
      code: json['code'],
      amount: json['amount'],
      description: json['description'],
      myTitle: json['myTitle'],
      myDescription: json['myDescription'],
      packaging: json['packaging'], // Parse packaging price from JSON
      isPackaging: json['isPackaging'] ?? 0,
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['photo'] = photo;
    data['price'] = price;
    data['real_price'] = realPrice;
    data['rate'] = rate;
    data['code'] = code;
    data['amount'] = amount;
    data['description'] = description;
    data['myTitle'] = myTitle;
    data['myDescription'] = myDescription;
    data['packaging'] = packaging; // Add packaging price to JSON
    data['isPackaging'] = isPackaging;
    data['quantity'] = quantity; // Save quantity as double
    if (subCategory != null) {
      data['subCategory'] = subCategory!.toJson();
    }
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 2)
class SubCategory extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  SubCategory({this.id, this.title});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}

@HiveType(typeId: 3)
class Unit extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? titleEn;

  @HiveField(3)
  String? titleAr;

  @HiveField(4)
  String? myTitle;

  Unit({this.id, this.title, this.titleEn, this.titleAr, this.myTitle});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      title: json['title'],
      titleEn: json['title_en'],
      titleAr: json['title_ar'],
      myTitle: json['my_title'],
    );
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
