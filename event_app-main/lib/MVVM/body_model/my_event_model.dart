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
        this.editDate});

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
    return data;
  }
}
