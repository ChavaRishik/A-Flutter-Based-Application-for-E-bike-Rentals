import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as IMG;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prayanaev/pages/bike_page.dart';
import 'package:prayanaev/sidebar.dart'; // Import the bike page

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late LatLng initialPosition;
  Set<Marker> _markers = {};
  late List<DocumentSnapshot> _bikeData = [];
  final List<Map<String, dynamic>> icons = [
    {'icon': Icons.home, 'label': "Home", 'image': 'assets/images/iconhome.png'},
    {'icon': Icons.account_circle, 'label': "Profile", 'image': 'assets/images/iconuser.png'},
    {'icon': Icons.directions_bike, 'label': "Past Rides", 'image': 'assets/images/iconpastrides.png'},
    {'icon': Icons.account_balance_wallet, 'label': "Wallet", 'image': 'assets/images/iconwallet.png'},
    {'icon': Icons.headset_mic, 'label': "Support", 'image': 'assets/images/iconsupport.png'},
    {'icon': Icons.share, 'label': "Share", 'image': 'assets/images/iconshare.png'}, // Added Share option
    {'icon': Icons.info, 'label': "About Us", 'image': 'assets/images/iconabout.png'},
    {'icon': Icons.developer_mode, 'label': "Developers", 'image': 'assets/images/icondeveloper.png'},
  ];

  @override
  void initState() {
    super.initState();
    initialPosition = const LatLng(16.494430, 80.499245); // Default position
    _getBikeMarkers(initialPosition, 16.0); // Get bike markers for the default position
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white70,
        ),
        drawer: MySidebar(),
        body: _backgroundWidget(),
      ),
    );
  }

  Widget _backgroundWidget() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 16.0,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          onCameraMove: (CameraPosition position) {
            _getBikeMarkers(position.target, position.zoom);
          },
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.3,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Text(
              '${_bikeData.length} bikes available near you',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.03,
          left: 16,
          child: SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width - 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _bikeData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTapped(_bikeData[index].data()),
                  child: BikeCard(bike: _bikeData[index].data() as Map<String, dynamic>),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onCardTapped(dynamic bikeData) {
    if (bikeData is Map<String, dynamic>) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BikePage(bikeData: bikeData), // Pass bikeData here
        ),
      );
    } else {
      // Handle invalid data type
    }
  }

  Future<void> _getBikeMarkers(LatLng target, double zoom) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Bikes')
          .where('status', isEqualTo: 'free')
          .orderBy('id')
          .get();

      // Update bike data list
      setState(() {
        _bikeData = snapshot.docs;
      });

      // Add bike markers to the map
      final List<Marker> newMarkers = [];
      for (final doc in snapshot.docs) {
        final bike = doc.data() as Map<String, dynamic>;
        final bikePosition = LatLng(
          bike['latitude'] as double,
          bike['longitude'] as double,
        );

        // Resize marker image based on zoom level
        final Uint8List markerIconBytes = await _resizeMarkerImage(zoom);

        final marker = Marker(
          markerId: MarkerId(bike['id'] as String),
          position: bikePosition,
          infoWindow: InfoWindow(title: 'Bike ${bike['id']}'),
          icon: BitmapDescriptor.fromBytes(markerIconBytes),
        );
        newMarkers.add(marker);
      }
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching bike markers: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<Uint8List> _resizeMarkerImage(double zoom) async {
    ByteData byteData = await rootBundle.load('assets/images/prayanalogomarker.png');
    Uint8List imageData = byteData.buffer.asUint8List();

    double markerSize = 45.0;

    double scale = 1.0;
    if (zoom < 15) {
      scale = 0.75;
    } else if (zoom >= 15 && zoom < 17) {
      scale = 1.5;
    }

    IMG.Image? img = IMG.decodeImage(imageData);
    IMG.Image resized = IMG.copyResize(img!, width: (markerSize * scale).toInt(), height: (markerSize * scale).toInt());
    return Uint8List.fromList(IMG.encodePng(resized));
  }
}

class BikeCard extends StatelessWidget {
  final Map<String, dynamic> bike;

  const BikeCard({Key? key, required this.bike}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 250, // Adjust the width as needed
        height: 120, // Doubled the height
        child: Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'assets/images/bikeimg.png', // Corrected image path
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${bike['id']}'),
                      Text('${bike['charging']}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
