import 'package:flutter_test/flutter_test.dart';
import 'package:futsal_app/features/owner/domain/ground.dart';
import 'package:futsal_app/features/owner/domain/pricing_calculator.dart';

void main() {
  const baseRules = PricingRules(
    morning: SurchargeRule(
      enabled: true,
      start: '06:00',
      end: '12:00',
      type: SurchargeType.percent,
      amount: 10,
    ),
    night: SurchargeRule(
      enabled: true,
      start: '18:00',
      end: '23:59',
      type: SurchargeType.fixed,
      amount: 50,
    ),
    saturday: SurchargeRule(
      enabled: true,
      start: '00:00',
      end: '23:59',
      type: SurchargeType.percent,
      amount: 20,
    ),
  );

  test('no surcharge on a weekday afternoon', () {
    final breakdown = PricingCalculator.calculate(
      basePrice: 1000,
      rules: baseRules,
      start: DateTime(2026, 11, 24, 15),
    );
    expect(breakdown.morning, 0);
    expect(breakdown.night, 0);
    expect(breakdown.saturday, 0);
    expect(breakdown.total, 1000);
  });

  test('morning adds a percentage of the base price', () {
    final breakdown = PricingCalculator.calculate(
      basePrice: 1000,
      rules: baseRules,
      start: DateTime(2026, 11, 24, 8),
    );
    expect(breakdown.morning, 100);
    expect(breakdown.total, 1100);
  });

  test('night adds a fixed amount', () {
    final breakdown = PricingCalculator.calculate(
      basePrice: 1000,
      rules: baseRules,
      start: DateTime(2026, 11, 24, 20),
    );
    expect(breakdown.night, 50);
    expect(breakdown.total, 1050);
  });

  test('Saturday surcharge stacks with the time surcharge', () {
    final breakdown = PricingCalculator.calculate(
      basePrice: 1000,
      rules: baseRules,
      start: DateTime(2026, 11, 28, 8),
    );
    expect(breakdown.morning, 100);
    expect(breakdown.saturday, 200);
    expect(breakdown.total, 1300);
  });

  test('overnight night window wraps past midnight', () {
    final rules = baseRules.copyWithNight(
      const SurchargeRule(
        enabled: true,
        start: '22:00',
        end: '06:00',
        type: SurchargeType.fixed,
        amount: 30,
      ),
    );
    final afterMidnight = PricingCalculator.calculate(
      basePrice: 1000,
      rules: rules,
      start: DateTime(2026, 11, 24, 2),
    );
    expect(afterMidnight.night, 30);
  });
}

extension on PricingRules {
  PricingRules copyWithNight(SurchargeRule night) {
    return PricingRules(morning: morning, night: night, saturday: saturday);
  }
}
