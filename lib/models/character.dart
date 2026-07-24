class Character {
  final int id;
  final String nameEn;
  final String nameJp;
  final String? thumbImg;
  final String? colorMain;
  final String? colorSub;
  final String? categoryLabelEn;

  Character({
    required this.id,
    required this.nameEn,
    required this.nameJp,
    this.thumbImg,
    this.colorMain,
    this.colorSub,
    this.categoryLabelEn,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      nameEn: json['name_en'] ?? '',
      nameJp: json['name_jp'] ?? '',
      thumbImg: json['thumb_img'],
      colorMain: json['color_main'],
      colorSub: json['color_sub'],
      categoryLabelEn: json['category_label_en'],
    );
  }
}