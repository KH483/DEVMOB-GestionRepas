import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipe_card.dart';

class AssignRecipePage extends StatelessWidget {
  final DateTime date;
  final MealSlot slot;

  const AssignRecipePage({
    super.key,
    required this.date,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    final recipes = context.watch<RecipeProvider>().recipes;
    final mealProvider = context.read<MealPlanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir pour ${slot.label}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: recipes.isEmpty
          ? const Center(
              child: Text('Aucune recette disponible.\nAjoutez des recettes d\'abord.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (ctx, i) => RecipeCard(
                recipe: recipes[i],
                onTap: () async {
                  await mealProvider.assignRecipe(date, slot, recipes[i]);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ),
    );
  }
}
