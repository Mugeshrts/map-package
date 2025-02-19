
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMap extends MapEvent {}

class LocateCurrentPosition extends MapEvent {}
class SetMapController extends MapEvent {
  final GoogleMapController controller;
  SetMapController(this.controller);
}
