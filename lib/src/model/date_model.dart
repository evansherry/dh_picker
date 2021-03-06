import 'dart:core';

import '../../src/date_util.dart';
import '../date_format.dart';
import '../date_util.dart';

abstract class BaseDateTimeModel {
  /// 第一列数据源
  List<String> firstList;

  /// 第二列数据源
  List<String> secondList;

  /// 第三列数据源
  List<String> thirdList;

  /// 第一列索引
  int firstIndex;

  /// 第二列索引
  int secondIndex;

  /// 第三列索引
  int thirdIndex;

  /// 当前选中时间
  DateTime currentTime;

  /// 最终时间
  DateTime finalTime() => currentTime;

  /// 第一列选中字符串
  String firstStringAtIndex(int index);

  /// 第二列选中字符串
  String secondStringAtIndex(int index);

  /// 第三列选中字符串
  String thirdStringAtIndex(int index);

  /// 更新第一列索引
  void updateFirstIndex(int index) => firstIndex = index;

  /// 更新第二列索引
  void updateSecondIndex(int index) => secondIndex = index;

  /// 更新第三列索引
  void updateThirdIndex(int index) => thirdIndex = index;

  List<String> _dividers;

  List<int> _weights;

  /// 分割线
  List<String> get dividers => _dividers;

  /// 布局权重
  List<int> get weights => _weights;

  /// 年月日标签
  List<bool> _labels;

  List<String> _formats;
}

/// 日期(年月日)选择器
class DatePickerModel extends BaseDateTimeModel {
  DateTime maxTime;
  DateTime minTime;

  DatePickerModel({
    DateTime currentTime,
    DateTime maxTime,
    DateTime minTime,
    List<String> formats,
    List<bool> labels,
    List<int> weights,
    List<String> dividers,
  })  : assert(weights == null || weights.length == 3),
        assert(dividers == null || dividers.length == 2),
        assert(formats == null || formats.length == 3),
        assert(labels == null || labels.length == 3) {
    _weights = weights ?? [1, 1, 1];
    _dividers = dividers ?? ['', ''];
    _labels = labels ?? [true, true, true];
    _formats = formats ?? [yyyy, mm, dd];

    this.maxTime = maxTime ?? DateTime(2049, 12, 31);
    this.minTime = minTime ?? DateTime(1970, 1, 1);

    currentTime = currentTime ?? DateTime.now();
    if (currentTime.compareTo(this.maxTime) > 0) {
      currentTime = this.maxTime;
    } else if (currentTime.compareTo(this.minTime) < 0) {
      currentTime = this.minTime;
    }
    this.currentTime = currentTime;

    _fillYearList();
    _fillMonthList();
    _fillDayList();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();

    firstIndex = this.currentTime.year - this.minTime.year;
    secondIndex = this.currentTime.month - minMonth;
    thirdIndex = this.currentTime.day - minDay;
  }

