import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingResult {
  final double lat;
  final double lng;
  final String displayName;
  const GeocodingResult({
    required this.lat,
    required this.lng,
    required this.displayName,
  });
}

class GeocodingService {
  static const _timeout = Duration(seconds: 10);

  /// 주소 문자열 → 좌표 (Nominatim OpenStreetMap)
  /// 실패 시 null 반환
  Future<GeocodingResult?> search(String address) async {
    if (address.trim().isEmpty) return null;

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q':               '${address.trim()} 대한민국',
        'countrycodes':    'kr',
        'format':          'json',
        'limit':           '1',
        'accept-language': 'ko',
      },
    );

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'mylibrary-app/1.0',
      }).timeout(_timeout);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isEmpty) return null;

      final first = data.first as Map<String, dynamic>;
      return GeocodingResult(
        lat:         double.parse(first['lat'] as String),
        lng:         double.parse(first['lon'] as String),
        displayName: first['display_name'] as String? ?? address,
      );
    } catch (_) {
      return null;
    }
  }
}
