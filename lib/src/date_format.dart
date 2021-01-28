import 'package:intl/intl.dart';
import 'res/strings.dart';

String padZero(int value, [int length = 2]) {
  return '$value'.padLeft(length, "0");
}

int dayInYear(DateTime date) =>
    date.difference(new DateTime(date.year, 1, 1)).inDays;

/// 本地化国家码
String get country => Intl.getCurrentLocale().split('_')[1];

/// 获取本地化语言
String get language => Intl.getCurrentLocale().split('_')[0];

String localeYear() {
  String lang = language;
  if (lang == 'zh' || lang == 'ja') {
    return '年';
  } else if (lang == 'ko') {
    return '년';
  } else {
    return '';
  }
}

String localeMonth(int month) {
  String lang = language;
  if (lang == 'zh' || lang == 'ja') {
    return '$month月';
  } else if (lang == 'ko') {
    return '$month월';
  } else {
    Map model = i18nModel[lang] ?? i18nModel['en'];
    List monthStrings = model['monthLong'];
    return monthStrings[month - 1];
  }
}

String localeDay() {
  String lang = language;
  if (lang == 'zh' || lang == 'ja') {
    return '日';
  } else if (lang == 'ko') {
    return '일';
  } else {
    return '';
  }
}