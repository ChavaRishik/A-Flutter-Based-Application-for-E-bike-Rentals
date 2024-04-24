import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class EndRidePage extends StatefulWidget {
  final String bikeId;
  final DateTime startTime;
  final DateTime endTime;
  final String rideDuration;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final String destination;
  final double fare;
  final String userEmail;

  const EndRidePage({
    Key? key,
    required this.bikeId,
    required this.startTime,
    required this.endTime,
    required this.rideDuration,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.destination,
    required this.fare,
    required this.userEmail,
  }) : super(key: key);

  @override
  _EndRidePageState createState() => _EndRidePageState();
}

class _EndRidePageState extends State<EndRidePage> with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  bool checked = true;
  int walletBalance = 0;
  bool fetchingBalance = false;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _checkmarkController.forward().whenComplete(() {
      _viewRideDetails();
    });


    fetchWalletBalance(widget.userEmail).then((value) {
      setState(() {
        walletBalance = value;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching wallet balance: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    super.dispose();
  }

  void _viewRideDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF69D84F),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ride Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      'Ride Duration: ${widget.rideDuration}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Start Coordinates: ${widget.startLatitude}, ${widget.startLongitude}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Destination: ${widget.destination} (${widget.endLatitude}, ${widget.endLongitude})',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Fare: \₹${widget.fare.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        fetchingBalance = true;
                      });
                      try {
                        int balance = await fetchWalletBalance(widget.userEmail);
                        setState(() {
                          walletBalance = balance;
                          fetchingBalance = false;
                        });
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error fetching wallet balance: $error'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        setState(() {
                          fetchingBalance = false;
                        });
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF69D84F)),
                    ),
                    child: fetchingBalance
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      'View Balance: \₹$walletBalance',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FBF2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/images/checkmark_animation.json',
              controller: _checkmarkController,
              height: 120,
              width: 120,
              onLoaded: (composition) {
                _checkmarkController
                  ..duration = composition.duration
                  ..forward().whenComplete(() {
                    _viewRideDetails();
                  });
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'Congratulations! Ride ended successfully',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF69D84F)),
              ),
              child: Text(
                'Go To Home',
                style: TextStyle(color: Colors.white),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<int> fetchWalletBalance(String userEmail) async {
    int balance = 0;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
      if (snapshot.exists) {
        balance = snapshot['wallet'] ?? 0;
      } else {
        throw 'User document does not exist';
      }
    } catch (e) {
      throw 'Error fetching wallet balance: $e';
    }
    return balance;
  }
  Future<void> _downloadFile() async {
    try {
      // Create a storage reference
      final storageRef = FirebaseStorage.instance.ref();

      // Create a reference to the file you want to download
      final gsReference = storageRef.child("myImage.png");

      // Get the application directory for storing the downloaded file
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = "${appDocDir.path}/myImage.png";

      // Create a File object to save the downloaded file
      final file = File(filePath);

      // Download the file to the local device
      await gsReference.writeToFile(file);

      // Handle the download completion
      // You can add your logic here, such as showing a notification or updating UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image downloaded successfully'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Handle any errors that occur during the download process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading image: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
