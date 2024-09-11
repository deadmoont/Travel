import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth.dart';

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
      _address = _userData?['address'] ?? ''; // Handle missing fields
      _mobile = _userData?['mobile'] ?? ''; // Handle missing fields
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

  // Method to save profile image using AuthServices
  Future<void> _saveProfileImage() async {
    if (_image != null) {
      await _authServices.uploadProfileImage(_image!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Image Updated!')),
      );
      // Reload user data after profile image update
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image!')),
      );
    }
  }

  // Method to save user profile information
  Future<void> _saveProfileInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _authServices.updateUserProfile({
        'name': _name,
        'email': _email,
        'address': _address,
        'mobile': _mobile,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!) // Show selected image
                          : _userData?['profileImageUrl'] != null
                          ? NetworkImage(_userData!['profileImageUrl'])
                          : null,
                      child: _image == null && _userData?['profileImageUrl'] == null
                          ? const Icon(Icons.add_a_photo, size: 50)
                          : null, // Show default icon if no image selected
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage, // Allow user to tap and select an image
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Name field
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (newValue) {
                    _name = newValue;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Email field
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSaved: (newValue) {
                    _email = newValue;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Address field
                TextFormField(
                  initialValue: _address,
                  decoration: const InputDecoration(labelText: 'Permanent Address'),
                  onSaved: (newValue) {
                    _address = newValue;
                  },
                ),
                const SizedBox(height: 10),
                // Mobile number field
                TextFormField(
                  initialValue: _mobile,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                  onSaved: (newValue) {
                    _mobile = newValue;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _saveProfileImage(); // Save profile image
                    _saveProfileInfo(); // Save user info
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
