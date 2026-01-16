import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  static const TIME = 'HH:mm';
  static const SHORT_MONTH = 'MMM';
  static const FULL_MONTH = 'MMMM';
  static const SHORT_DAY_MONTH = 'd MMM';
  static const SIMPLE_DATE_AT_TIME = "d MMM yyyy 'at' HH:mm";
  static const SIMPLE_DATE_HOUR = 'yyyy-MM-dd-HH';
  static const SIMPLE_DATE = 'yyyy-MM-dd';
  static const SIMPLE_DATE_DD_MM_YYYY = 'dd/MM/yyyy';
  static const SHORT_DATE = 'd MMM yyyy';
  static const FULL_DATE = 'dd MMMM yyyy';
  static const FULL_DATE_TIME_YEAR_FIRST = 'yyyy-MM-dd HH:mm';
  static const SHORT_DAY_OF_WEEK = 'EEE';
  static const FULL_DAY_OF_WEEK = 'EEEE';

  String format(
    String format, {
    bool formatToday = false,
    bool localTime = false,
  }) {
    if (formatToday) {
      final now = DateTime.now();
      final difference = now.difference(this).inDays;
      if (difference == 0 && now.day == day) {
        return 'Today';
      }
    }
    final formatter = DateFormat(format);
    return formatter.format(localTime ? toLocal() : this);
  }
}

extension DateRangeExtensions on DateTimeRange {
  bool isDateInRange(DateTime dateTime) {
    return (dateTime.isAfter(start) && dateTime.isBefore(end)) ||
        dateTime == start ||
        dateTime == end;
  }
}
