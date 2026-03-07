import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';

class RecipeProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Recipe> _recipes = [];
  String? _userId;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favorites => _recipes.where((r) => r.isFavorite).toList();

  List<Recipe> byCategory(MealCategory cat) =>
      _recipes.where((r) => r.category == cat).toList();

  Future<void> load(String userId) async {
    _userId = userId;
    _recipes = await _storage.loadRecipes(userId);
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    await _storage.saveRecipe(_userId!, recipe);
    notifyListeners();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx != -1) {
      _recipes[idx] = recipe;
      await _storage.saveRecipe(_userId!, recipe);
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    await _storage.deleteRecipe(_userId!, id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _recipes.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recipes[idx].isFavorite = !_recipes[idx].isFavorite;
      await _storage.saveRecipe(_userId!, _recipes[idx]);
      notifyListeners();
    }
  }
}
