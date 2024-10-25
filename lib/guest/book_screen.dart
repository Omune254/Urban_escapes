import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatelessWidget {
  final String roomId;
  final String guestId; // Changed userId to guestId

  BookingScreen({required this.roomId, required this.guestId}); // Constructor

  @override
  Widget build(BuildContext context) {
    return BookingForm(
      roomId: roomId,
      guestId: guestId, // Pass the guestId to the BookingForm widget
    );
  }
}

class BookingForm extends StatefulWidget {
  final String roomId;
  final String guestId; // Changed userId to guestId

  BookingForm({required this.roomId, required this.guestId}); // Constructor

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialRequestController =
      TextEditingController();
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(Duration(days: 1));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Room ${widget.roomId}"),
        backgroundColor: Color(0xFFFF4500), // Poppy red
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4500), // Poppy red
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Full Name Input
                  _buildTextInputField(
                    label: 'Full Name',
                    controller: _fullNameController,
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Phone Number Input
                  _buildTextInputField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty || value.length != 10) {
                        return 'Enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Email Input
                  _buildTextInputField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Check-in Date Picker
                  _buildDatePickerField(
                    label: 'Check-in Date',
                    selectedDate: _checkInDate,
                    onSelectDate: _selectCheckInDate,
                  ),
                  SizedBox(height: 20),
                  // Check-out Date Picker
                  _buildDatePickerField(
                    label: 'Check-out Date',
                    selectedDate: _checkOutDate,
                    onSelectDate: _selectCheckOutDate,
                  ),
                  SizedBox(height: 20),
                  // Special Requests Input
                  _buildTextInputField(
                    label: 'Special Requests (Optional)',
                    controller: _specialRequestController,
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFFF4500), // Poppy red
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitBooking();
                      }
                    },
                    child: Text(
                      'Submit and Book through WhatsApp',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // Custom Input Field Builder
  Widget _buildTextInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  // Date Picker Field Builder
  Widget _buildDatePickerField({
    required String label,
    required DateTime selectedDate,
    required VoidCallback onSelectDate,
  }) {
    return ListTile(
      title: Text('$label: ${selectedDate.toLocal()}'.split(' ')[0]),
      trailing: Icon(Icons.calendar_today),
      onTap: onSelectDate,
    );
  }

  // Select Check-in Date
  void _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
      });
    }
  }

  // Select Check-out Date
  void _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate
          .add(Duration(days: 1)), // Check-out must be after check-in
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  // Handle Booking Submission
  void _submitBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user's ID
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // Check if user is logged in
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You need to be logged in to book a room.")),
        );
        return;
      }

      // Update the room availability in Firestore
      await FirebaseFirestore.instance
          .collection('rooms') // Replace 'rooms' with your collection name
          .doc(widget.roomId) // Use the roomId to update the correct room
          .update({'isAvailable': false});

      // Save the booking details to Firestore
      await FirebaseFirestore.instance.collection('bookings').add({
        'roomId': widget.roomId,
        'guestId': widget.guestId, // Use the guestId passed to BookingForm
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
        'specialRequests': _specialRequestController.text,
      });

      // Fetch the room contact number from Firestore based on roomId
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .get();

      String contact = roomDoc['contact']; // Assuming the contact field exists

      // After saving booking details, open WhatsApp to contact the owner
      await _bookRoomThroughWhatsApp(contact);

      // Show confirmation dialog after submission
      _showDialog('Booking Successful',
          'Your booking for Room ${widget.roomId} has been confirmed!');
    } catch (error) {
      // Handle Firestore update error
      _showDialog('Booking Failed',
          'Failed to update room availability. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // WhatsApp Booking Function
  Future<void> _bookRoomThroughWhatsApp(String contact) async {
    final whatsappUrl =
        'https://wa.me/$contact?text=I%20would%20like%20to%20book%20your%20room%20${widget.roomId}%20from%20${_checkInDate.toLocal()}%20to%20${_checkOutDate.toLocal()}.%20Name:%20${_fullNameController.text}%20Phone:%20${_phoneController.text}';
    await launch(whatsappUrl);
  }

  // Show Dialog Function
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the BookingScreen
              },
            ),
          ],
        );
      },
    );
  }
}
