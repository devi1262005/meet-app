import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  User? currentUser;
  String username = '';
  String profilePicUrl = '';
  String status = 'Available';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
        setState(() {
          username = currentUser!.displayName ?? userDoc.data()?['username'] ?? 'No Username';
          profilePicUrl = currentUser!.photoURL ?? userDoc.data()?['profilePicUrl'] ?? '';
          status = userDoc.data()?['status'] ?? 'Available';
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);
      
      // Upload image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${currentUser!.uid}.jpg');
      
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();

      // Update Firebase Auth profile
      await currentUser!.updatePhotoURL(downloadUrl);
      
      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'profilePicUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        profilePicUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile photo updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile photo: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUsername(String newUsername) async {
    if (newUsername.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      // Update Firebase Auth profile
      await currentUser!.updateDisplayName(newUsername);
      
      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'username': newUsername,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        username = newUsername;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update username: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        status = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editField(String field, String currentValue, ValueChanged<String> onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : AssetImage('assets/img/profile.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _updateProfilePhoto,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.purple.shade800,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                username,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                currentUser?.email ?? 'No Email',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),

            // Personal Details Section
            Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            ListTile(
              title: Text('Username'),
              subtitle: Text(username),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editField('Username', username, _updateUsername);
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Status'),
              subtitle: Text(status),
              trailing: DropdownButton<String>(
                value: status,
                items: <String>['Available', 'Busy', 'Do Not Disturb'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newStatus) {
                  if (newStatus != null) {
                    _updateStatus(newStatus);
                  }
                },
              ),
            ),
            Divider(),

            SizedBox(height: 20),
            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout),
                label: Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade800,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
