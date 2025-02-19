import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mappackage/mapbloc/mapbloc.dart';
import 'package:mappackage/mapbloc/mapevent.dart';
import 'package:mappackage/mapbloc/mapstate.dart';


class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps with BLoC")),
      body: BlocProvider(
        create: (context) => MapBloc()..add(LoadMap()),
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoaded) {
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: state.currentLocation,
                      zoom: 15,
                    ),
                    markers: state.markers,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false, // Disable default button
                    onMapCreated: (GoogleMapController controller) {
                      context.read<MapBloc>().add(SetMapController(controller));
                    },
                  ),

                  // Floating Action Button in Top Right Corner
                  Positioned(
                    top: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        context.read<MapBloc>().add(LocateCurrentPosition());
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              );
            } else if (state is MapError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
