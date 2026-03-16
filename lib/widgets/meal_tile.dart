import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

class MealTile extends StatelessWidget {
  final MealSlot slot;
  final Recipe? recipe;
  final VoidCallback onAssign;
  final VoidCallback? onRemove;

  const MealTile({
    super.key,
    required this.slot,
    this.recipe,
    required this.onAssign,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: recipe != null ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: recipe != null ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          _slotIcon(slot),
          color: Colors.green.shade600,
          size: 20,
        ),
        title: Text(slot.label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: recipe != null
            ? Text(recipe!.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87))
            : const Text('Non planifié',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
        trailing: recipe != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: onRemove,
              )
            : IconButton(
                icon: const Icon(Icons.add, size: 18, color: Colors.green),
                onPressed: onAssign,
              ),
        onTap: onAssign,
      ),
    );
  }

  IconData _slotIcon(MealSlot slot) {
    switch (slot) {
      case MealSlot.breakfast:
        return Icons.free_breakfast;
      case MealSlot.lunch:
        return Icons.lunch_dining;
      case MealSlot.dinner:
        return Icons.dinner_dining;
    }
  }
}
