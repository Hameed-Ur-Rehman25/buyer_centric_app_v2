import 'package:intl/intl.dart';

String formatChatTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    // Today, use time format
    return DateFormat('h:mm a').format(dateTime);
  } else if (messageDate == yesterday) {
    // Yesterday
    return 'Yesterday';
  } else if (now.difference(dateTime).inDays < 7) {
    // Within the last week, use day name
    return DateFormat('EEEE').format(dateTime); // e.g., "Monday"
  } else {
    // Older, use date format
    return DateFormat('MM/dd/yy').format(dateTime);
  }
}

String formatMessageTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
} 