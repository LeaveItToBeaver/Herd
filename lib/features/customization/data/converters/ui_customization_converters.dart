import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

// FontWeight Converter
class FontWeightConverter implements JsonConverter<FontWeight, String> {
  const FontWeightConverter();

  @override
  FontWeight fromJson(String json) {
    switch (json) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  @override
  String toJson(FontWeight object) {
    switch (object) {
      case FontWeight.w100:
        return 'w100';
      case FontWeight.w200:
        return 'w200';
      case FontWeight.w300:
        return 'w300';
      case FontWeight.w400:
        return 'w400';
      case FontWeight.w500:
        return 'w500';
      case FontWeight.w600:
        return 'w600';
      case FontWeight.w700:
        return 'w700';
      case FontWeight.w800:
        return 'w800';
      case FontWeight.w900:
        return 'w900';
      default:
        return 'w400';
    }
  }
}

// ThemeMode Converter
class ThemeModeConverter implements JsonConverter<ThemeMode, String> {
  const ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) {
    switch (json) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  @override
  String toJson(ThemeMode object) {
    switch (object) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

// Curves Converter
class CurvesConverter implements JsonConverter<Curve, String> {
  const CurvesConverter();

  @override
  Curve fromJson(String json) {
    switch (json) {
      case 'linear':
        return Curves.linear;
      case 'decelerate':
        return Curves.decelerate;
      case 'fastLinearToSlowEaseIn':
        return Curves.fastLinearToSlowEaseIn;
      case 'ease':
        return Curves.ease;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeInToLinear':
        return Curves.easeInToLinear;
      case 'easeInSine':
        return Curves.easeInSine;
      case 'easeInQuad':
        return Curves.easeInQuad;
      case 'easeInCubic':
        return Curves.easeInCubic;
      case 'easeInQuart':
        return Curves.easeInQuart;
      case 'easeInQuint':
        return Curves.easeInQuint;
      case 'easeInExpo':
        return Curves.easeInExpo;
      case 'easeInCirc':
        return Curves.easeInCirc;
      case 'easeInBack':
        return Curves.easeInBack;
      case 'easeOut':
        return Curves.easeOut;
      case 'linearToEaseOut':
        return Curves.linearToEaseOut;
      case 'easeOutSine':
        return Curves.easeOutSine;
      case 'easeOutQuad':
        return Curves.easeOutQuad;
      case 'easeOutCubic':
        return Curves.easeOutCubic;
      case 'easeOutQuart':
        return Curves.easeOutQuart;
      case 'easeOutQuint':
        return Curves.easeOutQuint;
      case 'easeOutExpo':
        return Curves.easeOutExpo;
      case 'easeOutCirc':
        return Curves.easeOutCirc;
      case 'easeOutBack':
        return Curves.easeOutBack;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'easeInOutSine':
        return Curves.easeInOutSine;
      case 'easeInOutQuad':
        return Curves.easeInOutQuad;
      case 'easeInOutCubic':
        return Curves.easeInOutCubic;
      case 'easeInOutQuart':
        return Curves.easeInOutQuart;
      case 'easeInOutQuint':
        return Curves.easeInOutQuint;
      case 'easeInOutExpo':
        return Curves.easeInOutExpo;
      case 'easeInOutCirc':
        return Curves.easeInOutCirc;
      case 'easeInOutBack':
        return Curves.easeInOutBack;
      case 'fastOutSlowIn':
        return Curves.fastOutSlowIn;
      case 'slowMiddle':
        return Curves.slowMiddle;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'bounceInOut':
        return Curves.bounceInOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      case 'elasticInOut':
        return Curves.elasticInOut;
      default:
        return Curves.easeInOut;
    }
  }

  @override
  String toJson(Curve object) {
    // This is a simplified version - Curves is a complex class
    // For a complete implementation, you'd need to check all curve types
    if (object == Curves.linear) return 'linear';
    if (object == Curves.decelerate) return 'decelerate';
    if (object == Curves.fastLinearToSlowEaseIn)
      return 'fastLinearToSlowEaseIn';
    if (object == Curves.ease) return 'ease';
    if (object == Curves.easeIn) return 'easeIn';
    if (object == Curves.easeInToLinear) return 'easeInToLinear';
    if (object == Curves.easeInSine) return 'easeInSine';
    if (object == Curves.easeInQuad) return 'easeInQuad';
    if (object == Curves.easeInCubic) return 'easeInCubic';
    if (object == Curves.easeInQuart) return 'easeInQuart';
    if (object == Curves.easeInQuint) return 'easeInQuint';
    if (object == Curves.easeInExpo) return 'easeInExpo';
    if (object == Curves.easeInCirc) return 'easeInCirc';
    if (object == Curves.easeInBack) return 'easeInBack';
    if (object == Curves.easeOut) return 'easeOut';
    if (object == Curves.linearToEaseOut) return 'linearToEaseOut';
    if (object == Curves.easeOutSine) return 'easeOutSine';
    if (object == Curves.easeOutQuad) return 'easeOutQuad';
    if (object == Curves.easeOutCubic) return 'easeOutCubic';
    if (object == Curves.easeOutQuart) return 'easeOutQuart';
    if (object == Curves.easeOutQuint) return 'easeOutQuint';
    if (object == Curves.easeOutExpo) return 'easeOutExpo';
    if (object == Curves.easeOutCirc) return 'easeOutCirc';
    if (object == Curves.easeOutBack) return 'easeOutBack';
    if (object == Curves.easeInOut) return 'easeInOut';
    if (object == Curves.easeInOutSine) return 'easeInOutSine';
    if (object == Curves.easeInOutQuad) return 'easeInOutQuad';
    if (object == Curves.easeInOutCubic) return 'easeInOutCubic';
    if (object == Curves.easeInOutQuart) return 'easeInOutQuart';
    if (object == Curves.easeInOutQuint) return 'easeInOutQuint';
    if (object == Curves.easeInOutExpo) return 'easeInOutExpo';
    if (object == Curves.easeInOutCirc) return 'easeInOutCirc';
    if (object == Curves.easeInOutBack) return 'easeInOutBack';
    if (object == Curves.fastOutSlowIn) return 'fastOutSlowIn';
    if (object == Curves.slowMiddle) return 'slowMiddle';
    if (object == Curves.bounceIn) return 'bounceIn';
    if (object == Curves.bounceOut) return 'bounceOut';
    if (object == Curves.bounceInOut) return 'bounceInOut';
    if (object == Curves.elasticIn) return 'elasticIn';
    if (object == Curves.elasticOut) return 'elasticOut';
    if (object == Curves.elasticInOut) return 'elasticInOut';

    return 'easeInOut'; // default
  }
}

// Alignment Converter
class AlignmentConverter
    implements JsonConverter<Alignment, Map<String, double>> {
  const AlignmentConverter();

  @override
  Alignment fromJson(Map<String, double> json) {
    return Alignment(
      json['x'] ?? 0.0,
      json['y'] ?? 0.0,
    );
  }

  @override
  Map<String, double> toJson(Alignment object) {
    return {
      'x': object.x,
      'y': object.y,
    };
  }
}

// Simple converters for enums that don't need custom handling
class EnumToStringConverter<T> implements JsonConverter<T, String> {
  const EnumToStringConverter();

  @override
  T fromJson(String json) {
    // This would need to be implemented based on the specific enum
    throw UnimplementedError();
  }

  @override
  String toJson(T object) {
    return object.toString().split('.').last;
  }
}

class TimestampOrStringDateTimeConverter
    implements JsonConverter<DateTime, Object> {
  const TimestampOrStringDateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is Timestamp) {
      return json.toDate();
    }
    // As a fallback, though ideally, the data should always be String or Timestamp.
    // I will add error handling for unexpected types.
    // This is important to ensure that the converter can handle both cases.
    // For now, let's throw an ArgumentError for unexpected types.
    throw ArgumentError.value(
        json, 'json', 'Must be a String or Timestamp to convert to DateTime');
  }

  @override
  Object toJson(DateTime date) {
    return date.toIso8601String();
  }
}
