import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery.dart';
import 'package:shopping_list_app/screens/new_item.dart';
import 'package:shopping_list_app/widgets/grocery_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() {
    return _GroceryListScreenState();
  }
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<Grocery> _groceryItems = [];

  void _addItem() async {
    Grocery? newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'You have no groceries yet.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => GroceryItem(
          grocery: _groceryItems[index],
          onRemove: () {
            Grocery groceryToBeRemoved = _groceryItems[index];
            List<Grocery> updatedGroceryList = _groceryItems
                .where((item) => item.id != groceryToBeRemoved.id)
                .toList();

            setState(() {
              _groceryItems = updatedGroceryList;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                action: SnackBarAction(
                  label: 'undo',
                  textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  onPressed: () {
                    setState(() {
                      _groceryItems.insert(index, groceryToBeRemoved);
                    });
                  },
                ),
                content: Text(
                  '${groceryToBeRemoved.name} successfully removed.',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
