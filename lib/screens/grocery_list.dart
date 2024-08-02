import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
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
  bool _isLoading = true;
  String? _error;

  void _getGroceries() async {
    final url = Uri.https(
        'flutter-prep-ac46b-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> list = json.decode(response.body);
      final orderedList = list.entries.toList()
        ..sort((a, b) =>
            (a.value['order'] as int).compareTo(b.value['order'] as int));
      final List<Grocery> loadedItems = [];

      for (final item in orderedList) {
        loadedItems.add(
          Grocery(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: categories.entries
                .firstWhere(
                    (element) => element.value.name == item.value['category'])
                .value,
            order: item.value['order'],
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong.';
      });
    }
  }

  void _addItem() async {
    Grocery? newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => NewItemScreen(
          groceriesLength: _groceryItems.length,
        ),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(int index) async {
    Grocery groceryToBeRemoved = _groceryItems[index];

    List<Grocery> updatedGroceryList = _groceryItems
        .where((item) => item.id != groceryToBeRemoved.id)
        .toList();
    setState(() {
      _groceryItems = updatedGroceryList;
    });

    final url = Uri.https('flutter-prep-ac46b-default-rtdb.firebaseio.com',
        'shopping-list/${groceryToBeRemoved.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, groceryToBeRemoved);
      });
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        action: SnackBarAction(
          label: 'undo',
          textColor: Theme.of(context).colorScheme.onPrimaryContainer,
          onPressed: () async {
            final url = Uri.https(
                'flutter-prep-ac46b-default-rtdb.firebaseio.com',
                'shopping-list.json');
            var response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(
                {
                  'name': groceryToBeRemoved.name,
                  'quantity': groceryToBeRemoved.quantity,
                  'category': groceryToBeRemoved.category.name,
                  'order': groceryToBeRemoved.order,
                },
              ),
            );
            final responseData = json.decode(response.body);

            setState(() {
              _groceryItems.insert(
                index,
                Grocery(
                  id: responseData['name'],
                  name: groceryToBeRemoved.name,
                  quantity: groceryToBeRemoved.quantity,
                  category: groceryToBeRemoved.category,
                  order: groceryToBeRemoved.order,
                ),
              );
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
  }

  @override
  void initState() {
    super.initState();

    _getGroceries();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'You have no groceries yet.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => GroceryItem(
          grocery: _groceryItems[index],
          onRemove: () => _removeItem(index),
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
