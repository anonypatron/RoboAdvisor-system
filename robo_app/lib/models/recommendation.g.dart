// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    _Recommendation(
      ticker: json['ticker'] as String,
      date: json['date'] as String,
      close: (json['close'] as num).toDouble(),
      signalType: json['signal_type'] as String,
    );

Map<String, dynamic> _$RecommendationToJson(_Recommendation instance) =>
    <String, dynamic>{
      'ticker': instance.ticker,
      'date': instance.date,
      'close': instance.close,
      'signal_type': instance.signalType,
    };
