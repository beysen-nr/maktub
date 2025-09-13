class HomeScreenWidgetModel {
  final int id;
  final String type; // 'banner', 'big_product', 'product_horizontal_list'
  final Map<String, dynamic> data; // JSON с параметрами
  final int position;
  final int regionId;

  HomeScreenWidgetModel({
    required this.id,
    required this.type,
    required this.data,
    required this.position,
    required this.regionId,
  });

  factory HomeScreenWidgetModel.fromJson(Map<String, dynamic> json) {
    return HomeScreenWidgetModel(
      id: json['id'],
      type: json['type'],
      data: json['data'],
      position: json['position'],
      regionId: json['region_id'],
    );
  }
}
