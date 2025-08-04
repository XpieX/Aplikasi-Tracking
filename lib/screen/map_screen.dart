import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_app/utils/circle_marker.dart';
import 'package:tracking_app/service/api_service.dart';
import 'package:tracking_app/service/location_service.dart';
import 'package:tracking_app/service/ors_service.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  late PusherChannelsFlutter _pusher;
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(-0.0699777, 109.3067571),
    zoom: 14.5,
  );
  LatLng? _selectedJobPosition;
  final Set<Polyline> _polylines = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    LocationService().start();
    _initializePusher();
    _loadCustomerMarkers();
    _loadInitialLocation();
  }

  Future<String?> _fetchUserFotoUrl(int userId) async {
    try {
      return await APIService().getFotoProfil(userId);
    } catch (e) {
      print("❌ Gagal ambil foto profil: $e");
      return null;
    }
  }

  Future<void> _addMyDeviceMarker(Position position) async {
    print("🟢 Menambahkan marker dengan foto user dari API...");

    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      String title = "Saya";
      String? fotoUrl;

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        title = userData['username'] ?? "Saya";

        final int userId = userData['id'];
        fotoUrl = await _fetchUserFotoUrl(userId);
      }

      final customIcon = await CircleMarkerWithPin(
        text: title,
        imageUrl: fotoUrl,
        imagePath: 'assets/images/user_image.png',
      ).toBitmapDescriptor(
        logicalSize: const Size(180, 280),
        imageSize: const Size(180, 280),
      );

      final markerId = const MarkerId("device");
      final marker = Marker(
        markerId: markerId,
        position: LatLng(position.latitude, position.longitude),
        icon: customIcon,
        infoWindow: InfoWindow(title: title),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId == markerId);
        _markers.add(marker);
        print("✅ Marker dengan foto user ditambahkan.");
      });
    } catch (e) {
      print("❌ Gagal menambahkan marker user: $e");
    }
  }

  Future<void> _loadInitialLocation() async {
    final position = await Geolocator.getCurrentPosition();
    await _addMyDeviceMarker(position);

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
  }

  Future<void> _showORSRoute(LatLng start, LatLng end) async {
    final route = await OpenRouteService().getRoute(start: start, end: end);

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("ors_route"),
          points: route,
          width: 5,
          color: Colors.green,
        ),
      );
    });
  }

  Future<void> _initializePusher() async {
    _pusher = PusherChannelsFlutter();

    try {
      await _pusher.init(
        apiKey: '50678e8196ba007f9922',
        cluster: 'ap1',
        logToConsole: true,

        onEvent: _onPusherEvent,
      );
      await _pusher.subscribe(channelName: 'vehicle-tracking');
      await _pusher.connect();
      print("✅ Pusher connected");
    } catch (e) {
      print("❌ Pusher connection failed: $e");
    }
  }

  Future<void> _loadCustomerMarkers() async {
    final userData = await SharedPreferences.getInstance();
    final jsonString = userData.getString('user_data');
    if (jsonString == null) return;

    final userMap = jsonDecode(jsonString);
    final int userId = userMap['id'];

    final jobs = await APIService().getCustomerByUser(userId);

    for (final job in jobs) {
      final isSelesai = job.status.toString() == '1';

      final marker = Marker(
        markerId: MarkerId('job_${job.id}'),
        position: LatLng(job.lat, job.long),
        infoWindow: InfoWindow(
          title: job.customerName,
          snippet:
              isSelesai
                  ? 'Customer sudah selesai'
                  : 'Customer ini belum Selesai',
        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelesai ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() {
            _selectedJobPosition = LatLng(job.lat, job.long);
          });
        },
      );

      setState(() {
        _markers.add(marker);
      });
    }

    print("✅ ${jobs.length} pelanggan ditampilkan di map.");
  }

  Future<void> _refreshMarkers() async {
    setState(() {
      _markers.clear();
      _polylines.clear();
    });

    await _loadInitialLocation();
    await _loadCustomerMarkers();
  }

  Future<void> _drawRouteToJob() async {
    if (_selectedJobPosition == null) return;

    final currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final origin = LatLng(currentPosition.latitude, currentPosition.longitude);
    final destination = _selectedJobPosition!;

    try {
      final route = await OpenRouteService().getRoute(
        start: origin,
        end: destination,
      );

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("ors_route"),
            points: route,
            width: 5,
            color: Colors.green,
          ),
        );
      });

      print("✅ Rute ditampilkan dari posisi ke pelanggan.");
    } catch (e) {
      print("❌ Gagal menampilkan rute ORS: $e");
    }
  }

  void _onPusherEvent(PusherEvent event) async {
    print("📡 Pusher event received: ${event.eventName}");

    if (event.eventName == 'location.updated' && event.data != null) {
      try {
        final data = jsonDecode(event.data!);
        print("📦 Event Data: $data");

        final double lat = double.parse(data['lat'].toString());
        final double lng = double.parse(data['lng'].toString());
        final String vehicleId = data['vehicle_id'].toString();
        final String name = data['name'].toString();

        print("🧭 Menambahkan marker untuk $name pada $lat, $lng");

        _addRemoteMarker(lat, lng, name, vehicleId);

        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
        );
      } catch (e) {
        print("❌ Failed to process Pusher event: $e");
      }
    }
  }

  void _addRemoteMarker(double lat, double lng, String name, String id) async {
    final markerId = MarkerId('vehicle_$id');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      String title = "Pekerja";

      if (userDataString != null) {
        final userData = Map<String, dynamic>.from(jsonDecode(userDataString));
        title = userData['username'] ?? "Kendaraan";
      }

      // Buat custom marker
      final customIcon = await CircleMarkerWithPin(
        text: title,
        imagePath: 'assets/images/user_image.png',
      ).toBitmapDescriptor(
        logicalSize: const Size(180, 280),
        imageSize: const Size(180, 280),
      );

      final marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        icon: customIcon,
        infoWindow: InfoWindow(title: title),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId == markerId);
        _markers.add(marker);
      });

      print("✅ Marker with image added for $title at ($lat, $lng)");
    } catch (e) {
      print("❌ Error creating custom marker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking'),
        actions: [
          IconButton(
            onPressed: () {
              _refreshMarkers();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCamera,
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) => _controller.complete(controller),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: (_) {
          setState(() {
            _selectedJobPosition = null;
          });
        },
      ),
      floatingActionButton:
          _selectedJobPosition != null
              ? Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton.extended(
                  onPressed: _drawRouteToJob,
                  icon: const Icon(Icons.alt_route),
                  label: const Text("Lihat Rute"),
                ),
              )
              : null,
    );
  }
}
