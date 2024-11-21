import 'dart:convert';

/// Json-encodable data models base class.
///
/// Also implement these static factories to decode from json:\
/// (Replace `JsonDataModel` with the concrete instance class)
///
/// Decode data model from json map:
/// ```
/// factory JsonDataModel.fromJson(Map<String, dynamic> json); // json map
/// factory JsonDataModel.fromJson(List<Map<String, dynamic>> json); // json list
/// factory JsonDataModel.fromJson(dynamic json); // any json
/// ```
///
/// Decode data model from json string:
/// ```
/// factory JsonDataModel.fromJsonString(String jsonString) => JsonDataModel.fromJson(jsonDecode(jsonString));
/// ```
abstract class JsonDataModel {
  /// Encode data model to json map
  dynamic toJson();

  /// Encode data model to json string
  String toJsonString() => jsonEncode(toJson());
}
