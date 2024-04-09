import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prayanaev/authentication/email_verification_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  bool _isChecked = false;
  bool _isLoading = false;
  String _errorText = '';

  Future<void> _registerWithEmailAndPassword(BuildContext context) async {
    if (!_isChecked) {
      setState(() {
        _errorText = 'Please accept the terms and conditions.';
      });
      return;
    }

    final email = _emailController.text.trim();
    if (!RegExp(r'^[\w-\.]+@(vitap|vitapstudent)\.ac\.in$').hasMatch(email)) {
      setState(() {
        _errorText = 'Please enter a valid VIT-AP email address.';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      // Fetch the user's display name
      User? user = FirebaseAuth.instance.currentUser;
      String? displayName = user?.displayName;

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      // Add user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .set({
        'displayName': displayName,
        'email': email,
        'phoneNumber': _phoneNumberController.text.trim(),
        'registrationNumber': _registrationNumberController.text.trim(),
        'wallet' : 150,
        'numberOfRides':0,
      });

      // Registration successful, navigate to the email verification page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmailVerificationPage(user: userCredential.user!)),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/prayanagreenlogo.png',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 56,
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/email_icon.png',
                        width: 27,
                        height: 27,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Add text field for Registration Number
                Container(
                  width: 320,
                  height: 56,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/id_icon.png', // Add the path to your ID icon
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _registrationNumberController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Registration Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Add text field for Phone Number
                Container(
                  width: 320,
                  height: 56,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/phone_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Phone Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 56,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/lock.png',
                        width: 27,
                        height: 27,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                          _errorText = '';
                        });
                      },
                    ),
                    Flexible(
                      child: Text(
                        'By checking the checkbox, you agree to our '
                            'Terms of Use, Privacy Statement, and that'
                            ' you are over 18. Prayana is committed to its Privacy Policy',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_errorText.isNotEmpty)
                  Text(
                    _errorText,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _registerWithEmailAndPassword(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF69D84F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: Size(168, 40),
                  ),
                  child: _isLoading
                      ? LoadingAnimationWidget.waveDots(
                    color: Colors.white,
                    size: 24,
                  )
                      : Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
