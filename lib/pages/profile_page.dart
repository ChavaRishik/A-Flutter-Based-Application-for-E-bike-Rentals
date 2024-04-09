import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prayanaev/authentication/loginpage.dart';
import 'package:prayanaev/authentication/email_verification_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF69D84F),
                borderRadius: BorderRadius.all( Radius.circular(20)),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(''), // Add user profile image URL here
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Name', // Replace with user display name
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Placeholder until data is loaded
                      }
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Number of Rides: ${snapshot.data!['numberOfRides']}', // Assuming this is how you retrieve number of rides from Firestore
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Wallet Balance: ${snapshot.data!['wallet']}', // Assuming this is how you retrieve wallet balance from Firestore
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            buildOptionButton('Payment Method', 'paymentmethod.png', onPressed: () {
                              // Handle Payment Method button press
                            }),
                            buildOptionButton('Past Reviews', 'support.png', onPressed: () {
                              // Handle Past Reviews button press
                            }),
                            buildOptionButton('Get Help', 'gethelp.png', onPressed: () {
                              // Handle Get Help button press
                            }),
                            buildOptionButton('Logout', 'logout.png', onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                                    (route) => false,
                              );
                            }),
                          ],
                        );
                      }
                      return Text('Error fetching data');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionButton(String text, String iconPath, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Color(0xFF69D84F), // Use the same green color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icons/$iconPath',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold, // Set text to bold
                color: Colors.white, // Set text color to white
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white), // Set arrow color to white
          ],
        ),
      ),
    );
  }
}
