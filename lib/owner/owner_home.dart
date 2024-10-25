import 'package:flutter/material.dart';
import 'add_room.dart';
import 'bookings.dart';
import 'manage_rooms.dart'; // Import ManageRoomsScreen

class OwnerDashboard extends StatelessWidget {
  final String ownerId; // Owner ID as a String

  OwnerDashboard({required this.ownerId}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        title: const Text('Owner Dashboard', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.orange[300], // Ginger Peach color
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open a side drawer if needed
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items to start
            children: [
              _buildWelcomeCard(), // Top welcome card section
              const SizedBox(height: 20),
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 10),
              _buildActionGrid(context), // Grid layout for actions
              const SizedBox(height: 30),
              _buildSectionTitle('Overview'),
              const SizedBox(height: 10),
              _buildOverviewSection(), // Overview cards section
            ],
          ),
        ),
      ),
    );
  }

  /// Welcome section with a card and owner ID display.
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFFF6347), // Poppy Red color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Icon(Icons.person, size: 30, color: Colors.black54),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome, Owner!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your ID: $ownerId",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section title with padding and bold text.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Grid layout for action buttons using cards for better visual appeal.
  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true, // Allows grid to fit inside a column
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics:
          const NeverScrollableScrollPhysics(), // Prevent grid from scrolling
      children: [
        _buildDashboardCard(
          context,
          label: 'Add Room',
          icon: Icons.add_business,
          routeName: '/add_room',
          ownerId: ownerId,
          color: const Color(0xFFF5AB99), // Ginger Peach color
        ),
        _buildDashboardCard(
          context,
          label: 'Manage Rooms',
          icon: Icons.manage_accounts,
          routeName: '/manage_rooms',
          ownerId: ownerId,
          color: const Color(0xFFFF6347), // Poppy Red color
        ),
        _buildDashboardCard(
          context,
          label: 'View Bookings',
          icon: Icons.list_alt,
          routeName: '/owner_bookings',
          ownerId: ownerId,
          color: const Color(0xFFFFD700), // Sunflower Yellow color
        ),
      ],
    );
  }

  /// Builds a card-style dashboard action with icon and label.
  Widget _buildDashboardCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String routeName,
    String? ownerId,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (ownerId != null && routeName == '/add_room') {
          Navigator.pushNamed(context, routeName, arguments: ownerId);
        } else if (ownerId != null && routeName == '/manage_rooms') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageRoomsScreen(ownerId: ownerId),
            ),
          );
        } else if (ownerId != null && routeName == '/owner_bookings') {
          Navigator.pushNamed(context, routeName, arguments: ownerId);
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overview section showing cards with key metrics (e.g., bookings, rooms).
  Widget _buildOverviewSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOverviewCard('Rooms', '12', Icons.meeting_room),
        _buildOverviewCard('Bookings', '24', Icons.book_online),
      ],
    );
  }

  /// Builds an overview card with a metric label and value.
  Widget _buildOverviewCard(String label, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.orange[300]),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
