import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Import FirebaseDatabase
import 'end_ride.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OnRide extends StatefulWidget {
  final String initialLocation;
  final String bikeId;

  const OnRide({Key? key, required this.initialLocation, required this.bikeId})
      : super(key: key);

  @override
  _OnRideState createState() => _OnRideState();
}

class _OnRideState extends State<OnRide> {
  late GoogleMapController mapController;
  LatLng? initialPosition;
  Set<Marker> _markers = {};
  late DateTime _rideStartTime;
  late Timer _timer;
  String _rideDuration = '';
  List<String> _locations = [
    'AB1',
    'AB2',
    'CB',
    'SAC',
    'SPORTS TRIANGLE',
    'MH1',
    'MH2',
    'MH3',
    'MH4',
    'LH',
  ]; // Define your locations here
  String _selectedLocation = ''; // Define a default selected location
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation; // Set initial location
    _getUserLocation();
    _rideStartTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _calculateRideDuration();
      });
    });
  }

  void _calculateRideDuration() {
    final now = DateTime.now();
    final difference = now.difference(_rideStartTime);
    setState(() {
      _rideDuration = '${difference.inMinutes} : ${difference.inSeconds % 60} s';
    });
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        body: Stack(
          children: [
            _buildGoogleMap(),
            _buildRideDurationContainer(),
            _buildChangeDestinationButton(),
            _buildEndRideButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return initialPosition != null
        ? GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition!,
        zoom: 16.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
    )
        : Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildRideDurationContainer() {
    return Positioned(
      top: 60,
      left: 50,
      right: 50,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'Ride started since: $_rideDuration',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildChangeDestinationButton() {
    return Positioned(
      top: 120,
      left: 50,
      right: 50,
      child: ElevatedButton(
        onPressed: () {
          _showLocationSelectionDialog();
        },
        style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all<Color>(Color(0xFF69D84F)),
        ),
        child: Text(
          'Change Destination',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEndRideButton() {
    return Positioned(
      bottom: 20,
      left: 50,
      right: 50,
      child: ElevatedButton(
        onPressed:_isLoading
            ? null
            : _endRide,
        style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all<Color>(Color(0xFF69D84F)),
        ),
        child: _isLoading // Display loading animation if _isLoading is true
            ? LoadingAnimationWidget.waveDots(
          color: Colors.white,
          size: 24,
        )
            :  Text(
          'End Ride',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showLocationSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Destination'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _locations
                .map(
                  (location) => ChoiceChip(
                label: Text(location),
                selected: location == _selectedLocation,
                onSelected: (selected) {
                  setState(() {
                    _selectedLocation = location;
                  });
                  Navigator.pop(context);
                },
              ),
            )
                .toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to end the ride
  void _endRide() async {
    try {
      setState(() {
        _isLoading = true; // Start loading animation
      });
      // Retrieve bike coordinates from Firebase
      DocumentSnapshot bikeSnapshot = await FirebaseFirestore.instance.collection('Bikes').doc(widget.bikeId).get();
      Map<String, dynamic>? bikeData = bikeSnapshot.data() as Map<String, dynamic>?;

      if (bikeData == null) {
        throw Exception('Failed to retrieve bike coordinates');
      }

      double bikeLatitude = (bikeData['latitude'] as double?) ?? 0;
      double bikeLongitude = (bikeData['longitude'] as double?) ?? 0;

      // Retrieve destination coordinates from Firebase based on selected location
      DocumentSnapshot destinationSnapshot =
      await FirebaseFirestore.instance.collection('Destinations').doc(_selectedLocation).get();
      Map<String, dynamic>? destinationData = destinationSnapshot.data() as Map<String, dynamic>?;

      double? destinationLatitude;
      double? destinationLongitude;

      if (destinationData == null) {
        throw Exception('Selected location not found');
      } else {
        destinationLatitude = (destinationData['latitude'] as double?) ?? 0;
        destinationLongitude = (destinationData['longitude'] as double?) ?? 0;
      }

      // Retrieve user's current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // Check if all coordinates are within 10m radius and destination coordinates are not null
      if (destinationLatitude != null && destinationLongitude != null) {
        double bikeDestinationDistance =
        Geolocator.distanceBetween(bikeLatitude, bikeLongitude, destinationLatitude, destinationLongitude);
        double bikeUserDistance = Geolocator.distanceBetween(bikeLatitude, bikeLongitude, userLatitude, userLongitude);
        double userDestinationDistance =
        Geolocator.distanceBetween(userLatitude, userLongitude, destinationLatitude, destinationLongitude);

        if (bikeDestinationDistance > 1000 || bikeUserDistance > 1000 || userDestinationDistance > 1000) {
          // Display error message if coordinates are not within 10m radius
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You must be at the selected destination to end the ride.'),
            ),
          );
          return;
        }
      } else {
        throw Exception('Selected location coordinates are invalid');
      }

      // Inside the _endRide() function or wherever needed
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = '';

      if (user != null) {
        userEmail = user.email ?? '';
      } else {
        // Handle the case when the user is not logged in
      }

      // Calculate ride duration
      final now = DateTime.now();
      final difference = now.difference(_rideStartTime);
      String rideDuration = '${difference.inMinutes} : ${difference.inSeconds % 60} s';

      // Deduct fare from the wallet balance
      int fare = 20; // Assuming fare is 20
      int walletBalance = 0; // Initialize wallet balance
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('wallet') && userData['wallet'] is int) {
        walletBalance = userData['wallet'] as int; // Retrieve wallet balance
      } else {
        throw Exception('Wallet data does not exist for this user or is not in expected format');
      }

      if (walletBalance < fare) {
        throw Exception('Insufficient balance to end the ride');
      }

      // Update wallet balance in Firestore
      int newWalletBalance = walletBalance - fare;
      await FirebaseFirestore.instance.collection('users').doc(userEmail).update({'wallet': newWalletBalance});

      // Proceed with ending the ride
      // Navigate to EndRidePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EndRidePage(
            bikeId: widget.bikeId,
            startTime: _rideStartTime,
            endTime: now, // Pass the end time
            rideDuration: rideDuration, // Pass the ride duration
            startLatitude: bikeLatitude,
            startLongitude: bikeLongitude,
            endLatitude: destinationLatitude!,
            endLongitude: destinationLongitude!,
            destination: _selectedLocation,
            userEmail: userEmail,
            fare: fare.toDouble(),

          ),
        ),
      );

      // Update ride data in Firestore
      FirebaseFirestore.instance.collection('users').doc(userEmail).collection('past_rides').add({
        'bike_id': widget.bikeId,
        'start_time': _rideStartTime,
        'end_time': now,
        'start_coordinates': GeoPoint(bikeLatitude, bikeLongitude),
        'end_coordinates': GeoPoint(destinationLatitude, destinationLongitude),
        'duration': rideDuration,
        'fare': fare,
        // Add other ride details as needed
      });
      await FirebaseFirestore.instance.collection('users').doc(userEmail).update({'numberOfRides': FieldValue.increment(1)});


      // Update ride data in bikes collection
      FirebaseFirestore.instance.collection('Bikes').doc(widget.bikeId).update({
        'status': 'free', // Update bike status
      });

      // Update ride data in Bikes/BikeId/past_rides
      FirebaseFirestore.instance.collection('Bikes').doc(widget.bikeId).collection('past_rides').add({
        'user_email': userEmail,
        'start_time': _rideStartTime,
        'end_time': now,
        'start_coordinates': GeoPoint(bikeLatitude, bikeLongitude),
        'end_coordinates': GeoPoint(destinationLatitude, destinationLongitude),
        'duration': rideDuration,
        // Add other ride details as needed
      });

      // Add bike ID and current location to Realtime Database if conditions are satisfied
      DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child('BikesNeedToStop').push().set({
        'bikeId': widget.bikeId,
      }).then((_) {
        print('Bike ${widget.bikeId} added to BikesNeedToStop');
      }).catchError((error) {
        print('Failed to add bike to BikesNeedToStop: $error');
      });
    } catch (e) {
      // Display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error ending the ride: $e'),
        ),
      );
      print('Error ending the ride: $e');
    }
  }
}
