class UserDetails {
  String? displayName;
  String? email;
  String? photoURL;
  String? uid;
  String? provider;

  //constructor
  UserDetails(
      {this.displayName, this.email, this.photoURL, this.uid, this.provider});

  // we need to create map
  UserDetails.fromJson(Map<String, dynamic> json) {
    displayName = json["displayName"];
    photoURL = json["photoUrl"];
    email = json["email"];
    uid = json["uid"];
    provider = json["provider"];
  }
  Map<String, dynamic> toJson() {
    // object - data
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayName'] = displayName;
    data['email'] = email;
    data['photoUrl'] = photoURL;
    data['uid'] = uid;
    data['provider'] = provider;

    return data;
  }
}
