import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_escape_airbnbs/guest/guest_home.dart';
import 'package:urban_escape_airbnbs/login_screen.dart';
import 'package:urban_escape_airbnbs/models/models.dart';
import 'package:urban_escape_airbnbs/owner/owner_home.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Executive Airbnbs",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Menu action
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(context),

            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: _buildSearchBar(),
            ),

            // Categories Section (Popular destinations)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                "Popular Destinations",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
            ),
            _buildCategoriesSection(),

            // Featured Listings (Fetched from Firestore)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: const Text(
                "Featured Listings",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
            ),
            _buildFeaturedListings(context),
          ],
        ),
      ),
    );
  }

  // Hero Section
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        color: Color(0xFFEE6352), // Poppy Red
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Escape to the Best Stays",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Find your perfect room anywhere",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFF28C28), // Sunflower
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                // Check if the user is logged in
                if (currentUser == null) {
                  // Redirect to login/signup
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                } else {
                  final guestId = await _isGuest();
                  if (!mounted) return; // Add mounted check

                  if (guestId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GuestRoomSearch(guestId: guestId), // Pass guestId
                      ),
                    );
                  } else {
                    final isOwner = await _isOwner();
                    if (!mounted) return; // Add mounted check

                    if (isOwner) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerDashboard(
                              ownerId: currentUser!.uid), // Pass ownerId
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text(
                "Start Exploring",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search for rooms or locations...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.0),
          prefixIcon: Icon(Icons.search, color: Colors.teal),
        ),
      ),
    );
  }

  // Categories Section
  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCategoryCard(
                "Beachside", "assets/beach.jpg", const Color(0xFFFFE156)),
            _buildCategoryCard(
                "Mountain", "assets/mountain.jpg", const Color(0xFFF28C28)),
            _buildCategoryCard(
                "City", "assets/city.jpg", const Color(0xFFEE6352)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Fetch Featured Listings from Firestore using Room model
  Widget _buildFeaturedListings(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching data"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = snapshot.data!.docs
            .map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Room.fromMap(data, doc.id);
            })
            .where((room) => room.isAvailable)
            .toList(); // Only show available rooms

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildRoomCard(context, room.images[0], room.location,
                room.price.toString(), room.id);
          },
        );
      },
    );
  }

  // Room card builder with Room model data
  Widget _buildRoomCard(BuildContext context, String imageUrl, String location,
      String price, String roomId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ksh $price per night",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFF28C28), // Sunflower
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    // Check if the user is logged in
                    if (currentUser == null) {
                      // Redirect to login/signup
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    } else {
                      // Proceed to booking logic
                      final guestId = await _isGuest();
                      if (!mounted) return; // Add mounted check

                      if (guestId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                                guestId: guestId,
                                roomId: roomId), // Pass guestId and roomId
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Book Now"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Check if user is a guest
  Future<String?> _isGuest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final guestDoc = await FirebaseFirestore.instance
          .collection('guests')
          .doc(user.uid)
          .get();
      if (guestDoc.exists) {
        return user.uid;
      }
    }
    return null;
  }

  // Check if user is an owner
  Future<bool> _isOwner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ownerDoc = await FirebaseFirestore.instance
          .collection('owners')
          .doc(user.uid)
          .get();
      return ownerDoc.exists;
    }
    return false;
  }
}
