import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late GoogleMapController mapController;

  final LatLng employeeLocation = const LatLng(13.0866, 80.2051);

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    markers.add(
      const Marker(
        markerId: MarkerId("employee"),
        position: LatLng(13.0866, 80.2051),
        infoWindow: InfoWindow(title: "Employee Location"),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Live Location")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.0866, 80.2051),
          zoom: 16,
        ),
        markers: markers,
      ),
    );
  }
}