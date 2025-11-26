class CategoryModel {
  final String id;
  final String name;
  final String imagePath;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imagePath: json['imagePath'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'description': description,
    };
  }
}
