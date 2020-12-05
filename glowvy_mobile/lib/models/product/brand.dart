import 'package:Dimodo/models/category.dart';
import 'package:Dimodo/models/product/businessInfo.dart';
import 'package:Dimodo/models/product/tag.dart';
import 'package:json_annotation/json_annotation.dart';

import 'type.dart';

part 'brand.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Brand {
  String address1;
  String address2;
  int bookmarkCount;
  BusinessInfo businessInfo;
  String email;
  String enName;
  int id;
  String image;
  String name;
  List<Tag> tags;
  String telephone;
  String text;
  List<Category> categories;

  Type type;

  Brand({
    this.address1,
    this.address2,
    this.bookmarkCount,
    this.businessInfo,
    this.email,
    this.enName,
    this.id,
    this.image,
    this.name,
    this.tags,
    this.telephone,
    this.text,
    this.type,
  });
  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
  Map<String, dynamic> toJson() => _$BrandToJson(this);
}