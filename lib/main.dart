import 'package:flutter/material.dart';
import 'package:mappackage/Homepage/Homepage.dart';
import 'package:mappackage/mappage/custommap.dart';
import 'package:mappackage/mappage/mapheart.dart';
import 'package:mappackage/mappage/maprectangle.dart';
import 'package:mappackage/mappage/mapstar.dart';
import 'package:mappackage/mappage/maptriangle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps with Custom Marker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Mappage1(),
    );
  }
}

