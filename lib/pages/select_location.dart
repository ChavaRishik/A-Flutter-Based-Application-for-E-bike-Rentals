import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chip_list/chip_list.dart';
import 'package:prayanaev/pages/on_ride.dart'; // Import the chip_list package
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SelectLocationPage extends StatefulWidget {

  final String bikeId;

  const SelectLocationPage({Key? key, required this.bikeId}) : super(key: key);

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  String _selectedLocation = 'CB';
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
  ]; // Available locations
  bool _isLoading = false; // Track loading state
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Destination'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              '${widget.bikeId}', // Use widget.bikeId here
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
            ChipList(
              listOfChipNames: _locations, // Use the locations list
              listOfChipIndicesCurrentlySeclected: [_locations.indexOf(_selectedLocation)],
              activeBgColorList: [Theme.of(context).primaryColor],
              activeTextColorList: [Colors.white],
              extraOnToggle: (val) {
                setState(() {
                  _selectedLocation = _locations[val];
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:_isLoading
                  ? null
                :() {
                // Call function to start bike with selected location
                _startBike(widget.bikeId, _selectedLocation);
              },

              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF69D84F)),
              ),
              child: _isLoading // Display loading animation if _isLoading is true
                  ? LoadingAnimationWidget.waveDots(
                color: Colors.white,
                size: 24,
              )
               : Text(
                'Start Bike',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _startBike(String bikeId, String selectedLocation) async {
    try {
      setState(() {
    _isLoading = true; // Start loading animation
    });
      // Create a reference to the Firebase Realtime Database
      DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
      // Push the bike ID into the "BikesNeedToStart" bucket
      databaseReference.child('BikesNeedToStart').push().set({
        'bikeId': bikeId,
        'selectedLocation': selectedLocation,
        'status': 'Pending', // You can set status as 'Pending' or any other initial status
      }).then((_) {
        // If push is successful, update the bike status in Firestore
        FirebaseFirestore.instance.doc('Bikes/$bikeId').update({
          'status': 'InUse',
        }).then((_) {
          // If update is successful, navigate to OnRide screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OnRide(initialLocation: selectedLocation, bikeId: bikeId),
            ),
          );
          print('Bike $bikeId started at $selectedLocation');
        }).catchError((error) {
          // Handle error if Firestore update fails
          print('Failed to update bike status in Firestore: $error');
        });
      }).catchError((error) {
        // Handle error if push to Realtime Database fails
        print('Failed to push bike data to Realtime Database: $error');
      });
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

}
