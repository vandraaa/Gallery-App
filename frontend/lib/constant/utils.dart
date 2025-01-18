import 'package:intl/intl.dart';

String formatDate(String createdAt) {
  DateTime dateTime = DateTime.parse(createdAt);
  DateTime now = DateTime.now();

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return 'Today';
  } else if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day - 1) {
    return 'Yesterday';
  } else if (dateTime.isAfter(now.subtract(const Duration(days: 7)))) {
    return 'Last 7 days';
  } else {
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }
}

String formatDate2(String createdAt) {
  DateTime parsedDate = DateTime.parse(createdAt);
  return DateFormat('EEEE, dd MMMM yyyy').format(parsedDate);
}

String formatTime(String createdAt) {
  DateTime parsedDate = DateTime.parse(createdAt);
  return DateFormat('HH:mm').format(parsedDate);
}
