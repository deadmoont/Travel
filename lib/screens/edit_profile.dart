import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image; // To store the selected image
  final AuthServices _authServices = AuthServices(); // Instance of AuthServices
  Map<String, dynamic>? _userData; // To store user data
  bool _isLoading = true; // To manage loading state
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  String? _name; // Editable field for name
  String? _email; // Editable field for email
  String? _address; // Editable field for permanent address
  String? _mobile; // Editable field for mobile number
  String? _profileImage; // URL for the profile image in Firebase Storage

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Method to load user data from Firestore
  Future<void> _loadUserData() async {
    _userData = await _authServices.getUserData();
    setState(() {
      _name = _userData?['name'];
      _email = _userData?['email'];
      _address = _userData?['address'] ?? '';
      _mobile = _userData?['mobile'] ?? '';
      _profileImage = _userData?['profileImage']; // Fetch profile image URL
      _isLoading = false; // Stop loading after user data is loaded
    });
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Save profile image only if one is picked (optional)
  Future<void> _saveProfileImage() async {
    if (_image != null) {
      try {
        // Fetch current user ID
        String? userId = _authServices.getCurrentUserId();
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in!')),
          );
          return;
        }

        // Define storage reference for the profile image
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images/$userId.jpg');

        // Upload the file to Firebase Storage
        UploadTask uploadTask = storageReference.putFile(_image!);

        // Await task completion and get the download URL
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update Firestore with the image URL
        await _authServices.updateUserProfile({'profileImage': downloadUrl});

        // Update local profile image URL
        setState(() {
          _profileImage = downloadUrl;
        });
      } catch (e) {
        print('Error saving profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  // Method to save profile information to Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form data
      Map<String, dynamic> updatedProfile = {
        'name': _name,
        'email': _email,
        'address': _address,
        'mobile': _mobile,
      };

      // If profile image is updated, save it as well
      await _saveProfileImage();

      // Save the updated profile to Firestore
      try {
        await _authServices.updateUserProfile(updatedProfile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300], // Grey border around image
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: _image != null
                            ? FileImage(_image!) // Show selected image
                            : _profileImage != null
                            ? NetworkImage(_profileImage!)
                            : const AssetImage('assets/default_user.png') as ImageProvider, // Default image if none selected
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage, // Allow user to tap and select an image
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueAccent, // Edit button style
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Name field
                _buildProfileField(
                  label: 'Name',
                  initialValue: _name,
                  icon: Icons.person,
                  onSaved: (value) => _name = value,
                ),
                const SizedBox(height: 10),
                // Email field
                _buildProfileField(
                  label: 'Email',
                  initialValue: _email,
                  icon: Icons.email,
                  onSaved: (value) => _email = value,
                ),
                const SizedBox(height: 10),
                // Address field
                _buildProfileField(
                  label: 'Permanent Address',
                  initialValue: _address,
                  icon: Icons.location_on,
                  onSaved: (value) => _address = value,
                ),
                const SizedBox(height: 10),
                // Mobile number field
                _buildProfileField(
                  label: 'Mobile Number',
                  initialValue: _mobile,
                  icon: Icons.phone,
                  onSaved: (value) => _mobile = value,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                // Save Profile Button
                ElevatedButton(
                  onPressed: (){
                      _saveProfileImage();
                      _saveProfile(); // Call _saveProfile when pressed
                  },
                    child: const Text('Save Profile')
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build profile fields with consistent styling
  Widget _buildProfileField({
    required String label,
    required String? initialValue,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
}
