import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Grocery.dart';
import 'auth.dart';
import 'edit.dart';
import 'manage.dart';


class HomePage extends StatelessWidget {
  void _signOut(BuildContext context) async {
    await Authentication().signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, groceryProvider, _) {
          if (groceryProvider.groceries.isEmpty) {
            return Center(
              child: Text('No groceries found.'),
            );
          } else {
            return ListView.builder(
              itemCount: groceryProvider.groceries.length,
              itemBuilder: (context, index) {
                final grocery = groceryProvider.groceries[index];
                return Dismissible(
                  key: Key(grocery.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    groceryProvider.deleteGrocery(grocery.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted ${grocery.name}')),
                    );
                  },
                  child: ListTile(
                    title: Text(grocery.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGroceryPage(grocery: grocery),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AddGroceryPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