  /// 填充年数据
  void _fillYearList() {
    String labelYear = _labels[0] ? localeYear() : '';
    List<String> formats = [_formats[0], labelYear];
    firstList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      return '${formatDate(formats, year: minTime.year + index)}';
    });
  }

  /// 填充月数据
  void _fillMonthList() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();
    String labelMonth =
        _labels[1] && _formats[1].startsWith('m') ? localeMonth() : '';
    List<String> formats = [_formats[1], labelMonth];
    secondList = List.generate(maxMonth - minMonth + 1,
        (int index) => '${formatDate(formats, month: minMonth + index)}');
  }

  /// 填充日数据
  void _fillDayList() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    String labelDay = _labels[2] ? localeDay() : '';
    List<String> formats = [_formats[2], labelDay];
    thirdList = List.generate(maxDay - minDay + 1, (int index) {
      return '${formatDate(formats, day: minDay + index)}';
    });
  }

  /// 更新第一列index
  @override
  void updateFirstIndex(int index) {
    super.updateFirstIndex(index);

    int destYear = index + minTime.year;
    int minMonth = _minMonthOfCurrentYear();

    DateTime newTime;
    int newDay = currentTime.day;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newDay = calcDateCount(destYear, 2);
    }
    newTime = currentTime.isUtc
        ? DateTime.utc(
            destYear,
            currentTime.month,
            newDay,
          )
        : DateTime(
            destYear,
            currentTime.month,
            newDay,
          );

    //min/max check
    _checkTime(newTime);

    _fillMonthList();
    _fillDayList();
    minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    secondIndex = currentTime.month - minMonth;
    thirdIndex = currentTime.day - minDay;
  }

  /// 更新第二列index
  @override
  void updateSecondIndex(int index) {
    super.updateSecondIndex(index);

    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          );
    //min/max check
    _checkTime(newTime);

    _fillDayList();
    int minDay = _minDayOfCurrentMonth();
    thirdIndex = currentTime.day - minDay;
  }

  /// 更新第三列index
  @override
  void updateThirdIndex(int index) {
    super.updateThirdIndex(index);

    int minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            minDay + index,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            minDay + index,
          );
  }

  @override
  String firstStringAtIndex(int index) {
    // 防止数组越界异常
    if (index >= 0 && index < firstList.length) return firstList[index];
    return null;
  }

  @override
  String secondStringAtIndex(int index) {
    if (index >= 0 && index < secondList.length) return secondList[index];
    return null;
  }

  @override
  String thirdStringAtIndex(int index) {
    if (index >= 0 && index < thirdList.length) return thirdList[index];
    return null;
  }

  /// 当前月最大天数
  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month
        ? maxTime.day
        : dayCount;
  }

  /// 当前月最小天数
  int _minDayOfCurrentMonth() =>
      currentTime.year == minTime.year && currentTime.month == minTime.month
          ? minTime.day
          : 1;

  /// 当前年最大月
  int _maxMonthOfCurrentYear() =>
      currentTime.year == maxTime.year ? maxTime.month : 12;

  /// 当前年最小月
  int _minMonthOfCurrentYear() =>
      currentTime.year == minTime.year ? minTime.month : 1;

  void _checkTime(DateTime newTime) {
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }
  }
}

/// 时间(小时分钟秒)选择器模型
class TimePickerModel extends BaseDateTimeModel {
  /// 是否显示秒
  bool showSeconds;

  TimePickerModel({
    DateTime currentTime,
    this.showSeconds: false,
    List<int> weights,
    List<String> dividers,
  })  : assert(weights == null || weights.length == 3),
        assert(dividers == null || dividers.length == 2),
        assert(showSeconds != null) {
    _weights = weights ?? [1, 1, showSeconds ? 1 : 0];
    _dividers = dividers ?? [':', showSeconds ? ':' : ''];

    this.currentTime = currentTime ?? DateTime.now();

    firstIndex = this.currentTime.hour;
    secondIndex = this.currentTime.minute;
    thirdIndex = this.currentTime.second;
  }

  @override
  String firstStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return padZero(index);
    } else {
      return null;
    }
  }

  @override
  String secondStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return padZero(index);
    } else {
      return null;
    }
  }

  @override
  String thirdStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return padZero(index);
    } else {
      return null;
    }
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
            firstIndex, secondIndex, thirdIndex)
        : DateTime(currentTime.year, currentTime.month, currentTime.day,
            firstIndex, secondIndex, thirdIndex);
  }
}

/// 日期时间选择器模型
/// [年月日 时:分]
class DateTimePickerModel extends DatePickerModel {
  final bool showYears;
  DateTime maxTime;
  DateTime minTime;
  int fourthIndex;
  int fifthIndex;

  DateTimePickerModel({
    DateTime currentTime,
    DateTime maxTime,
    DateTime minTime,
    this.showYears = true,
    List<String> formats,
    List<bool> labels,
    List<int> weights,
    List<String> dividers,
  })  : assert(weights == null || weights.length == 5),
        assert(dividers == null || dividers.length == 4),
        super(
          currentTime: currentTime,
          maxTime: maxTime,
          minTime: minTime,
          labels: labels,
          formats: formats,
        ) {
    _weights = weights ?? [showYears ? 2 : 0, 1, 1, 1, 1];
    _dividers = dividers ?? ['', '', '', ':'];

    int minHour = _minHourOfCurrentDay();
    int minMinute = _minMinuteOfCurrentHour();

    fourthIndex = this.currentTime.hour - minHour;
    fifthIndex = this.currentTime.minute - minMinute;
  }

