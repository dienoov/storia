import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storia/common.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng, Placemark) onPicked;

  const LocationPicker({super.key, required this.onPicked});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController? _mapController;

  LatLng _position = const LatLng(-0.9720384, 116.7131314);
  Set<Marker> _markers = {};
  Placemark _placemark = Placemark();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _getPlacemark(_position);
  }

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _message = AppLocalizations.of(context)!.locationDisabled;
      });
      return;
    } else {
      setState(() {
        _message = '';
      });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _message = AppLocalizations.of(context)!.locationDenied;
        });
        return;
      } else {
        setState(() {
          _message = '';
        });
      }
    }

    final Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final LatLng position = LatLng(pos.latitude, pos.longitude);

    await _getPlacemark(position);

    setState(() {
      _position = position;
      _markers = {
        Marker(
          markerId: MarkerId(position.hashCode.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: _placemark.street,
            snippet: [
              _placemark.subLocality,
              _placemark.locality,
              _placemark.administrativeArea,
              _placemark.postalCode,
              _placemark.country,
            ].where((e) => e != '').join(', '),
          ),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    widget.onPicked(_position, _placemark);
  }

  Future<void> _onMapLongPress(LatLng position) async {
    await _getPlacemark(position);

    setState(() {
      _position = position;
      _markers = {
        Marker(
          markerId: MarkerId(position.hashCode.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: _placemark.street,
            snippet: [
              _placemark.subLocality,
              _placemark.locality,
              _placemark.administrativeArea,
              _placemark.postalCode,
              _placemark.country,
            ].where((e) => e != '').join(', '),
          ),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(position));

    widget.onPicked(_position, _placemark);
  }

  Future<void> _getPlacemark(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _placemark = placemarks.first;
        _message = '';
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 320,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _position,
                  zoom: 14,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _getPlacemark(_position);
                },
                onLongPress: _onMapLongPress,
                markers: _markers,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _placemark.street!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    [
                      _placemark.subLocality,
                      _placemark.locality,
                      _placemark.administrativeArea,
                      _placemark.postalCode,
                      _placemark.country,
                    ].where((e) => e != '').join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 12,
          right: 6,
          child: FloatingActionButton(
            elevation: 1,
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            onPressed: _getCurrentPosition,
            child: const Icon(Icons.my_location),
          ),
        ),
        if (_message.isNotEmpty)
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.all(12),
              child: Text(
                _message,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ),
      ],
    );
  }
}
