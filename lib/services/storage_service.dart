import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';

class StorageService {
  final _db = FirebaseFirestore.instance;

  // ── Recipes ──────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _recipesCol(String userId) =>
      _db.collection('users').doc(userId).collection('recipes');

  Future<List<Recipe>> loadRecipes(String userId) async {
    final snap = await _recipesCol(userId).get();
    return snap.docs.map((d) => Recipe.fromJson(d.data())).toList();
  }

  Future<void> saveRecipe(String userId, Recipe recipe) async {
    await _recipesCol(userId).doc(recipe.id).set(recipe.toJson());
  }

  Future<void> deleteRecipe(String userId, String recipeId) async {
    await _recipesCol(userId).doc(recipeId).delete();
  }

  // ── Meal Plan ─────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _mealPlanCol(String userId) =>
      _db.collection('users').doc(userId).collection('mealplan');

  Future<Map<String, DayMeal>> loadMealPlan(String userId) async {
    final snap = await _mealPlanCol(userId).get();
    return {for (final d in snap.docs) d.id: DayMeal.fromJson(d.data())};
  }

  Future<void> saveDayMeal(String userId, String key, DayMeal day) async {
    await _mealPlanCol(userId).doc(key).set(day.toJson());
  }
}
