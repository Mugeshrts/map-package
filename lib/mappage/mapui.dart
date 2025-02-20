import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class Mappage extends StatefulWidget {
  const Mappage({super.key});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {}; // Store multiple markers

  // List of marker positions with value & text
  final List<Map<String, dynamic>> _locations = [
    {"position": LatLng(37.7749, -122.4194), "value": "10", "label": "San Francisco"},
    {"position": LatLng(34.0522, -118.2437), "value": "5", "label": "Los Angeles"},
    {"position": LatLng(40.7128, -74.0060), "value": "8", "label": "New York"},
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // Load markers asynchronously
  Future<void> _loadMarkers() async {
    Set<Marker> markers = {};

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
            snippet: "Custom Marker with badge",
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

    final double iconY = badgeHeight + 10; // Space added
    canvas.drawImage(marker, Offset(0, iconY), paint);

    // Draw circular badge
    final Paint badgePaint = Paint()..color = Colors.red;
    final double badgeX = iconWidth / 2;
    final double badgeY = badgeRadius;
    canvas.drawCircle(Offset(badgeX, badgeY), badgeRadius, badgePaint);

    // Draw badge text
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

    // Draw bottom text (larger for readability)
    final TextPainter bottomTextPainter = TextPainter(
      text: TextSpan(
        text: bottomText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20, // Increased font size
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Multiple Markers')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _locations[0]["position"], // Default focus
          zoom: 5,
        ),
        markers: _markers,
      ),
    );
  }
}
