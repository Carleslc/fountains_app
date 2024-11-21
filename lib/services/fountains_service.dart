import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../exceptions/http.dart';
import '../models/bounding_box.dart';
import '../models/data_model.dart';
import '../models/distance.dart';
import '../models/fetch_context.dart';
import '../models/fountains.dart';
import '../utils/logger.dart';

/// Service to fetch fountains data
class FountainsService {
  // Singleton service
  factory FountainsService() => _instance;
  static final _instance = FountainsService._();
  FountainsService._();

  /// Fountains API
  static final _apiUrl = Uri(
    scheme: 'https',
    host: 'api.fountains.carleslc.me',
    pathSegments: ['api'],
  );

  /// Fountains by bounding box
  static final Uri _bboxUrl = _apiUrl.replace(
    pathSegments: [
      ..._apiUrl.pathSegments,
      'fountains',
      'bbox',
    ],
  );

  /// Fetch all fountains available inside [context] bounding box area
  Future<Fountains> fountainsWithinBoundingBox({
    required final FetchContext context,
  }) async {
    final BoundingBox bbox = context.boundingBox;

    final url = _bboxUrl.replace(
      queryParameters: {
        'north_lat': bbox.northLat.toString(),
        'west_long': bbox.westLong.toString(),
        'south_lat': bbox.southLat.toString(),
        'east_long': bbox.eastLong.toString(),
      },
    );

    final Fountains? fountains = await _get(
      url,
      fromJson: (List<dynamic> json) => Fountains.fromJson(
        context,
        json.cast<Map<String, dynamic>>(),
      ),
    );

    return fountains ?? Fountains.empty(context);
  }

  /// Fountains by radius
  static final Uri _radiusUrl = _apiUrl.replace(
    pathSegments: [
      ..._apiUrl.pathSegments,
      'fountains',
      'radius',
    ],
  );

  /// Fetch all fountains available near context location within [radius] distance
  Future<Fountains> fountainsWithinRadius({
    required final FetchContext context,
    required final Distance radius,
  }) async {
    final url = _radiusUrl.replace(
      queryParameters: {
        'lat': context.location.latitude.toString(),
        'long': context.location.longitude.toString(),
        'radius': radius.meters.toString(),
      },
    );

    final Fountains? fountains = await _get(
      url,
      fromJson: (List<dynamic> json) => Fountains.fromJson(
        context,
        json.cast<Map<String, dynamic>>(),
      ),
    );

    return fountains ?? Fountains.empty(context);
  }

  /// Makes a GET request to the API `url`
  /// and converts the response using `fromJson` method.
  ///
  /// If response status is not [success] then [HttpResponseError] is thrown.
  Future<T?> _get<T extends JsonDataModel, J>(
    final Uri url, {
    required T Function(J json) fromJson,
    int success = 200, // OK
  }) async {
    debug(url.toString());

    http.Response response = await http.get(url);

    if (response.statusCode != success) {
      throw HttpResponseError(
        uri: url,
        status: response.statusCode,
        body: response.body,
      );
    }

    final String body = response.body;

    if (body.isEmpty) return null;

    // Process parsing in background
    return compute(
      (String jsonString) {
        final dynamic json = jsonDecode(jsonString);

        if (json == null) return null;

        return fromJson(json as J);
      },
      body,
    );
  }
}
