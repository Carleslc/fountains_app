import 'dart:collection';
import 'dart:convert';

import 'data_model.dart';
import 'fetch_context.dart';
import 'fountain.dart';

/// Fountains list.
///
/// Convert from JSON: `Fountains.fromJson(fetchLocation, json)`
class Fountains extends JsonDataModel with Iterable<Fountain> {
  /// Set of fetched fountains
  final Set<Fountain> fountains;

  /// Fetch context at the moment of the request
  final FetchContext fetchContext;

  /// Timestamp of the response
  final DateTime fetchTimestamp;

  Fountains(this.fetchContext, final Iterable<Fountain> fountains)
      : fetchTimestamp = DateTime.now(),
        fountains = UnmodifiableSetView(fountains.toSet());

  Fountains.empty(FetchContext context) : this(context, []);

  factory Fountains.fromJson(
    FetchContext context,
    List<Map<String, dynamic>> json,
  ) {
    return Fountains(
      context,
      List<Fountain>.from(
        json.map(
          (Map<String, dynamic> fountainJson) =>
              Fountain.fromJson(fountainJson),
        ),
      ),
    );
  }

  factory Fountains.fromJsonString(FetchContext context, String jsonString) =>
      Fountains.fromJson(context, jsonDecode(jsonString));

  @override
  List<Map<String, dynamic>> toJson() =>
      fountains.map((Fountain fountain) => fountain.toJson()).toList();

  @override
  Iterator<Fountain> get iterator => fountains.iterator;

  @override
  String toString() => 'Fountains (${fountains.length}) fetched at '
      '(${fetchContext.location.latitude}, ${fetchContext.location.longitude}) ($fetchTimestamp)';

  @override
  bool operator ==(Object other) {
    return other is Fountains &&
        other.fetchTimestamp == fetchTimestamp &&
        other.fetchContext == fetchContext;
  }

  @override
  int get hashCode => fetchTimestamp.hashCode ^ fetchContext.hashCode;
}
