class CharacterDetail {
  final int id;
  final String nameEn;
  final String nameJp;
  final int birthDay;
  final int birthMonth;
  final String colorMain;
  final String colorSub;
  final String categoryLabelEn;
  final String? profile;
  final String? slogan;
  final String? strengths;
  final String? weaknesses;
  final String? height;
  final String? weight;
  final String? detailImgPc;
  final String? thumbImg;
  final String? voiceUrl;

  CharacterDetail({
    required this.id,
    required this.nameEn,
    required this.nameJp,
    required this.birthDay,
    required this.birthMonth,
    required this.colorMain,
    required this.colorSub,
    required this.categoryLabelEn,
    this.profile,
    this.slogan,
    this.strengths,
    this.weaknesses,
    this.height,
    this.weight,
    this.detailImgPc,
    this.thumbImg,
    this.voiceUrl,
  });

  CharacterDetail copyWithTranslations({
    String? profile,
    String? slogan,
    String? strengths,
    String? weaknesses,
  }) {
    return CharacterDetail(
      id: id,
      nameEn: nameEn,
      nameJp: nameJp,
      birthDay: birthDay,
      birthMonth: birthMonth,
      colorMain: colorMain,
      colorSub: colorSub,
      categoryLabelEn: categoryLabelEn,
      profile: profile ?? this.profile,
      slogan: slogan ?? this.slogan,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      height: height,
      weight: weight,
      detailImgPc: detailImgPc,
      thumbImg: thumbImg,
      voiceUrl: voiceUrl,
    );
  }

  factory CharacterDetail.fromJson(Map<String, dynamic> json) {
    return CharacterDetail(
      id: json['game_id'] ?? json['id'],
      nameEn: json['name_en'] ?? '',
      nameJp: json['name_jp'] ?? '',
      birthDay: json['birth_day'] ?? 0,
      birthMonth: json['birth_month'] ?? 0,
      colorMain: json['color_main'] ?? '#2F6B4A',
      colorSub: json['color_sub'] ?? '#A8C98C',
      categoryLabelEn: json['category_label_en'] ?? '',
      profile: json['profile'],
      slogan: json['slogan'],
      strengths: json['strengths'],
      weaknesses: json['weaknesses'],
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      detailImgPc: json['detail_img_pc'],
      thumbImg: json['thumb_img'],
      voiceUrl: json['voice'],
    );
  }

  static const List<String> _monthNames = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  String get birthdayFormatted {
    if (birthMonth < 1 || birthMonth > 12) return '';
    return '$birthDay de ${_monthNames[birthMonth]}';
  }
}