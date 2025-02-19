import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mappackage/mapbloc/mapevent.dart';
import 'package:mappackage/mapbloc/mapstate.dart';
/// BLoC Implementation


  class MapBloc extends Bloc<MapEvent, MapState> {
  GoogleMapController? _mapController;

  MapBloc() : super(MapInitial()) {
    on<LoadMap>((event, emit) async {
      try {
        Position position = await _determinePosition();
        LatLng latLng = LatLng(position.latitude, position.longitude);

        emit(MapLoaded(latLng, markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: latLng,
            infoWindow: const InfoWindow(title: "Your Location"),
          ),
        }));
      } catch (e) {
        emit(MapError("Failed to get location: ${e.toString()}"));
      }
    });

    on<SetMapController>((event, emit) {
      _mapController = event.controller;
      if (state is MapLoaded) {
        emit((state as MapLoaded).copyWith(mapController: _mapController));
      }
    });

    on<LocateCurrentPosition>((event, emit) async {
      try {
        Position position = await _determinePosition();
        LatLng latLng = LatLng(position.latitude, position.longitude);

        _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

        emit(MapLoaded(latLng, markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: latLng,
            infoWindow: const InfoWindow(title: "Your Location"),
          ),
        }, mapController: _mapController));
      } catch (e) {
        emit(MapError("Failed to locate position: ${e.toString()}"));
      }
    });
  }

  /// Determines the current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition();
  }
}