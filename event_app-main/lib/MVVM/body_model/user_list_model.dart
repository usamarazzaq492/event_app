class UserListModel {
  bool? success;
  List<Data>? data;
  String? message;
  int? count;

  UserListModel({this.success, this.data, this.message, this.count});

  UserListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['count'] = this.count;
    return data;
  }
}

class Data {
  int? userId;
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  String? shortBio;
  List<String>? interests;
  bool? isActive;
  bool? emailVerified;
  String? createdAt;

  Data(
      {this.userId,
        this.name,
        this.email,
        this.phoneNumber,
        this.profileImageUrl,
        this.shortBio,
        this.interests,
        this.isActive,
        this.emailVerified,
        this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    profileImageUrl = json['profileImageUrl'];
    shortBio = json['shortBio'];
    interests = json['interests'] is List
        ? (json['interests'] as List).map((e) => e.toString()).toList()
        : null;
    isActive = json['isActive'];
    emailVerified = json['emailVerified'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['profileImageUrl'] = this.profileImageUrl;
    data['shortBio'] = this.shortBio;
    data['interests'] = this.interests;
    data['isActive'] = this.isActive;
    data['emailVerified'] = this.emailVerified;
    data['created_at'] = this.createdAt;
    return data;
  }
}
