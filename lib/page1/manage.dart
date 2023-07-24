import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Grocery {
  final String id;
  final String name;
  final String imageUrl;
  final String notes;

  Grocery({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.notes,
  });
}

class GroceryProvider extends ChangeNotifier {
  List<Grocery> _groceries = [];

  List<Grocery> get groceries => _groceries;

  Future<void> fetchGroceries() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groceries').get();
      _groceries = querySnapshot.docs
          .map((doc) => Grocery(id: doc.id, name: doc['name'], imageUrl: '', notes: ''))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching groceries: $e');
    }
  }

  Future<void> addGrocery(String name) async {
    try {
      final DocumentReference document =
          await FirebaseFirestore.instance.collection('groceries').add({
        'name': name,
      });
      _groceries.add(Grocery(id: document.id, name: name, imageUrl: '', notes: ''));
      notifyListeners();
    } catch (e) {
      print('Error adding grocery: $e');
    }
  }

  Future<void> deleteGrocery(String id) async {
    try {
      await FirebaseFirestore.instance.collection('groceries').doc(id).delete();
      _groceries.removeWhere((grocery) => grocery.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting grocery: $e');
    }
  }

  Future<void> updateGrocery(String id, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('groceries')
          .doc(id)
          .update({'name': newName});

      final index = _groceries.indexWhere((grocery) => grocery.id == id);
      if (index != -1) {
        _groceries[index] = Grocery(id: id, name: newName, imageUrl: '', notes: '');
        notifyListeners();
      }
    } catch (e) {
      print('Error updating grocery: $e');
    }
  }
}
