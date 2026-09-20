class AllOrdersModel {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  AllOrdersModel({this.status, this.code, this.msg, this.data});

  AllOrdersModel.fromJson(Map<String, dynamic> json) {
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
  int? productsCount;
  bool? canCancel; // Added canCancel field
  dynamic canceledBy; // Added canceledBy field
  Address? address;
  dynamic coupon;
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
    this.productsCount,
    this.canCancel,
    this.canceledBy,
    this.address,
    this.coupon,
    this.promoCodeId,
    this.amountPaidUsingWallet,
    this.notes,
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
    productsCount = json['products_count'];
    canCancel = json['can_cancel']; // Parse can_cancel
    canceledBy = json['canceled_by']; // Parse canceled_by
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    coupon = json['coupon'];
    promoCodeId = json['promo_code_id'];
    amountPaidUsingWallet = json['amount_paid_using_wallet'];
    notes = json['notes'];
    scheduledDeliveryDate = json['scheduled_delivery_date'];
    refundReason = json['refund_reason'];
    refundStatus = json['refund_status'];
    adminRejectionReason = json['admin_rejection_reason'];
    orderCode = json['order_code'];
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
    data['products_count'] = productsCount;
    data['can_cancel'] = canCancel;
    data['canceled_by'] = canceledBy;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['coupon'] = coupon;
    data['promo_code_id'] = promoCodeId;
    data['amount_paid_using_wallet'] = amountPaidUsingWallet;
    data['notes'] = notes;
    data['scheduled_delivery_date'] = scheduledDeliveryDate;
    data['refund_reason'] = refundReason;
    data['refund_status'] = refundStatus;
    data['admin_rejection_reason'] = adminRejectionReason;
    data['order_code'] = orderCode;
    return data;
  }
}

class Address {
  int? id;
  String? title;
  String? phone;
  String? address;
  int? clientId;
  String? createdAt;
  String? updatedAt;

  Address({
    this.id,
    this.title,
    this.phone,
    this.address,
    this.clientId,
    this.createdAt,
    this.updatedAt,
  });

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    phone = json['phone'];
    address = json['address'];
    clientId = json['client_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['phone'] = phone;
    data['address'] = address;
    data['client_id'] = clientId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
