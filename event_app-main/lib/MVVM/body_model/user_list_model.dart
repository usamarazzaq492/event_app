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
        data!.add(Data.fromJson(v));
      });
    }
    message = json['message'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['count'] = count;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['profileImageUrl'] = profileImageUrl;
    data['shortBio'] = shortBio;
    data['interests'] = interests;
    data['isActive'] = isActive;
    data['emailVerified'] = emailVerified;
    data['created_at'] = createdAt;
    return data;
  }
}
