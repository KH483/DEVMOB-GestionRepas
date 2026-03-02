class Ingredient {
  String name;
  String quantity;
  String unit;

  Ingredient({required this.name, this.quantity = '', this.unit = ''});

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? '',
        unit: json['unit'] ?? '',
      );
}
