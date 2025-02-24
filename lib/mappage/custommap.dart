import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class Mappage1 extends StatefulWidget {
  const Mappage1({super.key});

  @override
  State<Mappage1> createState() => _MappageState();
}

class _MappageState extends State<Mappage1> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {}; // Store multiple markers
  final Map<String, Uint8List> _cachedIcons = {}; // Cache marker images

  /// 📍 **List of Locations with Different Marker Types**
  final List<Map<String, dynamic>> _locations = [
    {"position": LatLng(11.280982, 77.595181), "value": "10", "label": "Hospital A", "markerType": "hospital"},
    {"position": LatLng(11.275143, 77.590923), "value": "5", "label": "Police Station", "markerType": "police"},
    {"position": LatLng(11.276488, 77.588505), "value": "8", "label": "School B", "markerType": "school"},
  ];

  /// 📌 **Mapping Marker Types to Asset Paths**
  final Map<String, String> _markerAssets = {
    "hospital": "assets/images/industry.png",
    "police": "assets/images/hospital-building.png",
    "school": "assets/images/park (2).png",
  };

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  Future<void> _initializeMarkers() async {
    for (var location in _locations) {
      final markerType = location["markerType"] ?? "default";
      final assetPath = _markerAssets[markerType] ?? "assets/images/default.png";

      final markerIcon = await _getCustomMarker(
        assetPath,
        location["value"],
        location["label"],
      );

      _addMarker(location["position"], location["label"], markerIcon);
    }
  }

  void _addMarker(LatLng position, String label, Uint8List markerIcon) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      icon: BitmapDescriptor.fromBytes(markerIcon),
      infoWindow: InfoWindow(title: label, snippet: "Custom $label marker"),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  Future<Uint8List> _getCustomMarker(String assetPath, String value, String label) async {
    final String cacheKey = "$label-$assetPath"; // Unique cache key per marker type
    if (_cachedIcons.containsKey(cacheKey)) {
      return _cachedIcons[cacheKey]!;
    }

    final Uint8List baseImage = await _loadImage(assetPath, 150);
    final Uint8List customMarker = await _addCustomBadge(baseImage, value, label);

    _cachedIcons[cacheKey] = customMarker; // Cache the processed image
    return customMarker;
  }

  Future<Uint8List> _loadImage(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// **🎨 Create Custom Hexagon-Shaped Badge**
  Future<Uint8List> _addCustomBadge(Uint8List markerImage, String value, String label) async {
    final ui.Codec codec = await ui.instantiateImageCodec(markerImage);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image baseIcon = frame.image;

    final double iconWidth = baseIcon.width.toDouble();
    final double totalHeight = baseIcon.height + 80; // Extra space for badge & text
    final double badgeSize = 60;
    final double centerX = iconWidth / 2;
    final double centerY = badgeSize / 2;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = Colors.red; // Badge color

    // 📌 **Define Custom Hexagon Path**
    Path path = Path();
    path.moveTo(centerX, centerY - badgeSize / 2); // Top
    path.lineTo(centerX + badgeSize / 2, centerY - badgeSize / 4);
    path.lineTo(centerX + badgeSize / 2, centerY + badgeSize / 4);
    path.lineTo(centerX, centerY + badgeSize / 2);
    path.lineTo(centerX - badgeSize / 2, centerY + badgeSize / 4);
    path.lineTo(centerX - badgeSize / 2, centerY - badgeSize / 4);
    path.close();

    // 🎨 Draw the Custom Badge
    canvas.drawPath(path, paint);

    // 🏷️ **Draw Badge Text (Centered)**
    final TextPainter badgeText = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    badgeText.layout();
    badgeText.paint(canvas, Offset((iconWidth - badgeText.width) / 2, centerY - 10));

    // 🏷️ **Draw Label Text Below the Icon**
    final TextPainter labelText = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    labelText.layout();
    labelText.paint(canvas, Offset((iconWidth - labelText.width) / 2, totalHeight - 30));

    // Convert Canvas to Image
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
        initialCameraPosition: CameraPosition(target: _locations[0]["position"], zoom: 10),
        markers: _markers,
      ),
    );
  }
}
