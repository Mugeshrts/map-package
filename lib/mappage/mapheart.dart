// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:geolocator/geolocator.dart';
// import 'dart:typed_data';

// class Mapheart extends StatefulWidget {
//   const Mapheart({super.key});

//   @override
//   State<Mapheart> createState() => _MappageState();
// }

// class _MappageState extends State<Mapheart> {
//   late GoogleMapController mapController;
//   final Set<Marker> _markers = {}; // Store multiple markers
//   final Map<String, Uint8List> _cachedIcons = {}; // Cache marker images
//   LatLng? _currentPosition; // Store user's current location

//   /// 📍 **List of Locations with Different Marker Types**
//   final List<Map<String, dynamic>> _locations = [
//     {"position": LatLng(11.280982, 77.595181), "value": "10", "label": "Factory", "markerType": "hospital"},
//     {"position": LatLng(11.275143, 77.590923), "value": "5", "label": "Hospital", "markerType": "police"},
//     {"position": LatLng(11.276488, 77.588505), "value": "8", "label": "Park", "markerType": "Park"},
//   ];

//   /// 📌 **Mapping Marker Types to Asset Paths**
//   final Map<String, String> _markerAssets = {
//     "hospital": "assets/images/industry.png",
//     "police": "assets/images/hospital-building.png",
//     "school": "assets/images/park (2).png",
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initializeMarkers();
//     _getCurrentLocation(); // Fetch and move to user's location
//   }

//   Future<void> _initializeMarkers() async {
//     for (var location in _locations) {
//       final markerType = location["markerType"] ?? "default";
//       final assetPath = _markerAssets[markerType] ?? "assets/images/default.png";

//       final markerIcon = await _getCustomMarker(
//         assetPath,
//         location["value"],
//         location["label"],
//       );

//       _addMarker(location["position"], location["label"], markerIcon);
//     }
//   }

//   void _addMarker(LatLng position, String label, Uint8List markerIcon) {
//     final marker = Marker(
//       markerId: MarkerId(label),
//       position: position,
//       icon: BitmapDescriptor.fromBytes(markerIcon),
//       infoWindow: InfoWindow(title: label, snippet: "Custom $label marker"),
//     );

//     setState(() {
//       _markers.add(marker);
//     });
//   }

//   /// 📌 **Fetch User's Current Location**
//   Future<void> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever) return;
//     }

//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     _currentPosition = LatLng(position.latitude, position.longitude);

//     if (mapController != null) {
//       mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
//     }
//   }

//   Future<Uint8List> _getCustomMarker(String assetPath, String value, String label) async {
//     final String cacheKey = "$label-$assetPath"; // Unique cache key per marker type
//     if (_cachedIcons.containsKey(cacheKey)) {
//       return _cachedIcons[cacheKey]!;
//     }

//     final Uint8List baseImage = await _loadImage(assetPath, 150);
//     final Uint8List customMarker = await _addHeartBadge(baseImage, value, label);

//     _cachedIcons[cacheKey] = customMarker; // Cache the processed image
//     return customMarker;
//   }

//    Future<Uint8List> _loadImage(String path, int width) async {
//     final ByteData data = await rootBundle.load(path);
//     final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
//     final ui.FrameInfo frame = await codec.getNextFrame();
//     final ByteData? byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }

//    Future<Uint8List> _addHeartBadge(Uint8List markerImage, String value, String label) async {
//     final ui.Codec codec = await ui.instantiateImageCodec(markerImage);
//     final ui.FrameInfo frame = await codec.getNextFrame();
//     final ui.Image baseIcon = frame.image;

//     final double iconWidth = baseIcon.width.toDouble();
//     final double totalHeight = baseIcon.height + 80; // Extra space for heart & text
//     final double heartSize = 50; // Increase this to make the heart bigger

//     final ui.PictureRecorder recorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(recorder);
//     final Paint paint = Paint()..color = Colors.red;

//     // Draw base icon
//     canvas.drawImage(baseIcon, Offset(0, 60), paint);

//     // Draw heart shape
//     _drawHeart(canvas, paint, iconWidth / 2, heartSize, heartSize);

//     // Draw value inside the heart
//     final TextPainter valueText = TextPainter(
//       text: TextSpan(
//         text: value,
//         style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );
//     valueText.layout();
//       // Calculate center position inside the heart
//   double textX = (iconWidth - valueText.width) / 2;
//   double textY = heartSize / 1.5; // Adjust to center inside heart

//   // Draw value inside the heart
//   valueText.paint(canvas, Offset(textX, textY));

//     // Draw label text below the icon
//     final TextPainter labelText = TextPainter(
//       text: TextSpan(
//         text: label,
//         style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );
//     labelText.layout();
//     labelText.paint(canvas, Offset((iconWidth - labelText.width) / 2, totalHeight - 30));

//     final ui.Image finalImage = await recorder.endRecording().toImage(iconWidth.toInt(), totalHeight.toInt());
//     final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }

//   void _drawHeart(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
//     final Path heartPath = Path();

//     heartPath.moveTo(centerX, centerY + size / 4);
    
//     heartPath.cubicTo(
//         centerX - size, centerY - size / 2, 
//         centerX - size / 2, centerY - size, 
//         centerX, centerY - size / 2);

//     heartPath.cubicTo(
//         centerX + size / 2, centerY - size, 
//         centerX + size, centerY - size / 2, 
//         centerX, centerY + size / 4);

//     heartPath.close();
//     canvas.drawPath(heartPath, paint);
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Google Maps Multiple Markers'),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(Icons.my_location),
//         //     onPressed: _getCurrentLocation, // Button to move to user's location
//         //   ),
//         // ],
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _locations[0]["position"], // Default location
//           zoom: 10,
//         ),
//         markers: _markers,
//         myLocationEnabled: true, // ✅ Shows default blue dot
//         myLocationButtonEnabled: true, // ✅ Allows user to recenter map
//       ),
//     );
//   }
// }
