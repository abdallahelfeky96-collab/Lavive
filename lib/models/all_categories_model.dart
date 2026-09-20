class AllCategories {
  bool? status;
  int? code;
  String? msg;
  List<Data>? data;

  AllCategories({this.status, this.code, this.msg, this.data});

  AllCategories.fromJson(Map<String, dynamic> json) {
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
  String? photo;
  String? backgroundPhoto;
  String? color;

  Data({this.id, this.title, this.photo, this.backgroundPhoto, this.color});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    photo = json['photo'];
    backgroundPhoto = json['background_photo'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['photo'] = photo;
    data['background_photo'] = backgroundPhoto;
    data['color'] = color;
    return data;
  }
}
