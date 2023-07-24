import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'manage.dart';

class EditGroceryPage extends StatefulWidget {
  final Grocery grocery;

  EditGroceryPage({required this.grocery});

  @override
  _EditGroceryPageState createState() => _EditGroceryPageState();
}

class _EditGroceryPageState extends State<EditGroceryPage> {
  TextEditingController _groceryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groceryController.text = widget.grocery.name;
  }

  Future<void> _deleteGrocery(BuildContext context) async {
    try {
      await Provider.of<GroceryProvider>(context, listen: false)
          .deleteGrocery(widget.grocery.id);

      Navigator.pop(context);
    } catch (e) {
      print('Error deleting grocery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Grocery'),
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
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Save Changes'),
              onPressed: () {
                final newName = _groceryController.text.trim();
                if (newName.isNotEmpty) {
                  Provider.of<GroceryProvider>(context, listen: false)
                      .updateGrocery(widget.grocery.id, newName);
                  Navigator.pop(context);
                }
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () => _deleteGrocery(context),
              style: ElevatedButton.styleFrom(primary: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
