import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedRole = 'Guest';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false; // Track loading state

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define the color palette
  final Color poppyRed = Color(0xFFE74C3C);
  final Color gingerPeach = Color(0xFFFFA07A);
  final Color sunflowerYellow = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Create Account"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: gingerPeach,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Create Account',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: poppyRed,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildFullNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildRoleSelector(),
          const SizedBox(height: 30),
          _buildCreateAccountButton(),
        ],
      ),
    );
  }

  TextFormField _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: _inputDecoration('Full Name', Icons.person),
      validator: (value) {
        if (value!.isEmpty) return 'Please enter your full name';
        return null;
      },
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration('Email', Icons.email),
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: _inputDecorationWithToggle(
        'Password',
        Icons.lock,
        _passwordVisible,
        () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
      ),
      validator: (value) {
        if (value!.isEmpty || value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_confirmPasswordVisible,
      decoration: _inputDecorationWithToggle(
        'Confirm Password',
        Icons.lock,
        _confirmPasswordVisible,
        () {
          setState(() {
            _confirmPasswordVisible = !_confirmPasswordVisible;
          });
        },
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  TextFormField _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration('Phone Number', Icons.phone),
      validator: (value) {
        if (value!.isEmpty || value.length != 10) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Register as:", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedRole,
          dropdownColor: Colors.white,
          items: ['Guest', 'Owner'].map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
      ],
    );
  }

  ElevatedButton _buildCreateAccountButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: sunflowerYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0),
      ),
      onPressed: _isLoading ? null : _handleCreateAccount,
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Create Account',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: poppyRed),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  InputDecoration _inputDecorationWithToggle(
    String label,
    IconData icon,
    bool isVisible,
    VoidCallback onToggle,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: poppyRed),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: gingerPeach,
        ),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _handleCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        AppUser newUser = AppUser(
          id: userCredential.user!.uid,
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          role: _selectedRole,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully!")),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
