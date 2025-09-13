class Category {
  final int id;
  final String name;
  final String nameRu;
  final int? parentId;

  Category({
    required this.id,
    required this.name,
    required this.nameRu,
    this.parentId,
  });
    factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      nameRu: map['name_ru'] as String,
      parentId: map['parent_id'] as int?,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      nameRu: json['name_ru'] as String,
      parentId: json['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ru': nameRu,
      'parent_id': parentId,
    };
  }
}
