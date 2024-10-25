import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a room and return the document ID
  Future<String> addRoom(Map<String, dynamic> roomData) async {
    final docRef = await _firestore.collection('rooms').add(roomData);
    return docRef.id;
  }

  // Get rooms by ownerId
  Future<List<Map<String, dynamic>>> getRooms(String ownerId) async {
    final snapshot = await _firestore
        .collection('rooms')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get room by roomId
  Future<Map<String, dynamic>?> getRoomById(String roomId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Update room details by roomId
  Future<void> updateRoom(
      String roomId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('rooms').doc(roomId).update(updatedData);
  }

  // Delete room by roomId
  Future<void> deleteRoom(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).delete();
  }
}
