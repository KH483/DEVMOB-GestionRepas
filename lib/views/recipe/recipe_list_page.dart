import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipe_card.dart';
import 'add_recipe_page.dart';
import 'recipe_detail_page.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _categories = [null, ...MealCategory.values];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Recipe> _filtered(RecipeProvider provider, MealCategory? cat) {
    if (cat == null) return provider.recipes;
    return provider.byCategory(cat);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: [
            const Tab(text: 'Tous'),
            ...MealCategory.values.map((c) => Tab(text: c.label)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((cat) {
              final list = _filtered(provider, cat);
              if (list.isEmpty) {
                return const Center(
                    child: Text('Aucune recette',
                        style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, i) => RecipeCard(
                  recipe: list[i],
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                            RecipeDetailPage(recipe: list[i])),
                  ),
                  onFavoriteToggle: () =>
                      provider.toggleFavorite(list[i].id),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRecipePage()),
            ),
            backgroundColor: Colors.green,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nouvelle recette',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
