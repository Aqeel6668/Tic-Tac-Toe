import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationData? _currentLocation; // Store current location data
  Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _updateLocation();
  }

  Future<void> _updateLocation() async {
    LocationData locationData = await _location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme!.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude!,
                      _currentLocation!.longitude!)
                  : LatLng(33.7132232, 73.0237095),
              zoom: 8,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                //subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              if (_currentLocation != null)
                MarkerLayer(markers: [
                  Marker(
                      point: LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_pin,
                        size: 60,
                        color: Colors.red,
                      )),
                ])
            ],
          ),
        ],
      ),
    );
  }
}
