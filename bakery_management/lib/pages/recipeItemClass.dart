// Item model for recipe items
class Ingredient {
  final int ingredientID;
  final String name;
  final int quantity;

  Ingredient({
    required this.ingredientID,
    required this.name,
    required this.quantity,
  });

  // Factory constructor to parse JSON into Ingredient object
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientID: json['IngredientID'],
      name: json['Name'],
      quantity: json['Quantity'],
    );
  }
}

class Item {
  final int recipeID;
  final String name;
  final String steps;
  final int productID;
  final List<Ingredient> ingredients; // List to hold Ingredient objects

  Item({
    required this.recipeID,
    required this.name,
    required this.steps,
    required this.productID,
    required this.ingredients,
  });

  // Factory constructor to parse JSON into Item object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      recipeID: json['RecipeID'],
      name: json['Name'],
      steps: json['Steps'],
      productID: json['ProductID'],
      // Parse the array of ingredients from JSON and convert to List<Ingredient>
      ingredients: (json['Ingredients'] as List<dynamic>).map((ingredient) {
        return Ingredient.fromJson(ingredient);
      }).toList(),
    );
  }
}
