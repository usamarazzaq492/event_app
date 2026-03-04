class AdsModel {
  int? donationId;
  int? eventId; // Added for promoted events (same as donationId when mapped from eventId)
  int? userId;
  String? title;
  String? imageUrl;
  String? description;
  String? amount;
  String? city;
  String? state;
  String? zipcode;
  int? isActive;
  String? addDate;
  String? updatedAt;

  AdsModel(
      {this.donationId,
      this.eventId,
      this.userId,
      this.title,
      this.imageUrl,
      this.description,
      this.amount,
      this.city,
      this.state,
      this.zipcode,
      this.isActive,
      this.addDate,
      this.updatedAt});

  AdsModel.fromJson(Map<String, dynamic> json) {
    donationId = json['donationId'] is int
        ? json['donationId']
        : int.tryParse(json['donationId']?.toString() ?? '');
    // eventId is also returned for promoted events
    eventId = json['eventId'] is int
        ? json['eventId']
        : (json['eventId'] != null ? int.tryParse(json['eventId']?.toString() ?? '') : donationId);
    userId = json['userId'] is int
        ? json['userId']
        : int.tryParse(json['userId']?.toString() ?? '');
    title = json['title'];
    imageUrl = json['imageUrl'];
    description = json['description'];
    amount = json['amount']?.toString();
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    isActive = json['isActive'] is int
        ? json['isActive']
        : int.tryParse(json['isActive']?.toString() ?? '');
    addDate = json['addDate'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['donationId'] = donationId;
    data['eventId'] = eventId;
    data['userId'] = userId;
    data['title'] = title;
    data['imageUrl'] = imageUrl;
    data['description'] = description;
    data['amount'] = amount;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['isActive'] = isActive;
    data['addDate'] = addDate;
    data['updated_at'] = updatedAt;
    return data;
  }
}
