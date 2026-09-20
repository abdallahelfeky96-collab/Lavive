class NotisCountModel {
  bool? status;
  int? code;
  String? msg;
  int? data;

  NotisCountModel({this.status, this.code, this.msg, this.data});

  NotisCountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    msg = json['msg'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['msg'] = msg;
    data['data'] = this.data;
    return data;
  }
}

class NotisModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  NotisModel({this.status, this.code, this.msg, this.data});

  NotisModel.fromJson(Map<String, dynamic> json) {
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
  String? title;
  String? body;
  dynamic type;
  String? createdAt;
  String? updatedAt;
  dynamic photo;
  int? productId;
  int? orderId;
  int? categoryId;
  dynamic clientId;
  Pivot? pivot;

  Data(
      {this.id,
      this.title,
      this.categoryId,
      this.orderId,
      this.body,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.photo,
      this.productId,
      this.clientId,
      this.pivot});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryId = json['category_id'];
    orderId = json['order_id'];

    photo = json['photo'];
    productId = json['product_id'];
    clientId = json['client_id'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['body'] = body;
    data['type'] = type;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['photo'] = photo;
    data['product_id'] = productId;
    data['category_id'] = categoryId;
    data['order_id'] = orderId;
    data['client_id'] = clientId;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? clientId;
  int? notificationId;
  int? seen;

  Pivot({this.clientId, this.notificationId, this.seen});

  Pivot.fromJson(Map<String, dynamic> json) {
    clientId = json['client_id'];
    notificationId = json['notification_id'];
    seen = json['seen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_id'] = clientId;
    data['notification_id'] = notificationId;
    data['seen'] = seen;
    return data;
  }
}
