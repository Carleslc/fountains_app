import 'dart:convert';

import 'data_model.dart';

/// Fountains data provider source, e.g. OpenStreetMap
///
/// Convert from JSON: `Provider.fromJson(json)`
class Provider extends JsonDataModel {
  final String name;
  final String? url;

  Provider({
    required this.name,
    required this.url,
  });

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
        name: json['name'],
        url: json['url'],
      );

  factory Provider.fromJsonString(String jsonString) =>
      Provider.fromJson(jsonDecode(jsonString));

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Provider && name == other.name && url == other.url);

  @override
  int get hashCode => name.hashCode ^ url.hashCode;
}
