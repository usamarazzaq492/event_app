class LoginModel {
  String? message;
  String? token;
  String? expiresAt;
  User? user;

  LoginModel({this.message, this.token, this.expiresAt, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    token = json['token'];
    expiresAt = json['expires_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['token'] = this.token;
    data['expires_at'] = this.expiresAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? userId;
  String? name;
  String? email;

  User({this.userId, this.name, this.email});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
