import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereshot/theme/app_theme.dart';

class MapView extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final double initialZoom;
  final Function(LatLng)? onTap;
  
  const MapView({
    super.key,
    required this.initialPosition,
    this.markers = const {},
    this.initialZoom = 14.0,
    this.onTap,
  });
  
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _mapController;
  bool _mapLoaded = false;
  String? _mapError;
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.m),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: widget.initialZoom,
            ),
            markers: widget.markers,
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
                _mapLoaded = true;
              });
            },
            onTap: widget.onTap,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onCameraIdle: () {
              if (mounted) {
                setState(() {
                  _mapLoaded = true;
                });
              }
            },
          ),
          
          if (!_mapLoaded)
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          if (_mapError != null)
            Container(
              color: Colors.red.withValues(alpha: 0.3),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Map error: $_mapError',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.m),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      if (_mapLoaded && _mapError == null) {
                        _mapController.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      }
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      if (_mapLoaded && _mapError == null) {
                        _mapController.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      }
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    if (_mapLoaded && _mapError == null) {
      _mapController.dispose();
    }
    super.dispose();
  }
} 