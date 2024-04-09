import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonDisabled ? null : () => resetPassword(context, emailController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF69D84F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),fixedSize: Size(180, 40),
              ),
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    setState(() {
      isButtonDisabled = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle errors
      String errorMessage = 'An error occurred. Please try again later.';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with that email address.';
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Enable the button after 60 seconds
    Future.delayed(Duration(seconds: 60), () {
      setState(() {
        isButtonDisabled = false;
      });
    });
  }
}