  String fourthStringAtIndex(int index) {
    int max = _maxHourOfCurrentDay();
    int min = _minHourOfCurrentDay();

    if (index >= 0 && index < max - min + 1) {
      return padZero(min + index);
    }
    return null;
  }

  String fifthStringAtIndex(int index) {
    int max = _maxMinuteOfCurrentHour();
    int min = _minMinuteOfCurrentHour();

    if (index >= 0 && index < max - min + 1) {
      return padZero(min + index);
    }
    return null;
  }

  /// 更新第一列index
  @override
  void updateFirstIndex(int index) {
    firstIndex = index;

    int destYear = index + minTime.year;
    DateTime newTime;
    int newDay = currentTime.day;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newDay = calcDateCount(destYear, 2);
    }
    newTime = currentTime.isUtc
        ? DateTime.utc(
            destYear,
            currentTime.month,
            newDay,
            currentTime.hour,
            currentTime.minute,
          )
        : DateTime(
            destYear,
            currentTime.month,
            newDay,
            currentTime.hour,
            currentTime.minute,
          );
    //min/max check
    _checkTime(newTime);

    _fillMonthList();
    _fillDayList();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    int minHour = _minHourOfCurrentDay();
    int minMinute = _minMinuteOfCurrentHour();

    secondIndex = currentTime.month - minMonth;
    thirdIndex = currentTime.day - minDay;
    fourthIndex = currentTime.hour - minHour;
    fifthIndex = currentTime.minute - minMinute;
  }

  @override
  void updateSecondIndex(int index) {
    this.secondIndex = index;

    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
            currentTime.hour,
            currentTime.minute,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
            currentTime.hour,
            currentTime.minute,
          );
    //min/max check
    _checkTime(newTime);

    _fillDayList();
    int minDay = _minDayOfCurrentMonth();
    int minHour = _minHourOfCurrentDay();
    int minMinute = _minMinuteOfCurrentHour();

    thirdIndex = currentTime.day - minDay;
    fourthIndex = currentTime.hour - minHour;
    fifthIndex = currentTime.minute - minMinute;
  }

  @override
  void updateThirdIndex(int index) {
    this.thirdIndex = index;

    int minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            minDay + index,
            currentTime.hour,
            currentTime.minute,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            minDay + index,
            currentTime.hour,
            currentTime.minute,
          );

    int minHour = _minHourOfCurrentDay();
    int minMinute = _minMinuteOfCurrentHour();

    fourthIndex = currentTime.hour - minHour;
    fifthIndex = currentTime.minute - minMinute;
  }

  void updateFourthIndex(int index) {
    this.fourthIndex = index;

    int minHour = _minHourOfCurrentDay();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            minHour + index,
            currentTime.minute,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            minHour + index,
            currentTime.minute,
          );

    int minMinute = _minMinuteOfCurrentHour();
    fifthIndex = currentTime.minute - minMinute;
  }

  void updateFifthIndex(int index) {
    this.fifthIndex = index;

    int minMinute = _minMinuteOfCurrentHour();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            currentTime.hour,
            minMinute + index,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            currentTime.hour,
            minMinute + index,
          );
  }

  bool isAtSameDay(DateTime day1, DateTime day2) {
    return day1 != null &&
        day2 != null &&
        day1.difference(day2).inDays == 0 &&
        day1.day == day2.day;
  }

  int _maxHourOfCurrentDay() {
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month &&
            currentTime.day == maxTime.day
        ? maxTime.hour
        : 23;
  }

  int _minHourOfCurrentDay() {
    return currentTime.year == minTime.year &&
            currentTime.month == minTime.month &&
            currentTime.day == minTime.day
        ? minTime.hour
        : 0;
  }

  int _maxMinuteOfCurrentHour() {
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month &&
            currentTime.day == maxTime.day &&
            currentTime.hour == maxTime.hour
        ? maxTime.minute
        : 59;
  }

  int _minMinuteOfCurrentHour() {
    return currentTime.year == minTime.year &&
            currentTime.month == minTime.month &&
            currentTime.day == minTime.day &&
            currentTime.hour == minTime.hour
        ? minTime.minute
        : 0;
  }
}
