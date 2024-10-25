import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:urban_escape_airbnbs/owner/owner_home.dart';
import 'package:urban_escape_airbnbs/guest/guest_home.dart';
import 'package:urban_escape_airbnbs/login_screen.dart';
import 'package:urban_escape_airbnbs/owner/add_room.dart';
import 'package:urban_escape_airbnbs/owner/bookings.dart';
import 'package:urban_escape_airbnbs/owner/home_page.dart';
import 'package:urban_escape_airbnbs/owner/manage_rooms.dart';
import 'package:urban_escape_airbnbs/guest/book_screen.dart'
    as guest_booking; // Use a prefix for the BookingScreen import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Escape Airbnbs',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: Colors.amber,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/owner_home': (context) {
          final ownerId =
              ModalRoute.of(context)?.settings.arguments as String? ??
                  'defaultOwnerId';
          return OwnerDashboard(ownerId: ownerId);
        },
        '/guest_room_search': (context) {
          final guestId =
              ModalRoute.of(context)?.settings.arguments as String? ??
                  'defaultGuestId'; // Get guestId
          return GuestRoomSearch(guestId: guestId); // Pass guestId here
        },
        '/add_room': (context) {
          final ownerId =
              ModalRoute.of(context)?.settings.arguments as String? ??
                  'defaultOwnerId';
          return AddRoomScreen(ownerId: ownerId);
        },
        '/manage_rooms': (context) {
          final ownerId =
              ModalRoute.of(context)?.settings.arguments as String? ??
                  'defaultOwnerId';
          return ManageRoomsScreen(ownerId: ownerId);
        },
        '/guest_booking': (context) {
          final roomDetails = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          return guest_booking.BookingScreen(
            roomId: roomDetails?['roomId'] ?? '',
            guestId: roomDetails?['guestId'] ?? '', // Pass guestId parameter
          );
        },
        '/owner_bookings': (context) {
          final ownerId =
              ModalRoute.of(context)?.settings.arguments as String? ??
                  'defaultOwnerId';
          return OwnerBookingsScreen(ownerId: ownerId);
        },
      },
    );
  }
}
