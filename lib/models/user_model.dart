class UserModel {
  String? name, email, deviceToken, password, phone, provider, uid;
  dynamic image;

  UserModel(
      {this.image,
      this.name,
      this.password,
      this.email,
      this.phone,
      this.deviceToken,
      this.provider,
      this.uid});

  Map<String, dynamic> toJson() {
    return {
      "image": image,
      "name": name,
      "password": password,
      "email": email,
      "phone": phone,
      "device_token": deviceToken,
      "provider": provider,
      "uid": uid
    };
  }
}
