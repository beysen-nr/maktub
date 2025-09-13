class Banner {
  final String imageUrl;
  final OnTapAction? onTap;
  
  Banner({required this.imageUrl, this.onTap});

  factory Banner.fromJson(Map<String, dynamic> json) {
    
    return Banner(
      imageUrl: json['imageUrl'] as String,
      onTap: json['onTap'] != null
          ? OnTapAction.fromJson(json['onTap'] as Map<String, dynamic>)
          : null,
    );
  }
}


class OnTapAction {
  final String target;
  final Map<String, dynamic>? params;

  OnTapAction({required this.target, this.params});

  factory OnTapAction.fromJson(Map<String, dynamic> json) {
    return OnTapAction(
      target: json['target'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}






class HorizontalList {
  final String title;
  final String filterType;
  final int targetId;
  final int? parentCategoryId;
  
  HorizontalList({required this.title, required this.filterType, required this.targetId, this.parentCategoryId});

  factory HorizontalList.fromJson(Map<String, dynamic> json) {
    
    return HorizontalList(
      title: json['title'] as String,
      filterType: json['filterType'] as String,
      targetId: json['targetId'] as int,
      parentCategoryId: json['parentCategory']
    );
  }
}

