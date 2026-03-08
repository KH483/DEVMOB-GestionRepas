import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../services/storage_service.dart';

class MealPlanProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  Map<String, DayMeal> _plan = {};
  String? _userId;

  Map<String, DayMeal> get plan => _plan;

  Future<void> load(String userId) async {
    _userId = userId;
    _plan = await _storage.loadMealPlan(userId);
    notifyListeners();
  }

  String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DayMeal getDayMeal(DateTime date) {
    final key = _key(date);
    return _plan[key] ?? DayMeal(date: date);
  }

  Future<void> assignRecipe(
      DateTime date, MealSlot slot, Recipe? recipe) async {
    final key = _key(date);
    final day = _plan[key] ?? DayMeal(date: date);
    day.setSlot(slot, recipe);
    _plan[key] = day;
    await _storage.saveDayMeal(_userId!, key, day);
    notifyListeners();
  }

  List<Ingredient> generateShoppingList(DateTime weekStart) {
    final Map<String, Ingredient> merged = {};
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayMeal = getDayMeal(day);
      for (final recipe in dayMeal.allRecipes) {
        for (final ing in recipe.ingredients) {
          final key = ing.name.toLowerCase().trim();
          merged.putIfAbsent(key, () => ing);
        }
      }
    }
    return merged.values.toList();
  }
}
