String formatEthiopianTime(String timeStr) {
  if (timeStr.isEmpty) return '';

  try {
    // Expected format: HH:mm:ss or HH:mm
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    int etHours = hours - 6;
    if (etHours <= 0) etHours += 12;
    if (etHours > 12) etHours -= 12;

    final period = (hours >= 6 && hours < 18) ? 'Day' : 'Night';

    return '$etHours:${minutes.toString().padLeft(2, '0')} $period';
  } catch (e) {
    return timeStr;
  }
}

String formatEthiopianTimeFromDateTime(DateTime dateTime) {
  final hours = dateTime.hour;
  final minutes = dateTime.minute;

  int etHours = hours - 6;
  if (etHours <= 0) etHours += 12;
  if (etHours > 12) etHours -= 12;

  final period = (hours >= 6 && hours < 18) ? 'Day' : 'Night';

  return '$etHours:${minutes.toString().padLeft(2, '0')} $period';
}
