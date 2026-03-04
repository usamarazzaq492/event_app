class AdsDetailModel {
  Ad? ad;
  int? totalRaised;
  int? progress;

  AdsDetailModel({this.ad, this.totalRaised, this.progress});

  AdsDetailModel.fromJson(Map<String, dynamic> json) {
    ad = json['ad'] != null ? Ad.fromJson(json['ad']) : null;
    totalRaised = json['total_raised'] is int
        ? json['total_raised']
        : int.tryParse(json['total_raised']?.toString() ?? '');
    progress = json['progress'] is int
        ? json['progress']
        : int.tryParse(json['progress']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ad != null) {
      data['ad'] = ad!.toJson();
    }
    data['total_raised'] = totalRaised;
    data['progress'] = progress;
    return data;
  }
}

class Ad {
  int? donationId;
  int? userId;
  String? title;
  String? imageUrl;
  String? description;
  String? amount;
  int? isActive;
  String? addDate;
  String? updatedAt;

  Ad(
      {this.donationId,
      this.userId,
      this.title,
      this.imageUrl,
      this.description,
      this.amount,
      this.isActive,
      this.addDate,
      this.updatedAt});

  Ad.fromJson(Map<String, dynamic> json) {
    donationId = json['donationId'] is int
        ? json['donationId']
        : int.tryParse(json['donationId']?.toString() ?? '');
    userId = json['userId'] is int
        ? json['userId']
        : int.tryParse(json['userId']?.toString() ?? '');
    title = json['title'];
    imageUrl = json['imageUrl'];
    description = json['description'];
    amount = json['amount']?.toString();
    isActive = json['isActive'] is int
        ? json['isActive']
        : int.tryParse(json['isActive']?.toString() ?? '');
    addDate = json['addDate'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['donationId'] = donationId;
    data['userId'] = userId;
    data['title'] = title;
    data['imageUrl'] = imageUrl;
    data['description'] = description;
    data['amount'] = amount;
    data['isActive'] = isActive;
    data['addDate'] = addDate;
    data['updated_at'] = updatedAt;
    return data;
  }
}
