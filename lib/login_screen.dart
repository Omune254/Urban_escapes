import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_escape_airbnbs/signup_screen.dart'; // Assuming this is your sign-up screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Guest'; // Default role
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Loading state

  // Define your colors
  final Color poppyRed = Color(0xFFE74C3C); // Poppy Red
  final Color gingerPeach = Color(0xFFFFA07A); // Ginger Peach
  final Color sunflowerYellow = Color(0xFFFFD700); // Sunflower Yellow

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    poppyRed,
                    gingerPeach
                  ], // Use Poppy Red and Ginger Peach
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: const Center(
                child: Text(
                  'Urban Escape',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 250),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email, color: poppyRed),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock, color: poppyRed),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Login as: ",
                            style: TextStyle(fontSize: 16)),
                        DropdownButton<String>(
                          value: _selectedRole,
                          dropdownColor: Colors.white,
                          items: <String>['Guest', 'Owner']
                              .map((role) => DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator()) // Loading indicator
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: sunflowerYellow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ), // Button color as Sunflower Yellow
                            ),
                            onPressed: _handleLogin, // Updated login handler
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAccountScreen()),
                        );
                      },
                      child: Text(
                        'Create an Account',
                        style: TextStyle(
                          color: poppyRed, // Text color as Poppy Red
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      icon: Icon(Icons.login, color: poppyRed),
                      label: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: poppyRed,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : _handleGoogleSignIn, // Disable if loading
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password logic
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: gingerPeach, // Accent with Ginger Peach
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Create an AppUser object from Firestore data
      AppUser loggedInUser = AppUser.fromFirestore(
          userDoc.data() as Map<String, dynamic>, userCredential.user!.uid);

      // Navigate based on user role and pass the user ID
      if (loggedInUser.role == 'Owner') {
        Navigator.of(context).pushReplacementNamed('/owner_home',
            arguments: loggedInUser.uid); // Pass userId
      } else {
        Navigator.of(context).pushReplacementNamed('/guest_room_search',
            arguments: loggedInUser.uid); // Pass userId
      }
    } on FirebaseAuthException catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Create an AppUser object from Firestore data
      AppUser loggedInUser = AppUser.fromFirestore(
          userDoc.data() as Map<String, dynamic>, userCredential.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logged in with Google successfully!")));
      // Navigate based on role and pass the user ID
      if (loggedInUser.role == 'Owner') {
        Navigator.of(context).pushReplacementNamed('/owner_home',
            arguments: loggedInUser.uid); // Pass userId
      } else {
        Navigator.of(context).pushReplacementNamed('/guest_room_search',
            arguments: loggedInUser.uid); // Pass userId
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }
}

class AppUser {
  final String uid;
  final String email;
  final String role;

  AppUser({required this.uid, required this.email, required this.role});

  factory AppUser.fromFirestore(
      Map<String, dynamic> firestoreData, String uid) {
    return AppUser(
      uid: uid,
      email: firestoreData['email'],
      role: firestoreData['role'],
    );
  }
}
