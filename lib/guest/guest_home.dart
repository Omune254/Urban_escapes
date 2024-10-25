import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Define the colors from the image
const Color poppyRed = Color(0xFFFF4500); // Poppy red
const Color gingerPeach = Color(0xFFFFA07A); // Ginger peach
const Color sunflower = Color(0xFFFFD700); // Sunflower

class GuestRoomSearch extends StatefulWidget {
  final String guestId; // Update parameter name

  GuestRoomSearch({Key? key, required this.guestId})
      : super(key: key); // Constructor to receive guestId

  @override
  _GuestRoomSearchState createState() => _GuestRoomSearchState();
}

class _GuestRoomSearchState extends State<GuestRoomSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Rooms"),
        backgroundColor: poppyRed, // Apply poppy red color
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _navigateToBookingsScreen(); // Navigate to bookings screen
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildRoomList(context)),
          ],
        ),
      ),
    );
  }

  // Modernized Search Bar
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by location...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.search, color: poppyRed), // Poppy red
        contentPadding: const EdgeInsets.all(10),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim();
        });
      },
    );
  }

  // Room List Builder
  Widget _buildRoomList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getAvailableRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No rooms available",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        var rooms = snapshot.data!.docs.where((room) {
          var roomData = room.data() as Map<String, dynamic>;
          return roomData['location']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            var room = rooms[index];
            var roomData = room.data() as Map<String, dynamic>;
            var roomImageUrl =
                roomData['images'][0] ?? 'https://placeimg.com/640/480/room';
            var roomLocation = roomData['location'] ?? 'Unknown Location';
            var roomPrice = roomData['price']?.toString() ?? 'N/A';
            var roomContact = roomData['contact'] ?? 'No Contact';

            return _buildRoomCard(
              roomImageUrl,
              roomLocation,
              roomPrice,
              room.id,
              roomContact,
              roomData['type'],
              roomData['description'],
            );
          },
        );
      },
    );
  }

  // Modernized Room Card Design
  Widget _buildRoomCard(
    String imageUrl,
    String location,
    String price,
    String roomId,
    String contact,
    String type,
    String description,
  ) {
    return GestureDetector(
      onTap: () => _showRoomDetails(
          imageUrl, location, price, contact, roomId, type, description),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                location,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: gingerPeach, // Ginger peach
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Ksh $price per night',
                style: TextStyle(
                  color: sunflower, // Sunflower
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: ElevatedButton(
                onPressed: () {
                  _navigateToBookingScreen(
                      roomId, location, price, contact, type, description);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: poppyRed, // Poppy red
                ),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to BookingScreen with room details
  void _navigateToBookingScreen(String roomId, String location, String price,
      String contact, String type, String description) {
    Navigator.pushNamed(
      context,
      '/guest_booking', // Ensure this matches the route name in MyApp
      arguments: {
        'roomId': roomId,
        'location': location,
        'price': price,
        'contact': contact,
        'type': type,
        'description': description,
        'guestId': widget.guestId, // Pass guestId to BookingScreen
      },
    );
  }

  // Navigate to GuestBookingsScreen
  void _navigateToBookingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestBookingsScreen(guestId: widget.guestId),
      ),
    );
  }

  // Display Room Details
  void _showRoomDetails(String imageUrl, String location, String price,
      String contact, String roomId, String type, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(location),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl),
              const SizedBox(height: 10),
              Text('Price: Ksh $price per night',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Contact Owner: $contact',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Type: $type', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Description: $description',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Firestore Query for Available Rooms
  Stream<QuerySnapshot> getAvailableRooms() {
    return FirebaseFirestore.instance
        .collection('rooms')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// BookingScreen Example
class BookingScreen extends StatelessWidget {
  final String guestId; // Update parameter name

  BookingScreen({Key? key, required this.guestId, required String roomId})
      : super(key: key); // Constructor to receive guestId

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> roomDetails =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: poppyRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room Type: ${roomDetails['type']}',
                style: const TextStyle(fontSize: 20)),
            Text('Location: ${roomDetails['location']}',
                style: const TextStyle(fontSize: 18)),
            Text('Price: ${roomDetails['price']}',
                style: const TextStyle(fontSize: 18)),
            Text('Contact: ${roomDetails['contact']}',
                style: const TextStyle(fontSize: 18)),
            Text('Description: ${roomDetails['description']}',
                style: const TextStyle(fontSize: 18)),
            // Booking form fields
          ],
        ),
      ),
    );
  }
}

// New GuestBookingsScreen
class GuestBookingsScreen extends StatelessWidget {
  final String guestId; // Update parameter name

  GuestBookingsScreen({Key? key, required this.guestId})
      : super(key: key); // Constructor to receive guestId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: poppyRed, // Apply poppy red color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('guestId', isEqualTo: guestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var bookingData = bookings[index].data() as Map<String, dynamic>;
              var roomLocation = bookingData['location'] ?? 'Unknown Location';
              var checkInDate = bookingData['checkInDate'] ?? 'N/A';
              var checkOutDate = bookingData['checkOutDate'] ?? 'N/A';

              return ListTile(
                title: Text(roomLocation),
                subtitle:
                    Text('Check-in: $checkInDate\nCheck-out: $checkOutDate'),
                leading: const Icon(Icons.hotel),
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          );
        },
      ),
    );
  }
}
