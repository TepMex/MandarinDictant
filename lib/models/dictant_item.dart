import 'package:json_annotation/json_annotation.dart';

part 'dictant_item.g.dart';

@JsonSerializable()
class DictantItem {
  final int id;

  @JsonKey(name: 'file_path')
  final String filePath;

  @JsonKey(name: 'syllable_count')
  final int syllableCount;

  @JsonKey(name: 'tones')
  final List<int> tones;

  @JsonKey(name: 'pinyin')
  final List<String> pinyinSyllables;

  @JsonKey(name: 'hanzi')
  final String hanzi;

  DictantItem(this.id, this.filePath, this.syllableCount, this.tones,
      this.pinyinSyllables, this.hanzi);

  factory DictantItem.fromJson(Map<String, dynamic> json) =>
      _$DictantItemFromJson(json);

  Map<String, dynamic> toJson() => _$DictantItemToJson(this);
}
