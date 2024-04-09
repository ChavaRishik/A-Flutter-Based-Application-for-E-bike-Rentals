import 'dart:async'; // Add this import for Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:prayanaev/authentication/loginpage.dart';

class EmailVerificationPage extends StatefulWidget {
  final User user;

  const EmailVerificationPage({Key? key, required this.user}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isEmailVerified = false;
  bool _isResendDisabled = true;
  late Timer _timer;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkEmailVerification();
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _isResendDisabled = false;
        });
      }
    });
  }

  void _checkEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (_isEmailVerified) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email Successfully Verified")));
      _timer.cancel();
      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendDisabled = true;
      _resendCooldown = 60; // Set cooldown to 60 seconds
    });

    await widget.user.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification email resent.'),
      ),
    );
  }

  String getFormattedCooldown() {
    int minutes = _resendCooldown ~/ 60;
    int seconds = _resendCooldown % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Email Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _isEmailVerified
                ? Column(
              children: [
                Text(
                  'Email verified successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                LoadingAnimationWidget.flickr(
                  size: 50,
                  leftDotColor: Colors.lightGreenAccent,
                  rightDotColor: CupertinoColors.systemGrey3,
                ),
              ],
            )
                : Column(
              children: [
                Text(
                  'Please verify your email address.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                LoadingAnimationWidget.flickr(
                  size: 50,
                  leftDotColor: Colors.lightGreenAccent,
                  rightDotColor: CupertinoColors.systemGrey3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isResendDisabled ? null : _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF69D84F), // Green color
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Resend',
                        style: TextStyle(
                          color: Colors.white,

                        ),
                      ),
                      SizedBox(width: 10),
                      if (_isResendDisabled)
                        Text(
                          '${getFormattedCooldown()}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
