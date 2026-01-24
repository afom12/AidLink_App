import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat dateTime = DateFormat('MMM d, HH:mm');
  static final DateFormat dateOnly = DateFormat('MMM d');

  static String formatDateTime(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return dateTime.format(value);
  }

  static String formatCountdown(Duration? duration) {
    if (duration == null) {
      return '--:--';
    }
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }
}




