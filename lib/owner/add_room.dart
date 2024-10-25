import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'room_service.dart'; // Import your actual RoomService

class AddRoomScreen extends StatefulWidget {
  final String ownerId;

  AddRoomScreen({Key? key, required this.ownerId}) : super(key: key);

  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<Uint8List> _webSelectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // New field for availability
  bool _isAvailable = true; // Default to available

  Future<void> _pickImages() async {
    final pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _selectedImages.addAll(pickedImages);
      });

      if (kIsWeb) {
        for (var image in pickedImages) {
          Uint8List imageBytes = await image.readAsBytes();
          _webSelectedImages.add(imageBytes);
        }
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('rooms/${image.path.split('/').last}');
    UploadTask uploadTask = storageRef.putFile(image);

    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        _uploadProgress = event.bytesTransferred / event.totalBytes;
      });
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> _uploadImageWeb(Uint8List imageBytes, String imageName) async {
    final storageRef = FirebaseStorage.instance.ref().child('rooms/$imageName');
    UploadTask uploadTask = storageRef.putData(imageBytes);

    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        _uploadProgress = event.bytesTransferred / event.totalBytes;
      });
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Uploading room data...'),
          ],
        ),
      ),
    );

    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      String imageUrl = kIsWeb
          ? await _uploadImageWeb(await image.readAsBytes(), image.name)
          : await _uploadImage(File(image.path));
      imageUrls.add(imageUrl);
    }

    await RoomService().addRoom({
      'type': _typeController.text,
      'location': _locationController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'contact': _contactController.text,
      'description': _descriptionController.text,
      'images': imageUrls,
      'ownerId': widget.ownerId,
      'isAvailable': _isAvailable, // Save isAvailable status
    });

    Navigator.pop(context);
    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room added successfully!')),
    );

    _clearForm();
  }

  void _clearForm() {
    _typeController.clear();
    _locationController.clear();
    _priceController.clear();
    _contactController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImages.clear();
      _webSelectedImages.clear();
      _isAvailable = true; // Reset to available
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (kIsWeb) _webSelectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room'),
        backgroundColor: const Color(0xFFFF595E), // poppy red
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Add a New Room',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC300), // sunflower yellow
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _typeController,
                label: 'Room Type',
                icon: Icons.meeting_room_outlined,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _priceController,
                label: 'Price (KES)',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _contactController,
                label: 'Contact Info',
                icon: Icons.contact_phone_outlined,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Checkbox for room availability
              Row(
                children: [
                  Checkbox(
                    value: _isAvailable,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAvailable = value ?? true;
                      });
                    },
                  ),
                  const Text(
                    'Is Available',
                    style: TextStyle(
                      color: Color(0xFFFFA85C), // ginger peach
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildImagePreview(),
              const SizedBox(height: 10),
              _buildImagePickerButton(),
              const SizedBox(height: 20),
              if (_isUploading) LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _saveRoom,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF595E), // poppy red
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Save Room',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFC300), // sunflower yellow
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFFFA85C)), // ginger peach
        prefixIcon: Icon(icon, color: const Color(0xFFFF595E)), // poppy red
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildImagePreview() {
    return _selectedImages.isNotEmpty || _webSelectedImages.isNotEmpty
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  kIsWeb ? _webSelectedImages.length : _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    kIsWeb
                        ? Image.memory(
                            _webSelectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_selectedImages[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : const Text('No images selected');
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton.icon(
      onPressed: _pickImages,
      icon: const Icon(Icons.photo_library_outlined),
      label: const Text('Pick Images'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA85C), // ginger peach
      ),
    );
  }
}
