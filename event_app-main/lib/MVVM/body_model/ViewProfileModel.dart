class ViewPublicProfileModel {
  int? userId;
  String? name;
  String? profileImageUrl;
  String? shortBio;
  List<String>? interests;
  int? followersCount;
  int? followingCount;
  bool? isFollowing;

  ViewPublicProfileModel({
    this.userId,
    this.name,
    this.profileImageUrl,
    this.shortBio,
    this.interests,
    this.followersCount,
    this.followingCount,
    this.isFollowing,
  });

  ViewPublicProfileModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    profileImageUrl = json['profileImageUrl'];
    shortBio = json['shortBio'];

    // 🔹 Parse interests as List<String> (null-safe: API may return null in list)
    if (json['interests'] != null) {
      if (json['interests'] is String) {
        interests = (json['interests'] as String)
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (json['interests'] is List) {
        interests = (json['interests'] as List)
            .map((e) => (e == null ? '' : e).toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    followersCount = json['followers_count'];
    followingCount = json['following_count'];
    isFollowing = json['isFollowing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['name'] = name;
    data['profileImageUrl'] = profileImageUrl;
    data['shortBio'] = shortBio;
    data['interests'] = interests;
    data['followers_count'] = followersCount;
    data['following_count'] = followingCount;
    data['isFollowing'] = isFollowing;
    return data;
  }
}
