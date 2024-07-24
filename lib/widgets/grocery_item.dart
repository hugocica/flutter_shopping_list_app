import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery.dart';

const double gap = 12;

class GroceryItem extends StatelessWidget {
  const GroceryItem({super.key, required this.grocery});

  final Grocery grocery;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: grocery.category.color,
            width: 20,
            height: 20,
          ),
          const SizedBox(
            width: gap,
          ),
          Expanded(
            child: Text(
              grocery.name,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
          const SizedBox(
            width: gap,
          ),
          // const Spacer(),
          Text(
            grocery.quantity.toString(),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
