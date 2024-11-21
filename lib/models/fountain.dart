import 'dart:convert';

import '../utils/date_format.dart';
import '../utils/location.dart';
import 'data_model.dart';
import 'fountain_enums.dart';

/// Fountain data.
///
/// Convert from JSON: `Fountain.fromJson(json)`
class Fountain extends JsonDataModel {
  final String id;
  final double latitude;
  final double longitude;
  final String? name;
  final String? description;
  final String? operator;
  final String? picture;
  final FountainType type;
  final FountainSafeWater safeWater;
  final FountainLegalWater legalWater;
  final FountainAccess access;
  final bool? operationalStatus;
  final bool? accessBottles;
  final bool? accessPets;
  final bool? accessWheelchair;
  final bool? fee;
  final String? address;
  final String? website;
  final String? providerName;
  final String? providerId;
  final DateTime? providerUpdatedAt;
  final String? providerUrl;
  final String? userId;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  Fountain({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.name,
    this.description,
    this.operator,
    this.picture,
    this.type = FountainType.unknown,
    this.safeWater = FountainSafeWater.unknown,
    this.legalWater = FountainLegalWater.unknown,
    this.access = FountainAccess.unknown,
    this.operationalStatus,
    this.accessBottles,
    this.accessPets,
    this.accessWheelchair,
    this.fee,
    this.address,
    this.website,
    this.providerName,
    this.providerId,
    this.providerUpdatedAt,
    this.providerUrl,
    this.userId,
    this.updatedAt,
    this.createdAt,
  });

  Location get location => Location(latitude, longitude);

  factory Fountain.fromJson(Map<String, dynamic> json) => Fountain(
        id: json['id'],
        latitude: json['lat'],
        longitude: json['long'],
        name: json['name'],
        description: json['description'],
        operator: json['operator'],
        picture: json['picture'],
        type: FountainType.fromString(json['type']),
        safeWater: FountainSafeWater.fromString(json['safe_water']),
        legalWater: FountainLegalWater.fromString(json['legal_water']),
        access: FountainAccess.fromString(json['access']),
        operationalStatus: json['operational_status'],
        accessBottles: json['access_bottles'],
        accessPets: json['access_pets'],
        accessWheelchair: json['access_wheelchair'],
        fee: json['fee'],
        address: json['address'],
        website: json['website'],
        providerName: json['provider_name'],
        providerId: json['provider_id'],
        providerUpdatedAt:
            DateFormatter.parseOrNull(json['provider_updated_at']),
        providerUrl: json['provider_url'],
        userId: json['user_id'],
        updatedAt: DateFormatter.parseOrNull(json['updated_at']),
        createdAt: DateFormatter.parseOrNull(json['created_at']),
      );

  factory Fountain.fromJsonString(String jsonString) =>
      Fountain.fromJson(jsonDecode(jsonString));

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'lat': latitude,
        'long': longitude,
        'name': name,
        'description': description,
        'operator': operator,
        'picture': picture,
        'type': type.value,
        'safe_water': safeWater.value,
        'legal_water': legalWater.value,
        'access': access.value,
        'operational_status': operationalStatus,
        'access_bottles': accessBottles,
        'access_pets': accessPets,
        'access_wheelchair': accessWheelchair,
        'fee': fee,
        'address': address,
        'website': website,
        'provider_name': providerName,
        'provider_id': providerId,
        'provider_updated_at': providerUpdatedAt?.toIso8601String(),
        'provider_url': providerUrl,
        'user_id': userId,
        'updated_at': updatedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  bool get isPublic => switch (access) {
        FountainAccess.yes => true,
        FountainAccess.unknown => true,
        FountainAccess.permissive => true,
        FountainAccess.customers => false,
        FountainAccess.permit => false,
        FountainAccess.private => false,
        FountainAccess.no => false,
      };

  @override
  String toString() {
    String s = 'Fountain $id at ($latitude, $longitude)';

    if (name != null) {
      s += ' [$name]';
    }

    if (providerUrl != null) {
      s += '. Provider: $providerUrl';
    }

    return s;
  }

  @override
  bool operator ==(Object other) {
    return other is Fountain && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
