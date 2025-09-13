class CarouselModel {
  final String name;
  final int position;
  final String imageUrl;
  final DateTime? fromDate;
  final DateTime? tillDate;
  final CarouselAction? onTap;

  CarouselModel({
    required this.name,
    required this.position,
    required this.imageUrl,
    this.fromDate,
    this.tillDate,
    this.onTap,
  });

  factory CarouselModel.fromJson(Map<String, dynamic> json) {
    return CarouselModel(
      name: json['name'],
      position: json['position'],
      imageUrl: json['image_link'],
      fromDate: json['from_date'] != null ? DateTime.tryParse(json['from_date']) : null,
      tillDate: json['till_date'] != null ? DateTime.tryParse(json['till_date']) : null,
      onTap: json['ontap'] != null ? CarouselAction.fromJson(json['ontap']) : null,
    );
  }
}
class CarouselAction {
  final String type;
  final int target;
  final String? url;
  final String? title;
  final String? titleKz;
  final String? titleRu;
  final int? parentCategoryId;

  CarouselAction({
    required this.type,
    required this.target,
    this.url,
    this.title,
    this.titleKz,
    this.titleRu,
    this.parentCategoryId
  });

  factory CarouselAction.fromJson(Map<String, dynamic> json) {
    return CarouselAction(
      type: json['type'],
      target: json['target'],
      title: json['title'],
      titleKz: json['titleKz'],
      titleRu: json['titleRu'],
      url: json['url'],
      parentCategoryId: json['parentCategoryId']
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'target': target,
        'title': title,
        'titleKz': titleKz,
        'titleRu': titleRu,
      };
}


