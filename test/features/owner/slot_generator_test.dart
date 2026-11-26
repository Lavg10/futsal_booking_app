import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsal_app/features/owner/domain/slot_generator.dart';

void main() {
  test('generates contiguous slots', () {
    final slots = SlotGenerator.generate(
      open: const TimeOfDay(hour: 8, minute: 0),
      close: const TimeOfDay(hour: 10, minute: 0),
      durationMinutes: 60,
    );
    expect(slots.length, 2);
    expect(slots.first.start, '08:00');
    expect(slots.first.end, '09:00');
    expect(slots.last.end, '10:00');
    expect(slots.first.id, '08:00_09:00');
  });

  test('drops an incomplete trailing slot', () {
    final slots = SlotGenerator.generate(
      open: const TimeOfDay(hour: 8, minute: 0),
      close: const TimeOfDay(hour: 9, minute: 30),
      durationMinutes: 60,
    );
    expect(slots.length, 1);
  });

  test('rejects an invalid time window', () {
    expect(
      () => SlotGenerator.generate(
        open: const TimeOfDay(hour: 22, minute: 0),
        close: const TimeOfDay(hour: 8, minute: 0),
        durationMinutes: 60,
      ),
      throwsArgumentError,
    );
  });
}
