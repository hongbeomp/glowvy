// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'second_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecondCategory _$SecondCategoryFromJson(Map<String, dynamic> json) {
  return SecondCategory(
    showMergedChildren: json['show_merged_children'] as bool,
    secondCategoryKoName: json['second_category_ko_name'] as String,
    secondCategoryEnName: json['second_category_en_name'] as String,
    secondCategoryName: json['second_category_name'] as String,
    secondIsNew: json['second_is_new'] as bool,
    secondCategoryId: json['second_category_id'] as int,
    thirdCategories: (json['third_categories'] as List)
        ?.map((e) => e == null
            ? null
            : ThirdCategory.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    thirdCategoryEnName: json['third_category_en_name'] as String,
    thirdCategoryName: json['third_category_name'] as String,
  );
}

Map<String, dynamic> _$SecondCategoryToJson(SecondCategory instance) =>
    <String, dynamic>{
      'show_merged_children': instance.showMergedChildren,
      'second_category_ko_name': instance.secondCategoryKoName,
      'second_category_en_name': instance.secondCategoryEnName,
      'second_category_name': instance.secondCategoryName,
      'second_is_new': instance.secondIsNew,
      'second_category_id': instance.secondCategoryId,
      'third_categories': instance.thirdCategories,
      'third_category_en_name': instance.thirdCategoryEnName,
      'third_category_name': instance.thirdCategoryName,
    };