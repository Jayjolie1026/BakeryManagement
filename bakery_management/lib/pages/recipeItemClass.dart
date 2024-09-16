// Item model for recipe items
class Item {
  final int recipeID;
  final String name;
  final String steps;
  final int productID;
  final int ingredientID;
  final String ingredientName;
  final int ingredientQuantity;

  
  // Constructor
  Item({
    required this.recipeID,
    required this.name,
    required this.steps,
    required this.productID,
    required this.ingredientID,
    required this.ingredientName,
    required this.ingredientQuantity,
    
  });

  // Factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      recipeID: json['RecipeID'] ?? 0,    // Default to 0 if null
      name: json['Name'] ?? '',
      steps: json['Steps'] ?? '',         // Default to empty string if null
      productID: json['ProductID'] ?? 0,
      ingredientID: json['IngredientID'] ?? 0,
      ingredientName: json['IngredientName'] ?? '', 
      ingredientQuantity: json['IngredientQuantity'] ?? 0, 
    ); 
  }

  // Convert Item object to JSON format
  Map<String, dynamic> toJson() => {
        'RecipeID': recipeID,
        'Name': name,
        'Steps': steps,
        'ProductID': productID,
        'IngredientID': ingredientID,
        'IngredientName': ingredientName,
        'IngredientQuantity': ingredientQuantity,

      };
}