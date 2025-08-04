import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OpenRouteService {
  final Dio _dio = Dio();
  final String _apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjBhNGZiNGI0OGQ3ODQxNmU5YmU4OGYwNzE1ZGZkZTM0IiwiaCI6Im11cm11cjY0In0='; // Ganti di sini

  Future<List<LatLng>> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final url = 'https://api.openrouteservice.org/v2/directions/driving-car';

    final response = await _dio.get(
      url,
      queryParameters: {
        'api_key': _apiKey,
        'start': '${start.longitude},${start.latitude}',
        'end': '${end.longitude},${end.latitude}',
      },
    );

    final coordinates = response.data['features'][0]['geometry']['coordinates'];

    // ORS mengembalikan List<List<double>> dalam bentuk [lng, lat]
    return coordinates.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }
}
