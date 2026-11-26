import 'ground.dart';

class PriceBreakdown {
  const PriceBreakdown({
    required this.base,
    required this.morning,
    required this.night,
    required this.saturday,
    required this.total,
  });

  final double base;
  final double morning;
  final double night;
  final double saturday;
  final double total;
}

abstract final class PricingCalculator {
  static PriceBreakdown calculate({
    required double basePrice,
    required PricingRules rules,
    required DateTime start,
  }) {
    final minutes = start.hour * 60 + start.minute;

    final morning = rules.morning.enabled && _inWindow(minutes, rules.morning)
        ? _amountFor(basePrice, rules.morning)
        : 0.0;
    final night = rules.night.enabled && _inWindow(minutes, rules.night)
        ? _amountFor(basePrice, rules.night)
        : 0.0;
    final saturday = rules.saturday.enabled && start.weekday == DateTime.saturday
        ? _amountFor(basePrice, rules.saturday)
        : 0.0;

    return PriceBreakdown(
      base: basePrice,
      morning: morning,
      night: night,
      saturday: saturday,
      total: basePrice + morning + night + saturday,
    );
  }

  static String formatPrice(double amount) {
    return amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
  }

  static bool _inWindow(int minutes, SurchargeRule rule) {
    final start = _minutesFromTime(rule.start);
    final end = _minutesFromTime(rule.end);
    if (end > start) return minutes >= start && minutes < end;
    return minutes >= start || minutes < end;
  }

  static double _amountFor(double basePrice, SurchargeRule rule) {
    if (rule.type == SurchargeType.percent) {
      return basePrice * rule.amount / 100;
    }
    return rule.amount;
  }

  static int _minutesFromTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }
}
