import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prayanaev/pages/map_page.dart';
import 'package:prayanaev/pages/profile_page.dart';

class MySidebar extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'User'), // Use user's display name if available, otherwise fallback to 'Your Name'
            accountEmail: Text(user?.email ?? 'your.email@example.com'), // Use user's email if available, otherwise fallback to a placeholder email
            currentAccountPicture: CircleAvatar(
              backgroundImage
                  : AssetImage('assets/profile_picture.jpg'), // Use user's photo if available, otherwise fallback to a default profile picture
            ),
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/iconhome.png', width: 24, height: 24),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage())); // Navigate to the MapPage
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/iconuser.png', width: 24, height: 24),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())); // Navigate to the ProfilePage
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/iconpastrides.png', width: 24, height: 24),
            title: Text('History'),
            onTap: () {
              // Navigate to the History page or perform any action
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/wallet.png', width: 24, height: 24),
            title: Text('Wallet'),
            onTap: () {
              // Navigate to the Wallet page or perform any action
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/iconsupport.png', width: 24, height: 24),
            title: Text('Support'),
            onTap: () {
              // Navigate to the Support page or perform any action
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/iconabout.png', width: 24, height: 24),
            title: Text('About Us'),
            onTap: () {
              // Navigate to the About Us page or perform any action
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/iconshare.png', width: 24, height: 24),
            title: Text('Share'),
            onTap: () {
              // Navigate to the Share page or perform any action
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/icons/icondeveloper.png', width: 24, height: 24),
            title: Text('Developers'),
            onTap: () {
              // Navigate to the Developers page or perform any action
            },
          ),
        ],
      ),
    );
  }
}


