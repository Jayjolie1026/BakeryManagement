// Item model for recipe items
class Ingredient {
  final int ingredientID;
  final String name;
  final int quantity;
  final String measurement; // New field for measurement

  Ingredient({
    required this.ingredientID,
    required this.name,
    required this.quantity,
    required this.measurement, // Include measurement in constructor
  });

  // Factory constructor to parse JSON into Ingredient object
   factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientID: json['IngredientID'] ?? 0, // Default to 0 if null
      name: json['Name'] ?? '', // Default to empty string if null
      quantity: json['Quantity'] ?? 0, // Default to 0 if null
      measurement: json['Measurement'] ?? '', // Default to empty string if null
    );
  }

}
class Item {
  final int recipeID;
  final String name;
  final String steps;
  final int productID;
  final List<Ingredient> ingredients; // List to hold Ingredient objects
  final String category; // New field for category
  final int yield2; // New field for yield
  

  Item({
    required this.recipeID,
    required this.name,
    required this.steps,
    required this.productID,
    required this.ingredients,
    required this.category, // Include category in constructor
    required this.yield2,
  });

  // Factory constructor to parse JSON into Item object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      recipeID: json['RecipeID'] ?? 0, // Default to 0 if null
      name: json['Name'] ?? '', // Default to empty string if null
      steps: json['Steps'] ?? '', // Default to empty string if null
      productID: json['ProductID'] ?? 0, // Default to 0 if null
      // Parse the array of ingredients from JSON and convert to List<Ingredient>
      ingredients: (json['Ingredients'] as List<dynamic>?)?.map((ingredient) {
        return Ingredient.fromJson(ingredient);
      }).toList() ?? [], // Default to an empty list if null
      category: json['Category'] ?? '', // Default to empty string if null
      yield2: json['Yield'] ?? 0,
    );
  }
}
