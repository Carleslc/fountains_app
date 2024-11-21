enum FountainType {
  natural('natural'),
  tapWater('tap_water'),
  waterPoint('water_point'),
  wateringPlace('watering_place'),
  unknown('unknown');

  final String value;

  const FountainType(this.value);

  static FountainType fromString(String? type) => switch (type) {
        'natural' => FountainType.natural,
        'tap_water' => FountainType.tapWater,
        'water_point' => FountainType.waterPoint,
        'watering_place' => FountainType.wateringPlace,
        _ => FountainType.unknown
      };
}

enum FountainSafeWater {
  yes('yes'),
  probably('probably'),
  no('no'),
  unknown('unknown');

  final String value;

  const FountainSafeWater(this.value);

  static FountainSafeWater fromString(String? safeWater) => switch (safeWater) {
        'yes' => FountainSafeWater.yes,
        'probably' => FountainSafeWater.probably,
        'no' => FountainSafeWater.no,
        _ => FountainSafeWater.unknown
      };
}

enum FountainLegalWater {
  treated('treated'),
  untreated('untreated'),
  unknown('unknown');

  final String value;

  const FountainLegalWater(this.value);

  static FountainLegalWater fromString(String? legalWater) =>
      switch (legalWater) {
        'treated' => FountainLegalWater.treated,
        'untreated' => FountainLegalWater.untreated,
        _ => FountainLegalWater.unknown
      };
}

enum FountainAccess {
  yes('yes'),
  permissive('permissive'),
  customers('customers'),
  permit('permit'),
  private('private'),
  no('no'),
  unknown('unknown');

  final String value;

  const FountainAccess(this.value);

  static FountainAccess fromString(String? access) => switch (access) {
        'yes' => FountainAccess.yes,
        'permissive' => FountainAccess.permissive,
        'customers' => FountainAccess.customers,
        'permit' => FountainAccess.permit,
        'private' => FountainAccess.private,
        'no' => FountainAccess.no,
        _ => FountainAccess.unknown
      };
}
