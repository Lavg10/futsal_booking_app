import 'package:flutter/material.dart';

import 'ground.dart';

abstract final class SlotGenerator {
  static List<TimeSlot> generate({
    required TimeOfDay open,
    required TimeOfDay close,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError.value(durationMinutes, 'durationMinutes', 'must be positive');
    }

    final startMinutes = open.hour * 60 + open.minute;
    final endMinutes = close.hour * 60 + close.minute;
    if (endMinutes <= startMinutes) {
      throw ArgumentError('Closing time must be after opening time');
    }

    final slots = <TimeSlot>[];
    for (var minute = startMinutes;
        minute + durationMinutes <= endMinutes;
        minute += durationMinutes) {
      final slotStart = _format(minute);
      final slotEnd = _format(minute + durationMinutes);
      slots.add(
        TimeSlot(id: '${slotStart}_$slotEnd', start: slotStart, end: slotEnd),
      );
    }
    return slots;
  }

  static String _format(int minutesSinceMidnight) {
    final hour = minutesSinceMidnight ~/ 60;
    final minute = minutesSinceMidnight % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
