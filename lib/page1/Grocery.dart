import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:inclass/page1/manage.dart';

class AddGroceryPage extends StatefulWidget {
  @override
  _AddGroceryPageState createState() => _AddGroceryPageState();
}

class _AddGroceryPageState extends State<AddGroceryPage> {
  final TextEditingController _groceryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isAdding = false;
  String _error = '';
  File? _image;

  Future<void> _addGrocery() async {
    final groceryName = _groceryController.text.trim();
    final notes = _notesController.text.trim();

    if (groceryName.isEmpty) {
      setState(() {
        _error = 'Please enter a grocery name';
      });
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      // Upload the image to Firebase Storage
      String imageUrl = '';
      if (_image != null) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('grocery_images/${DateTime.now().millisecondsSinceEpoch}');
        final TaskSnapshot taskSnapshot = await storageReference.putFile(_image!);
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Add the grocery to Firestore
      await FirebaseFirestore.instance.collection('groceries').add({
        'name': groceryName,
        'imageUrl': imageUrl,
        'notes': notes,
      });

      setState(() {
        _isAdding = false;
        _error = '';
        _groceryController.clear();
        _notesController.clear();
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grocery added successfully')),
      );
    } catch (e) {
      setState(() {
        _isAdding = false;
        _error = 'Error adding grocery';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickImageFromGoogle() async {
    const googleImagesUrl = 'https://www.google.com/imghp';

    if (await canLaunch(googleImagesUrl)) {
      await launch(googleImagesUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch Google Images')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Grocery'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groceryController,
              decoration: InputDecoration(
                labelText: 'Grocery Name',
                hintText: 'Enter the grocery name',
                errorText: _error.isNotEmpty ? _error : null,
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Add Image from Gallery'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _pickImageFromGoogle,
                  child: Text('Add Image from Google'),
                ),
                SizedBox(width: 16.0),
                if (_image != null)
                  Image.file(
                    _image!,
                    height: 80.0,
                    width: 80.0,
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any notes for the grocery',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: _isAdding
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Add'),
              onPressed: _isAdding ? null : _addGrocery,
            ),
          ],
        ),
      ),
    );
  }
}
