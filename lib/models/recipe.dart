import 'ingredient.dart';

enum MealCategory { breakfast, lunch, dinner, dessert, snack }

extension MealCategoryLabel on MealCategory {
  String get label {
    switch (this) {
      case MealCategory.breakfast:
        return 'Petit déjeuner';
      case MealCategory.lunch:
        return 'Déjeuner';
      case MealCategory.dinner:
        return 'Dîner';
      case MealCategory.dessert:
        return 'Dessert';
      case MealCategory.snack:
        return 'Collation';
    }
  }
}

class Recipe {
  final String id;
  String name;
  String description;
  List<Ingredient> ingredients;
  List<String> steps;
  MealCategory category;
  String? imagePath;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    this.description = '',
    List<Ingredient>? ingredients,
    List<String>? steps,
    this.category = MealCategory.lunch,
    this.imagePath,
    this.isFavorite = false,
  })  : ingredients = ingredients ?? [],
        steps = steps ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'steps': steps,
        'category': category.index,
        'imagePath': imagePath,
        'isFavorite': isFavorite,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((i) => Ingredient.fromJson(i))
                .toList() ??
            [],
        steps: List<String>.from(json['steps'] ?? []),
        category: MealCategory.values[json['category'] ?? 1],
        imagePath: json['imagePath'],
        isFavorite: json['isFavorite'] ?? false,
      );
}
