import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe/recipe_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<RecipeProvider>().favorites;

    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Aucune recette favorite',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 4),
            Text('Appuyez sur ♥ pour ajouter aux favoris',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (ctx, i) => RecipeCard(
        recipe: favorites[i],
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(
              builder: (_) => RecipeDetailPage(recipe: favorites[i])),
        ),
        onFavoriteToggle: () =>
            context.read<RecipeProvider>().toggleFavorite(favorites[i].id),
      ),
    );
  }
}
