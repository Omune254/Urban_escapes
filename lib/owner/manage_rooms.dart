import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_escape_airbnbs/models/models.dart';

class ManageRoomsScreen extends StatelessWidget {
  final String ownerId;

  // Define the colors from the provided scheme
  final Color poppyRed = Color(0xFFFF4B3E); // Poppy Red
  final Color gingerPeach = Color(0xFFFFAC81); // Ginger Peach
  final Color sunflower = Color(0xFFFFD166); // Sunflower

  ManageRoomsScreen({Key? key, required this.ownerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean background
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        centerTitle: true,
        backgroundColor: poppyRed, // Use poppy red for the AppBar
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Logic to add new room
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Your Rooms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: sunflower, // Sunflower color for headings
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .where('ownerId', isEqualTo: ownerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final rooms = snapshot.data?.docs ?? [];

                  if (rooms.isEmpty) {
                    return const Center(
                      child: Text(
                        'No rooms added yet.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final roomList = rooms.map((doc) {
                    return Room.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  return ListView.builder(
                    itemCount: roomList.length,
                    itemBuilder: (context, index) {
                      final room = roomList[index];

                      return Card(
                        color: gingerPeach.withOpacity(
                            0.2), // Ginger Peach background for cards
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            room.type,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: poppyRed, // Poppy Red for the title
                            ),
                          ),
                          subtitle: Text(
                            room.description.isNotEmpty
                                ? room.description
                                : 'No description',
                            style: TextStyle(color: Colors.black54),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: sunflower, // Sunflower for edit icon
                                onPressed: () {
                                  _showEditDialog(context, room.id, room);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: poppyRed, // Poppy Red for delete icon
                                onPressed: () {
                                  _confirmDeleteRoom(context, room.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show a confirmation dialog before deleting a room
  void _confirmDeleteRoom(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Room'),
          content: const Text('Are you sure you want to delete this room?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRoom(context, roomId);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete a room from Firestore
  Future<void> _deleteRoom(BuildContext context, String roomId) async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Room deleted successfully'),
          backgroundColor: sunflower, // Sunflower background for snackbar
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete room: $error'),
          backgroundColor: poppyRed, // Error messages in Poppy Red
        ),
      );
    }
  }

  // Function to show an edit dialog
  void _showEditDialog(BuildContext context, String roomId, Room room) {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        String? roomType = room.type;
        String? roomDescription = room.description;
        String? roomLocation = room.location;
        String? roomContact = room.contact;
        String? roomPrice =
            room.price.toString(); // Convert price to string for form field
        bool isAvailable = room.isAvailable;

        return AlertDialog(
          title: const Text('Edit Room'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: roomType,
                    decoration: const InputDecoration(labelText: 'Room Type'),
                    onSaved: (value) => roomType = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter room type'
                        : null,
                  ),
                  TextFormField(
                    initialValue: roomDescription,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => roomDescription = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter description'
                        : null,
                  ),
                  TextFormField(
                    initialValue: roomLocation,
                    decoration: const InputDecoration(labelText: 'Location'),
                    onSaved: (value) => roomLocation = value,
                  ),
                  TextFormField(
                    initialValue: roomPrice,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number, // Ensure numeric input
                    onSaved: (value) => roomPrice = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: roomContact,
                    decoration: const InputDecoration(labelText: 'Contact'),
                    onSaved: (value) => roomContact = value,
                  ),
                  SwitchListTile(
                    activeColor: poppyRed, // Use poppy red for switch toggle
                    title: const Text('Available'),
                    value: isAvailable,
                    onChanged: (value) {
                      isAvailable = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _updateRoom(context, roomId, roomType, roomDescription,
                      roomLocation, roomPrice, roomContact, isAvailable);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Update the room details in Firestore
  Future<void> _updateRoom(
      BuildContext context,
      String roomId,
      String? roomType,
      String? roomDescription,
      String? roomLocation,
      String? roomPrice,
      String? roomContact,
      bool isAvailable) async {
    try {
      double? price = double.tryParse(roomPrice!); // Convert price to double

      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'type': roomType,
        'description': roomDescription,
        'location': roomLocation,
        'price': price, // Use double price
        'contact': roomContact,
        'isAvailable': isAvailable,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Room updated successfully'),
          backgroundColor: sunflower, // Success messages in Sunflower
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update room: $error'),
          backgroundColor: poppyRed, // Error messages in Poppy Red
        ),
      );
    }
  }
}
