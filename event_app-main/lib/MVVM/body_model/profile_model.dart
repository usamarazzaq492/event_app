import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    Data? data;
    if (json["data"] != null && json["data"] is Map) {
      try {
        data = Data.fromJson(Map<String, dynamic>.from(json["data"] as Map));
      } catch (e) {
        // Catch TypeError (null not subtype of String) and other parse errors
        data = null;
      }
    }
    return ProfileModel(
      success: json["success"] == true,
      data: data,
      message: json["message"]?.toString(),
    );
  }

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

  factory Data.fromJson(Map<String, dynamic> json) {
    List<String> parseInterests(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val
            .map((x) => (x == null ? '' : x).toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (val is String) {
        return val
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    }

    final userId = json["userId"];
    final fc = json["followers_count"];
    final flc = json["following_count"];
    final createdVal = json["created_at"];

    return Data(
      userId: userId is int ? userId : int.tryParse(userId?.toString() ?? ''),
      name: json["name"]?.toString(),
      email: json["email"]?.toString(),
      phoneNumber: json["phoneNumber"]?.toString(),
      profileImageUrl: json["profileImageUrl"]?.toString(),
      shortBio: json["shortBio"]?.toString(),
      interests: parseInterests(json["interests"]),
      createdAt:
          createdVal == null ? null : DateTime.tryParse(createdVal.toString()),
      followersCount:
          fc is int ? fc : (int.tryParse(fc?.toString() ?? '') ?? 0),
      followingCount:
          flc is int ? flc : (int.tryParse(flc?.toString() ?? '') ?? 0),
    );
  }

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
