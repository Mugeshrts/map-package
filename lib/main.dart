import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class Mappage extends StatefulWidget {
  const Mappage({super.key});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {}; // Multiple markers
  LatLng? _currentLocation; // Store user location

  final List<Map<String, dynamic>> _locations = [
    {"position": LatLng(37.7749, -122.4194), "value": "10", "label": "San Francisco"},
    {"position": LatLng(34.0522, -118.2437), "value": "5", "label": "Los Angeles"},
    {"position": LatLng(40.7128, -74.0060), "value": "8", "label": "New York"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    Position position = await _determinePosition();
    print("object1");
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    Set<Marker> markers = {};

    // Load custom markers
    for (var location in _locations) {
      final Uint8List markerIcon = await _getBytesFromAsset('assets/images/man_avatar.png', 150);
      final Uint8List finalMarker = await _addBadgeAndText(markerIcon, location["value"], location["label"]);

      markers.add(
        Marker(
          markerId: MarkerId(location["label"]),
          position: location["position"],
          icon: BitmapDescriptor.fromBytes(finalMarker),
          infoWindow: InfoWindow(
            title: location["label"],
            snippet: "Custom Marker",
          ),
        ),
      );
    }

    // Add current location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: "You Are Here",
            snippet: "Your current location",
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _addBadgeAndText(Uint8List markerImage, String value, String bottomText) async {
    final ui.Codec markerCodec = await ui.instantiateImageCodec(markerImage);
    final ui.FrameInfo markerFrame = await markerCodec.getNextFrame();
    final ui.Image marker = markerFrame.image;

    final double iconWidth = marker.width.toDouble();
    final double totalHeight = marker.height / 0.6 + 60;

    final double badgeHeight = totalHeight * 0.3;
    final double badgeRadius = badgeHeight / 2;
    final double textHeight = totalHeight * 0.1;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint();

    final double iconY = badgeHeight + 10;
    canvas.drawImage(marker, Offset(0, iconY), paint);

    // Draw badge
    final Paint badgePaint = Paint()..color = Colors.red;
    final double badgeX = iconWidth / 2;
    final double badgeY = badgeRadius;
    canvas.drawCircle(Offset(badgeX, badgeY), badgeRadius, badgePaint);

    // Badge text
    final TextPainter badgeTextPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.white,
          fontSize: badgeHeight * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    badgeTextPainter.layout();
    badgeTextPainter.paint(canvas, Offset(badgeX - (badgeTextPainter.width / 2), badgeY - (badgeTextPainter.height / 2)));

    // Bottom text
    final TextPainter bottomTextPainter = TextPainter(
      text: TextSpan(
        text: bottomText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    bottomTextPainter.layout();
    bottomTextPainter.paint(canvas, Offset((iconWidth / 2) - (bottomTextPainter.width / 2), totalHeight - textHeight - 10));

    // Convert to image
    final ui.Image finalImage = await recorder.endRecording().toImage(iconWidth.toInt(), totalHeight.toInt());
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps - Multiple Markers & Current Location')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? _locations[0]["position"],
          zoom: 5,
        ),
        markers: _markers,
        myLocationEnabled: true, // Show blue dot
        myLocationButtonEnabled: true,
      ),
    );
  }
}
