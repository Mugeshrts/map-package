import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// States for the BLoC
abstract class MapState extends Equatable {
  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {}

class MapLoaded extends MapState {
  final LatLng currentLocation;
  final Set<Marker> markers;
  final GoogleMapController? mapController;
  MapLoaded(this.currentLocation, {this.markers = const{},this.mapController});

  MapLoaded copyWith({LatLng? currentLocation, GoogleMapController? mapController}) {
   return MapLoaded(
    currentLocation ?? this.currentLocation,
    markers: markers,
    mapController: mapController ?? this.mapController,
   );
  }
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}