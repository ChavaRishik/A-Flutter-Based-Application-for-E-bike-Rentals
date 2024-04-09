import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prayanaev/pages/map_page.dart';
import 'package:prayanaev/welcomepages/onboardingscreen.dart';
import 'package:prayanaev/pages/homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1250),
    );
    _animation = Tween<Offset>(
      begin: Offset(0, 1), // Start from below the screen
      end: Offset.zero, // End at the center of the screen
    ).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // After animation completes, check if the user is signed in
          checkUserSignIn();
        }
      });
    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void checkUserSignIn() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (user != null) {
        // If user is signed in, navigate to homepage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MapPage(), // Replace with your homepage
          ),
        );
      } else {
        // If user is not signed in, navigate to onboarding screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FBF2),
      body: Center(
        child: SlideTransition(
          position: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/prayanalogo.png',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
