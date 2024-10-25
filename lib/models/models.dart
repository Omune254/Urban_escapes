import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Convert Firestore document to AppUser model
  factory AppUser.fromFirestore(Map<String, dynamic> data, String userId) {
    return AppUser(
      id: userId,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role:
          data['role'] ?? 'Guest', // Default to Guest if role is not specified
    );
  }

  // Convert AppUser model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

class Room {
  String id;
  String type;
  String description;
  String location;
  String contact;
  double price; // Treat price as a double
  List<String> images;
  bool isAvailable; // Add isAvailable field

  Room({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.contact,
    required this.price, // Ensure price is a number
    required this.images,
    required this.isAvailable, // Initialize isAvailable field
  });

  // Factory method to create a Room object from Firestore data
  factory Room.fromMap(Map<String, dynamic> data, String documentId) {
    return Room(
      id: documentId,
      type: data['type'] as String,
      description: data['description'] as String,
      location: data['location'] as String,
      contact: data['contact'].toString(), // Convert contact to string
      price: data['price'] is int
          ? (data['price'] as int).toDouble()
          : data['price'], // Ensure price is double
      images: List<String>.from(
          data['images'] ?? []), // Ensure images is a list of strings
      isAvailable: data['isAvailable'] as bool? ?? false, // Handle isAvailable
    );
  }

  // Convert the Room object back to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'location': location,
      'contact': contact,
      'price': price,
      'images': images,
      'isAvailable': isAvailable, // Add isAvailable to the JSON
    };
  }
}

class Booking {
  final String id; // Booking document ID
  final String roomId; // The ID of the booked room
  final String guestId; // ID of the guest making the booking
  final String guestName; // Name of the guest
  final String guestPhone; // Phone number of the guest
  final String guestEmail; // Email of the guest
  final String checkIn; // Check-in date
  final String checkOut; // Check-out date

  Booking({
    required this.id,
    required this.roomId,
    required this.guestId, // Added guestId
    required this.guestName,
    required this.guestPhone,
    required this.guestEmail,
    required this.checkIn,
    required this.checkOut,
  });

  // Method to create a Booking object from Firestore data
  factory Booking.fromMap(Map<String, dynamic> data, String documentId) {
    return Booking(
      id: documentId,
      roomId: data['roomId'] ?? '',
      guestId: data['guestId'] ?? '', // Ensure guestId is included
      guestName: data['guestName'] ?? '',
      guestPhone: data['guestPhone'] ?? '',
      guestEmail: data['guestEmail'] ?? '',
      checkIn: data['checkIn'] ?? '',
      checkOut: data['checkOut'] ?? '',
    );
  }

  // Convert a Booking object to a map, useful for adding/updating Firestore documents
  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'guestId': guestId, // Include guestId in the map
      'guestName': guestName,
      'guestPhone': guestPhone,
      'guestEmail': guestEmail,
      'checkIn': checkIn,
      'checkOut': checkOut,
    };
  }
}
