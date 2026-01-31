class EventDetailModel {
  int? eventId;
  int? userId;
  String? eventTitle;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? eventPrice;
  String? vipPrice;
  String? description;
  String? category;
  String? address;
  String? city;
  String? latitude;
  String? longitude;
  String? eventImage;
  String? liveStreamUrl;
  String? liveStreamEmbedUrl;
  bool? hasLiveStreamAccess;
  bool? isOrganizer;
  int? isActive;
  String? addDate;
  String? editDate;
  bool? isBooked; // changed to bool
  bool? isPromoted;
  String? promotionStartDate;
  String? promotionEndDate;
  String? promotionPackage;

  EventDetailModel({
    this.eventId,
    this.userId,
    this.eventTitle,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.eventPrice,
    this.vipPrice,
    this.description,
    this.category,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.eventImage,
    this.liveStreamUrl,
    this.liveStreamEmbedUrl,
    this.hasLiveStreamAccess,
    this.isOrganizer,
    this.isActive,
    this.addDate,
    this.editDate,
    this.isBooked, // updated
    this.isPromoted,
    this.promotionStartDate,
    this.promotionEndDate,
    this.promotionPackage,
  });

  EventDetailModel.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    userId = json['userId'];
    eventTitle = json['eventTitle'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    eventPrice = json['eventPrice'];
    vipPrice = json['vipPrice'];
    description = json['description'];
    category = json['category'];
    address = json['address'];
    city = json['city'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    eventImage = json['eventImage'];
    liveStreamUrl = json['live_stream_url'];
    liveStreamEmbedUrl = json['live_stream_embed_url'];
    hasLiveStreamAccess = json['hasLiveStreamAccess'];
    isOrganizer = json['isOrganizer'];
    isActive = json['isActive'];
    addDate = json['addDate'];
    editDate = json['editDate'];
    isBooked = json['isBooked'] == true || json['isBooked'] == '1'; // updated
    isPromoted = json['isPromoted'] == 1 || json['isPromoted'] == true;
    promotionStartDate = json['promotionStartDate'];
    promotionEndDate = json['promotionEndDate'];
    promotionPackage = json['promotionPackage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['eventId'] = eventId;
    data['userId'] = userId;
    data['eventTitle'] = eventTitle;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['eventPrice'] = eventPrice;
    data['vipPrice'] = vipPrice;
    data['description'] = description;
    data['category'] = category;
    data['address'] = address;
    data['city'] = city;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['eventImage'] = eventImage;
    data['live_stream_url'] = liveStreamUrl;
    data['live_stream_embed_url'] = liveStreamEmbedUrl;
    data['hasLiveStreamAccess'] = hasLiveStreamAccess;
    data['isOrganizer'] = isOrganizer;
    data['isActive'] = isActive;
    data['addDate'] = addDate;
    data['editDate'] = editDate;
    data['isBooked'] = isBooked; // updated
    return data;
  }

  /// Check if promotion is currently active (isPromoted=true AND promotionEndDate has not passed)
  bool get isPromotionActive {
    if (isPromoted == null || !isPromoted!) return false;
    if (promotionEndDate == null || promotionEndDate!.trim().isEmpty) {
      return true; // Marked promoted but no end date → treat as active
    }
    try {
      String dateStr = promotionEndDate!.trim();
      if (dateStr.contains(' ') && !dateStr.contains('T')) {
        dateStr = dateStr.replaceFirst(' ', 'T'); // Dart parse prefers T for ISO
      }
      final endDate = DateTime.parse(dateStr);
      return DateTime.now().isBefore(endDate);
    } catch (e) {
      return true; // Parse failed → treat as active if isPromoted
    }
  }
}
