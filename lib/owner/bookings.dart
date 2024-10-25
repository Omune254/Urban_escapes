import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_escape_airbnbs/models/models.dart';

// Color Scheme
const Color poppyRed = Color(0xFFD32F2F);
const Color gingerPeach = Color(0xFFFFB74D);
const Color sunflower = Color(0xFFFFEB3B);

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({Key? key, required String ownerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extracting the ownerId passed as an argument
    final String ownerId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: poppyRed, // Updated AppBar color
      ),
      body: StreamBuilder<List<BookingWithRoomDetails>>(
        stream: _getOwnerBookingsStream(ownerId), // Pass ownerId to fetch bookings
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final bookingWithRoom = bookings[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shadowColor: gingerPeach,
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    '${bookingWithRoom.booking.guestName} (${bookingWithRoom.booking.guestPhone})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      _buildRoomDetailRow(
                        label: 'Room Type:',
                        value: bookingWithRoom.room.type,
                      ),
                      _buildRoomDetailRow(
                        label: 'Description:',
                        value: bookingWithRoom.room.description,
                      ),
                      _buildRoomDetailRow(
                        label: 'Price:',
                        value: '\$${bookingWithRoom.room.price}',
                      ),
                      _buildRoomDetailRow(
                        label: 'Check-in:',
                        value: bookingWithRoom.booking.checkIn,
                      ),
                      _buildRoomDetailRow(
                        label: 'Check-out:',
                        value: bookingWithRoom.booking.checkOut,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: poppyRed),
                    onPressed: () {
                      _confirmDeleteBooking(context, bookingWithRoom.booking.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to build room detail rows with consistent styling
  Widget _buildRoomDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: gingerPeach,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  // Function to get a stream of bookings for the owner's rooms
  Stream<List<BookingWithRoomDetails>> _getOwnerBookingsStream(String ownerId) async* {
    // Fetch room IDs owned by the owner
    final roomDocs = await FirebaseFirestore.instance
        .collection('rooms')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    // Extract room IDs from the fetched room documents
    final roomIds = roomDocs.docs.map((doc) => doc.id).toList();

    // If there are no rooms, yield an empty list
    if (roomIds.isEmpty) {
      yield [];
      return;
    }

    // Listen to the bookings collection, filtering by room IDs
    yield* FirebaseFirestore.instance
        .collection('bookings')
        .where('roomId', whereIn: roomIds) // Fetch bookings for the owner's rooms
        .snapshots()
        .asyncMap((snapshot) async {
      final bookings = snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Fetch room details for each booking
      final roomDetailsFutures = bookings.map((booking) async {
        final roomDoc = await FirebaseFirestore.instance
            .collection('rooms')
            .doc(booking.roomId)
            .get();

        final room = Room.fromMap(roomDoc.data() as Map<String, dynamic>, roomDoc.id);
        return BookingWithRoomDetails(booking: booking, room: room);
      });

      return await Future.wait(roomDetailsFutures);
    });
  }

  // Function to show a confirmation dialog before deleting a booking
  void _confirmDeleteBooking(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Booking'),
          content: const Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: poppyRed)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBooking(context, bookingId);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete a booking from Firestore
  Future<void> _deleteBooking(BuildContext context, String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking deleted successfully'),
          backgroundColor: sunflower, // Success message color
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete booking: $error'),
          backgroundColor: poppyRed, // Error message color
        ),
      );
    }
  }
}

// Define a class to hold booking and room details
class BookingWithRoomDetails {
  final Booking booking;
  final Room room;

  BookingWithRoomDetails({required this.booking, required this.room});
}
