import 'recipe.dart';

enum MealSlot { breakfast, lunch, dinner }

extension MealSlotLabel on MealSlot {
  String get label {
    switch (this) {
      case MealSlot.breakfast:
        return 'Petit déjeuner';
      case MealSlot.lunch:
        return 'Déjeuner';
      case MealSlot.dinner:
        return 'Dîner';
    }
  }
}

class DayMeal {
  final DateTime date;
  Recipe? breakfast;
  Recipe? lunch;
  Recipe? dinner;

  DayMeal({required this.date, this.breakfast, this.lunch, this.dinner});

  Recipe? getSlot(MealSlot slot) {
    switch (slot) {
      case MealSlot.breakfast:
        return breakfast;
      case MealSlot.lunch:
        return lunch;
      case MealSlot.dinner:
        return dinner;
    }
  }

  void setSlot(MealSlot slot, Recipe? recipe) {
    switch (slot) {
      case MealSlot.breakfast:
        breakfast = recipe;
        break;
      case MealSlot.lunch:
        lunch = recipe;
        break;
      case MealSlot.dinner:
        dinner = recipe;
        break;
    }
  }

  List<Recipe> get allRecipes =>
      [breakfast, lunch, dinner].whereType<Recipe>().toList();

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'breakfast': breakfast?.toJson(),
        'lunch': lunch?.toJson(),
        'dinner': dinner?.toJson(),
      };

  factory DayMeal.fromJson(Map<String, dynamic> json) => DayMeal(
        date: DateTime.parse(json['date']),
        breakfast: json['breakfast'] != null
            ? Recipe.fromJson(json['breakfast'])
            : null,
        lunch: json['lunch'] != null ? Recipe.fromJson(json['lunch']) : null,
        dinner:
            json['dinner'] != null ? Recipe.fromJson(json['dinner']) : null,
      );
}
