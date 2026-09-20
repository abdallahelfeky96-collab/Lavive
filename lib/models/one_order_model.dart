class OneOrderModel {
  bool? status;
  int? code;
  String? msg;
  Data? data;

  OneOrderModel({this.status, this.code, this.msg, this.data});

  OneOrderModel.fromJson(Map<String, dynamic> json) {
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
  int? clientId;
  int? deliveryPrice;
  dynamic deliveryId;
  int? deliveryType;
  int? paidType;
  dynamic description;
  dynamic photo;
  String? price;
  String? date;
  int? seen;
  int? type;
  int? status;
  dynamic latitude;
  dynamic longitude;
  String? addressId; // Changed from int? to String?
  dynamic couponId;
  String? priceAfterOffer;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  int? isPaid;
  int? decrement;
  int? isReturned;
  int? pointsAdd;
  int? amountOfPoints;
  int? amountOfWallet;
  int? donated;
  int? walletAdd;
  bool? canCancel; // Added canCancel field
  dynamic canceledBy; // Added canceledBy field
  dynamic coupon;
  List<Products>? products;
  int? promoCodeId;
  String? amountPaidUsingWallet;
  String? couponAmount;
  String? notes;
  dynamic scheduledDeliveryDate; // Added scheduledDeliveryDate field
  dynamic refundReason; // Added refundReason field
  dynamic refundStatus; // Added refundStatus field
  dynamic adminRejectionReason; // Added adminRejectionReason field
  String? orderCode; // Added orderCode field

  Data({
    this.id,
    this.clientId,
    this.deliveryPrice,
    this.deliveryId,
    this.deliveryType,
    this.paidType,
    this.description,
    this.photo,
    this.price,
    this.date,
    this.seen,
    this.type,
    this.status,
    this.latitude,
    this.longitude,
    this.addressId,
    this.couponId,
    this.couponAmount,
    this.priceAfterOffer,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isPaid,
    this.decrement,
    this.isReturned,
    this.pointsAdd,
    this.amountOfPoints,
    this.amountOfWallet,
    this.donated,
    this.walletAdd,
    this.canCancel,
    this.canceledBy,
    this.coupon,
    this.amountPaidUsingWallet,
    this.notes,
    this.promoCodeId,
    this.products,
    this.scheduledDeliveryDate,
    this.refundReason,
    this.refundStatus,
    this.adminRejectionReason,
    this.orderCode,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    deliveryPrice = json['delivery_price'];
    deliveryId = json['delivery_id'];
    deliveryType = json['delivery_type'];
    paidType = json['paid_type'];
    description = json['description'];
    photo = json['photo'];
    price = json['price'];
    date = json['date'];
    seen = json['seen'];
    type = json['type'];
    status = json['status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    addressId = json['address_id']?.toString(); // Convert to String
    couponId = json['coupon_id'];
    couponAmount = json['coupon_amount']?.toString();
    priceAfterOffer = json['price_after_offer'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    isPaid = json['is_paid'];
    decrement = json['decrement'];
    isReturned = json['is_returned'];
    pointsAdd = json['points_add'];
    amountOfPoints = json['amount_of_points'];
    amountOfWallet = json['amount_of_wallet'];
    donated = json['donated'];
    walletAdd = json['wallet_add'];
    canCancel = json['can_cancel']; // Parse can_cancel
    canceledBy = json['canceled_by']; // Parse canceled_by
    coupon = json['coupon'];
    promoCodeId = json['promo_code_id'];
    amountPaidUsingWallet = json['amount_paid_using_wallet'];
    notes = json['notes'];
    scheduledDeliveryDate = json['scheduled_delivery_date'];
    refundReason = json['refund_reason'];
    refundStatus = json['refund_status'];
    adminRejectionReason = json['admin_rejection_reason'];
    orderCode = json['order_code'];

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
    data['client_id'] = clientId;
    data['delivery_price'] = deliveryPrice;
    data['delivery_id'] = deliveryId;
    data['delivery_type'] = deliveryType;
    data['paid_type'] = paidType;
    data['description'] = description;
    data['photo'] = photo;
    data['price'] = price;
    data['date'] = date;
    data['seen'] = seen;
    data['type'] = type;
    data['status'] = status;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address_id'] = addressId;
    data['coupon_id'] = couponId;
    data['coupon_amount'] = couponAmount;
    data['price_after_offer'] = priceAfterOffer;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['is_paid'] = isPaid;
    data['decrement'] = decrement;
    data['is_returned'] = isReturned;
    data['points_add'] = pointsAdd;
    data['amount_of_points'] = amountOfPoints;
    data['amount_of_wallet'] = amountOfWallet;
    data['donated'] = donated;
    data['wallet_add'] = walletAdd;
    data['can_cancel'] = canCancel;
    data['canceled_by'] = canceledBy;
    data['promo_code_id'] = promoCodeId;
    data['amount_paid_using_wallet'] = amountPaidUsingWallet;
    data['notes'] = notes;
    data['coupon'] = coupon;
    data['scheduled_delivery_date'] = scheduledDeliveryDate;
    data['refund_reason'] = refundReason;
    data['refund_status'] = refundStatus;
    data['admin_rejection_reason'] = adminRejectionReason;
    data['order_code'] = orderCode;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? id;
  String? realPrice;
  String? price;
  String? photo;
  String? title;
  String? titleEn;
  String? titleAr;
  int? minimumOrder;
  int? order;
  String? code;
  int? amount;
  String? descriptionEn;
  String? descriptionAr;
  int? active;
  int? unitId;
  int? categoryId;
  int? countryId;
  dynamic brandId;
  dynamic typeId;
  dynamic manufactureId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  int? isPackaging;
  int? rate;
  int? subCategoryId;
  String? packaging;
  String? deliveryPrice;
  String? scheduledDeliveryPrice;
  String? myTitle;
  String? myDescription;
  Pivot? pivot;

  Products({
    this.id,
    this.realPrice,
    this.price,
    this.photo,
    this.title,
    this.titleEn,
    this.titleAr,
    this.minimumOrder,
    this.order,
    this.code,
    this.amount,
    this.descriptionEn,
    this.descriptionAr,
    this.active,
    this.unitId,
    this.categoryId,
    this.countryId,
    this.brandId,
    this.typeId,
    this.manufactureId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isPackaging,
    this.rate,
    this.subCategoryId,
    this.packaging,
    this.deliveryPrice,
    this.scheduledDeliveryPrice,
    this.myTitle,
    this.myDescription,
    this.pivot,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    realPrice = json['real_price'];
    price = json['price'];
    photo = json['photo'];
    title = json['title'];
    titleEn = json['title_en'];
    titleAr = json['title_ar'];
    minimumOrder = json['minimum_order'];
    order = json['order'];
    code = json['code'];
    amount = json['amount'];
    descriptionEn = json['description_en'];
    descriptionAr = json['description_ar'];
    active = json['active'];
    unitId = json['unit_id'];
    categoryId = json['category_id'];
    countryId = json['country_id'];
    brandId = json['brand_id'];
    typeId = json['type_id'];
    manufactureId = json['manufacture_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    isPackaging = json['is_packaging'];
    rate = json['rate'];
    subCategoryId = json['sub_category_id'];
    packaging = json['packaging'];
    deliveryPrice = json['delivery_price'];
    scheduledDeliveryPrice = json['scheduled_delivery_price'];
    myTitle = json['my_title'];
    myDescription = json['my_description'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['real_price'] = realPrice;
    data['price'] = price;
    data['photo'] = photo;
    data['title'] = title;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['minimum_order'] = minimumOrder;
    data['order'] = order;
    data['code'] = code;
    data['amount'] = amount;
    data['description_en'] = descriptionEn;
    data['description_ar'] = descriptionAr;
    data['active'] = active;
    data['unit_id'] = unitId;
    data['category_id'] = categoryId;
    data['country_id'] = countryId;
    data['brand_id'] = brandId;
    data['type_id'] = typeId;
    data['manufacture_id'] = manufactureId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['is_packaging'] = isPackaging;
    data['rate'] = rate;
    data['sub_category_id'] = subCategoryId;
    data['packaging'] = packaging;
    data['delivery_price'] = deliveryPrice;
    data['scheduled_delivery_price'] = scheduledDeliveryPrice;
    data['my_title'] = myTitle;
    data['my_description'] = myDescription;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? orderId;
  int? productId;
  String? price;
  int? amount;
  int? packaging;
  int? id;
  int? packagingPrice;

  Pivot({
    this.orderId,
    this.productId,
    this.price,
    this.amount,
    this.packaging,
    this.id,
    this.packagingPrice,
  });

  Pivot.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    productId = json['product_id'];
    price = json['price'];
    amount = json['amount'];
    packaging = json['packaging'];
    id = json['id'];
    packagingPrice = json['packaging_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['order_id'] = orderId;
    data['product_id'] = productId;
    data['price'] = price;
    data['amount'] = amount;
    data['packaging'] = packaging;
    data['id'] = id;
    data['packaging_price'] = packagingPrice;
    return data;
  }
}
