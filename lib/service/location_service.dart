import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  DateTime? _lastSent;

  String? userId;
  String? name;
  final String apiUrl = "http://192.168.1.3:8000/api/update-location";

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString == null) {
      print("❌ User data not found in SharedPreferences");
      return;
    }

    final userData = jsonDecode(userDataString) as Map<String, dynamic>;
    userId = userData['id'].toString();
    name = userData['username'];

    if (userId == null || name == null) {
      print("❌ User ID or name is missing");
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location service not enabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("❌ Location permission not granted");
        return;
      }
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      final now = DateTime.now();
      if (_lastSent == null ||
          now.difference(_lastSent!) > Duration(seconds: 2)) {
        _sendLocation(position.latitude, position.longitude);
        _lastSent = now;
      }
    });
  }

  void _sendLocation(double lat, double lng) async {
    try {
      if (userId == null || name == null) {
        print("❌ userId or name is not initialized");
        return;
      }

      print("📡 Sending location: $lat, $lng for $name (ID: $userId)");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "latitude": lat,
          "longitude": lng,
        }),
      );

      print("📬 Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("✅ Location sent: $lat, $lng");
      } else {
        print("❌ Failed to send location: ${response.body}");
      }
    } catch (e) {
      print("💥 Error sending location: $e");
    }
  }
}
