import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import 'add_recipe_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    // Get fresh copy from provider
    final r = provider.recipes.firstWhere((e) => e.id == recipe.id,
        orElse: () => recipe);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(r.name),
              background: r.imagePath != null
                  ? Image.network(r.imagePath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.green.shade200,
                        child: const Icon(Icons.restaurant, size: 80, color: Colors.white)))
                  : Container(
                      color: Colors.green.shade200,
                      child: const Icon(Icons.restaurant,
                          size: 80, color: Colors.white)),
            ),
            actions: [
              IconButton(
                icon: Icon(
                    r.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(r.id),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddRecipePage(recipe: r)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Supprimer ?'),
                      content: Text('Supprimer "${r.name}" ?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Supprimer',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await provider.deleteRecipe(r.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(
                    label: Text(r.category.label),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(color: Colors.green.shade800),
                  ),
                  if (r.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(r.description,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                  ],
                  const SizedBox(height: 20),

                  // Ingredients
                  const Text('Ingrédients',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (r.ingredients.isEmpty)
                    const Text('Aucun ingrédient',
                        style: TextStyle(color: Colors.grey))
                  else
                    ...r.ingredients.map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.fiber_manual_record,
                                  size: 8, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(ing.name,
                                  style: const TextStyle(fontSize: 15)),
                              const Spacer(),
                              Text(
                                  '${ing.quantity} ${ing.unit}'.trim(),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        )),
                  const SizedBox(height: 20),

                  // Steps
                  if (r.steps.isNotEmpty) ...[
                    const Text('Préparation',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...r.steps.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.green,
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(e.value,
                                      style: const TextStyle(
                                          fontSize: 15, height: 1.4))),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
