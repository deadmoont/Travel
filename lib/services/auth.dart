import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get current user's data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // SignUp User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Add user to Firestore database
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
        });

        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // Method to upload profile image
  Future<void> uploadProfileImage(File image) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child(_auth.currentUser!.uid + '.jpg');
      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();

      // Update Firestore with the image URL
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print(e);
    }
  }

  // Method to update user profile
  Future<void> updateUserProfile(Map<String, dynamic> userProfile) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update(userProfile);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // LogIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // SignOut
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
