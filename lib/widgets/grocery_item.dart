import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery.dart';

class GroceryItem extends StatelessWidget {
  const GroceryItem({super.key, required this.grocery, required this.onRemove});

  final Grocery grocery;
  final void Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(grocery.id),
      background: Container(
        color: Theme.of(context).colorScheme.inverseSurface,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (direction) {
        onRemove();
      },
      child: ListTile(
        title: Text(
          grocery.name,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.normal,
              ),
        ),
        leading: Container(
          color: grocery.category.color,
          width: 24,
          height: 24,
        ),
        trailing: Text(
          grocery.quantity.toString(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
