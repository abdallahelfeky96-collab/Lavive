class SendMessageModel {
  String message;
  SendMessageModel({required this.message});

  Map<String, dynamic> toJson() {
    return {"message": message};
  }
}

class MessageModel {
  bool? status;
  int? code;
  String? msg;
  Data? data;

  MessageModel({this.status, this.code, this.msg, this.data});

  MessageModel.fromJson(Map<String, dynamic> json) {
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

  // Add copyWith method
  MessageModel copyWith({
    bool? status,
    int? code,
    String? msg,
    Data? data,
  }) {
    return MessageModel(
      status: status ?? this.status,
      code: code ?? this.code,
      msg: msg ?? this.msg,
      data: data ?? this.data,
    );
  }
}

class Data {
  int? id;
  int? clientId;
  List<Messages>? messages;

  Data({this.id, this.clientId, this.messages});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Add copyWith method
  Data copyWith({
    int? id,
    int? clientId,
    List<Messages>? messages,
  }) {
    return Data(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      messages: messages ?? this.messages,
    );
  }
}

class Messages {
  int? id;
  String? message;
  int? chatId;
  dynamic adminId;
  String? createdAt;

  Messages({this.id, this.message, this.chatId, this.adminId, this.createdAt});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    chatId = json['chat_id'];
    adminId = json['admin_id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['chat_id'] = chatId;
    data['admin_id'] = adminId;
    data['created_at'] = createdAt;
    return data;
  }

  // Add copyWith method
  Messages copyWith({
    int? id,
    String? message,
    int? chatId,
    dynamic adminId,
    String? createdAt,
  }) {
    return Messages(
      id: id ?? this.id,
      message: message ?? this.message,
      chatId: chatId ?? this.chatId,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
