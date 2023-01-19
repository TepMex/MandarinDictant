// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictant_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictantItem _$DictantItemFromJson(Map<String, dynamic> json) => DictantItem(
      json['id'] as int,
      json['file_path'] as String,
      json['syllable_count'] as int,
      (json['tones'] as List<dynamic>).map((e) => e as int).toList(),
      (json['pinyin'] as List<dynamic>).map((e) => e as String).toList(),
      json['hanzi'] as String,
    );

Map<String, dynamic> _$DictantItemToJson(DictantItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file_path': instance.filePath,
      'syllable_count': instance.syllableCount,
      'tones': instance.tones,
      'pinyin': instance.pinyinSyllables,
      'hanzi': instance.hanzi,
    };
