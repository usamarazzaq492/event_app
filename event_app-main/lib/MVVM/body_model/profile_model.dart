import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  bool? success;
  Data? data;
  String? message;

  ProfileModel({
    this.success,
    this.data,
    this.message,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    success: json["success"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  int? userId;
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  String? shortBio;
  List<String>? interests;
  DateTime? createdAt;
  int? followersCount;
  int? followingCount;

  Data({
    this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.shortBio,
    this.interests,
    this.createdAt,
    this.followersCount,
    this.followingCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    name: json["name"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    profileImageUrl: json["profileImageUrl"],
    shortBio: json["shortBio"],
    interests: json["interests"] == null
        ? []
        : List<String>.from(json["interests"].map((x) => x)),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    followersCount: json["followers_count"] ?? 0,
    followingCount: json["following_count"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "name": name,
    "email": email,
    "phoneNumber": phoneNumber,
    "profileImageUrl": profileImageUrl,
    "shortBio": shortBio,
    "interests": interests != null
        ? List<dynamic>.from(interests!.map((x) => x))
        : [],
    "created_at": createdAt?.toIso8601String(),
    "followers_count": followersCount,
    "following_count": followingCount,
  };
}
