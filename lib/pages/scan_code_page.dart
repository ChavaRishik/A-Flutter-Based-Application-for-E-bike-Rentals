import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import mobile_scanner package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'select_location.dart'; // Import SelectLocationPage
import 'dart:typed_data';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({Key? key}) : super(key: key);

  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
                returnImage: true,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                final Uint8List? image = capture.image;
                for (final barcode in barcodes) {
                  print('Barcode found! ${barcode.rawValue ?? "Unknown"}');
                  // Check the scanned QR code against bike IDs in Firestore
                  _checkBikeStatus(barcode.rawValue ?? "");
                }
                if (image != null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          barcodes.first.rawValue ?? "Unknown",
                        ),
                        content: Image(
                          image: MemoryImage(image),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to check bike status in Firestore
  Future<void> _checkBikeStatus(String bikeId) async {
    try {
      final bikeSnapshot = await FirebaseFirestore.instance
          .collection('Bikes')
          .doc(bikeId)
          .get();

      if (bikeSnapshot.exists) {
        final bikeData = bikeSnapshot.data() as Map<String, dynamic>;
        final bool isBikeFree = bikeData['status'] == 'free';

        if (isBikeFree) {
          // Bike is free, navigate to select location page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectLocationPage(bikeId: bikeId)),
          );
        } else {
          // Bike is not free, show a message or handle accordingly
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Bike Not Available'),
                content: Text('The scanned bike is currently not available.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Bike ID not found in Firestore
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Bike Not Found'),
              content: Text('The scanned bike ID was not found in the database.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
}
