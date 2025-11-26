class AdsModel {
  int? donationId;
  int? userId;
  String? title;
  String? imageUrl;
  String? description;
  String? amount;
  int? isActive;
  String? addDate;
  String? updatedAt;

  AdsModel(
      {this.donationId,
      this.userId,
      this.title,
      this.imageUrl,
      this.description,
      this.amount,
      this.isActive,
      this.addDate,
      this.updatedAt});

  AdsModel.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['donationId'] = this.donationId;
    data['userId'] = this.userId;
    data['title'] = this.title;
    data['imageUrl'] = this.imageUrl;
    data['description'] = this.description;
    data['amount'] = this.amount;
    data['isActive'] = this.isActive;
    data['addDate'] = this.addDate;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
