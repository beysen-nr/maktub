class Region {
  final int id;
  final String name;
  final List<double> center;
  final List<List<List<double>>> border;
  final String regionLogo;

  Region({
    required this.id,
    required this.name,
    required this.center,
    required this.border,
    required this.regionLogo
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      center: List<double>.from(json['center']['coordinates']),
      regionLogo: json['region_logo'],
      border: (json['border']['coordinates'] as List)
          .map((polygon) => (polygon as List)
              .map((point) => List<double>.from(point))
              .toList())
          .toList(),
    );
  }
}


