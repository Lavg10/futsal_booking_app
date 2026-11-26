import 'package:cloud_firestore/cloud_firestore.dart';

enum SurchargeType { fixed, percent }

extension SurchargeTypeX on SurchargeType {
  String get value => name;

  static SurchargeType fromValue(String? value) {
    if (value == 'percent') return SurchargeType.percent;
    return SurchargeType.fixed;
  }
}

class SurchargeRule {
  const SurchargeRule({
    required this.enabled,
    required this.start,
    required this.end,
    required this.type,
    required this.amount,
  });

  final bool enabled;
  final String start;
  final String end;
  final SurchargeType type;
  final double amount;

  static const empty = SurchargeRule(
    enabled: false,
    start: '06:00',
    end: '12:00',
    type: SurchargeType.percent,
    amount: 0,
  );

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'start': start,
        'end': end,
        'type': type.value,
        'amount': amount,
      };

  factory SurchargeRule.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;
    return SurchargeRule(
      enabled: map['enabled'] as bool? ?? false,
      start: map['start'] as String? ?? '06:00',
      end: map['end'] as String? ?? '12:00',
      type: SurchargeTypeX.fromValue(map['type'] as String?),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PricingRules {
  const PricingRules({
    required this.morning,
    required this.night,
    required this.saturday,
  });

  final SurchargeRule morning;
  final SurchargeRule night;
  final SurchargeRule saturday;

  static const defaults = PricingRules(
    morning: SurchargeRule(
      enabled: false,
      start: '06:00',
      end: '12:00',
      type: SurchargeType.percent,
      amount: 10,
    ),
    night: SurchargeRule(
      enabled: false,
      start: '18:00',
      end: '23:59',
      type: SurchargeType.percent,
      amount: 15,
    ),
    saturday: SurchargeRule(
      enabled: false,
      start: '00:00',
      end: '23:59',
      type: SurchargeType.percent,
      amount: 20,
    ),
  );

  Map<String, dynamic> toMap() => {
        'morning': morning.toMap(),
        'night': night.toMap(),
        'saturday': saturday.toMap(),
      };

  factory PricingRules.fromMap(Map<String, dynamic>? map) {
    if (map == null) return defaults;
    return PricingRules(
      morning: SurchargeRule.fromMap(map['morning'] as Map<String, dynamic>?),
      night: SurchargeRule.fromMap(map['night'] as Map<String, dynamic>?),
      saturday: SurchargeRule.fromMap(map['saturday'] as Map<String, dynamic>?),
    );
  }
}

class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.start,
    required this.end,
  });

  final String id;
  final String start;
  final String end;

  Map<String, dynamic> toMap() => {'id': id, 'start': start, 'end': end};

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] as String? ?? '',
      start: map['start'] as String? ?? '',
      end: map['end'] as String? ?? '',
    );
  }
}

class Ground {
  const Ground({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.description,
    required this.amenities,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.basePrice,
    required this.pricingRules,
    required this.slots,
    required this.imageUrls,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String description;
  final List<String> amenities;
  final double latitude;
  final double longitude;
  final String geohash;
  final double basePrice;
  final PricingRules pricingRules;
  final List<TimeSlot> slots;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ground copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    String? description,
    List<String>? amenities,
    double? latitude,
    double? longitude,
    String? geohash,
    double? basePrice,
    PricingRules? pricingRules,
    List<TimeSlot>? slots,
    List<String>? imageUrls,
    bool? isActive,
  }) {
    return Ground(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      basePrice: basePrice ?? this.basePrice,
      pricingRules: pricingRules ?? this.pricingRules,
      slots: slots ?? this.slots,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Ground.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Ground(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      description: data['description'] as String? ?? '',
      amenities: List<String>.from(data['amenities'] as List<dynamic>? ?? []),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      geohash: data['geohash'] as String? ?? '',
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0,
      pricingRules: PricingRules.fromMap(data['pricingRules'] as Map<String, dynamic>?),
      slots: (data['slots'] as List<dynamic>? ?? [])
          .map((item) => TimeSlot.fromMap(item as Map<String, dynamic>))
          .toList(),
      imageUrls: List<String>.from(data['imageUrls'] as List<dynamic>? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'name': name,
        'address': address,
        'description': description,
        'amenities': amenities,
        'latitude': latitude,
        'longitude': longitude,
        'geohash': geohash,
        'basePrice': basePrice,
        'pricingRules': pricingRules.toMap(),
        'slots': slots.map((slot) => slot.toMap()).toList(),
        'imageUrls': imageUrls,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
