class MyEventModel {
  int? eventId;
  int? userId;
  String? eventTitle;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? eventPrice;
  String? description;
  String? category;
  String? address;
  String? city;
  String? eventImage;
  int? isActive;
  String? addDate;
  String? editDate;
  int? isPromoted;
  String? promotionStartDate;
  String? promotionEndDate;
  String? promotionPackage;

  MyEventModel(
      {this.eventId,
        this.userId,
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
        this.isActive,
        this.addDate,
        this.editDate,
        this.isPromoted,
        this.promotionStartDate,
        this.promotionEndDate,
        this.promotionPackage});

  MyEventModel.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    userId = json['userId'];
    eventTitle = json['eventTitle'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    eventPrice = json['eventPrice'];
    description = json['description'];
    category = json['category'];
    address = json['address'];
    city = json['city'];
    eventImage = json['eventImage'];
    isActive = json['isActive'];
    addDate = json['addDate'];
    editDate = json['editDate'];
    isPromoted = json['isPromoted'];
    promotionStartDate = json['promotionStartDate'];
    promotionEndDate = json['promotionEndDate'];
    promotionPackage = json['promotionPackage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['userId'] = this.userId;
    data['eventTitle'] = this.eventTitle;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['eventPrice'] = this.eventPrice;
    data['description'] = this.description;
    data['category'] = this.category;
    data['address'] = this.address;
    data['city'] = this.city;
    data['eventImage'] = this.eventImage;
    data['isActive'] = this.isActive;
    data['addDate'] = this.addDate;
    data['editDate'] = this.editDate;
    data['isPromoted'] = this.isPromoted;
    data['promotionStartDate'] = this.promotionStartDate;
    data['promotionEndDate'] = this.promotionEndDate;
    data['promotionPackage'] = this.promotionPackage;
    return data;
  }

  /// Parse date from server (handles both ISO 8601 with timezone and MySQL datetime format)
  DateTime? _parseServerDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Check if date has timezone info (ISO 8601 format)
      if (dateString.endsWith('Z') || 
          dateString.contains('+') || 
          (dateString.length > 10 && (dateString[dateString.length - 6] == '+' || dateString[dateString.length - 6] == '-'))) {
        // Has timezone info, parse directly
        return DateTime.parse(dateString).toUtc();
      } else {
        // No timezone info (MySQL datetime format like "2024-01-15 10:30:00")
        // Assume UTC since server stores in UTC
        return DateTime.parse('${dateString.replaceAll(' ', 'T')}Z').toUtc();
      }
    } catch (e) {
      return null;
    }
  }

  /// Check if promotion is currently active
  bool get isPromotionActive {
    if (isPromoted == null || isPromoted == 0) return false;
    if (promotionEndDate == null || promotionEndDate!.isEmpty) return false;
    try {
      final endDate = _parseServerDate(promotionEndDate);
      if (endDate == null) return false;
      return DateTime.now().toUtc().isBefore(endDate);
    } catch (e) {
      return false;
    }
  }

  /// Get remaining promotion days
  int? get remainingPromotionDays {
    if (!isPromotionActive) return null;
    try {
      final endDate = _parseServerDate(promotionEndDate);
      if (endDate == null) return null;
      final now = DateTime.now().toUtc();
      final difference = endDate.difference(now);
      return difference.inDays;
    } catch (e) {
      return null;
    }
  }
}
