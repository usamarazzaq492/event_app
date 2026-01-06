class EventModel {
  final int? eventId;
  final String? eventTitle;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? eventPrice;
  final String? description;
  final String? category;
  final String? address;
  final String? city;
  final String? eventImage;
  final String? latitude;
  final String? longitude;
  final String? liveStreamUrl;
  final String? liveStreamEmbedUrl;
  final bool? hasLiveStreamAccess;
  final bool? isBooked;
  final bool? isOrganizer;
  final bool? isPromoted;
  final String? promotionStartDate;
  final String? promotionEndDate;
  final String? promotionPackage;
  final String? userName;
  final String? userProfileImage;

  EventModel({
    this.eventId,
    this.eventTitle,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.eventPrice,
    this.description,
    this.category,
    this.address,
    this.city,
    this.eventImage,
    this.latitude,
    this.longitude,
    this.liveStreamUrl,
    this.liveStreamEmbedUrl,
    this.hasLiveStreamAccess,
    this.isBooked,
    this.isOrganizer,
    this.isPromoted,
    this.promotionStartDate,
    this.promotionEndDate,
    this.promotionPackage,
    this.userName,
    this.userProfileImage,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      eventPrice: json['eventPrice'],
      description: json['description'],
      category: json['category'],
      address: json['address'],
      city: json['city'],
      eventImage: json['eventImage'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      liveStreamUrl: json['live_stream_url'],
      liveStreamEmbedUrl: json['live_stream_embed_url'],
      hasLiveStreamAccess: json['hasLiveStreamAccess'],
      isBooked: json['isBooked'],
      isOrganizer: json['isOrganizer'],
      isPromoted: json['isPromoted'] == 1 || json['isPromoted'] == true,
      promotionStartDate: json['promotionStartDate'],
      promotionEndDate: json['promotionEndDate'],
      promotionPackage: json['promotionPackage'],
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
    );
  }

  /// Check if promotion is currently active
  bool get isPromotionActive {
    if (isPromoted == null || !isPromoted!) return false;
    if (promotionEndDate == null) return false;
    try {
      final endDate = DateTime.parse(promotionEndDate!);
      return DateTime.now().isBefore(endDate);
    } catch (e) {
      return false;
    }
  }
}
