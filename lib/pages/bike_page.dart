import 'package:flutter/material.dart';
import 'package:prayanaev/pages/scan_code_page.dart'; // Import the ScanCodePage
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package

class BikePage extends StatelessWidget {
  final Map<String, dynamic> bikeData;

  const BikePage({Key? key, required this.bikeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FBF2), // Set background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 60), // Add top margin
                child: Image.asset(
                  'assets/images/bikeimg3d.png', // Bike image path
                  width: 450, // Adjust width as needed
                  height: 300, // Adjust height as needed
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${bikeData['id']}',
                style: TextStyle(
                  fontSize: 24, // Increase font size
                  fontWeight: FontWeight.bold, // Make it bold
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  'Effortlessly navigate through campus, enjoying the perfect blend of style and sustainability. Bid farewell to traffic hassles and embrace the eco-friendly joy of electric-powered mobility.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _checkLocationServicesAndPermission(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF69D84F)), // Set button color
                ),
                child: Text('Scan QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLocationServicesAndPermission(BuildContext context) async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      // If location services are not enabled, show turn on location dialog
      _showLocationServiceDialog(context);
      return;
    }

    if (!(await Permission.locationWhenInUse.isGranted)) {
      // If location permission is not granted, request it
      _requestLocationPermission(context);
      return;
    }

    // If both location services and permission are granted, navigate to ScanCodePage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanCodePage()),
    );
  }

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Disabled"),
          content: Text("Please enable location services to proceed."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _requestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      // If permission is granted, navigate to ScanCodePage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanCodePage()),
      );
    } else {
      // If permission is denied, show a dialog informing the user about the importance of location permissions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Location Permission Required"),
            content: Text("Location permission is required to use this feature."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
