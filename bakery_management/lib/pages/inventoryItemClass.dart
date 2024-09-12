// Item model for inventory items
class Item {
  final int entryID;
  final int quantity;
  final double cost;
  final String notes;
  final DateTime createDateTime;
  final DateTime expireDateTime;
  final int employeeID; // Optional if included in API response
  final int recipeID;   // Optional if included in API response
  final String ingredientName;
  final int ingredientQuantity;
  final int minAmount;
  final int maxAmount;
  final int reorderAmount;


  // Constructor
  Item({
    required this.entryID,
    required this.quantity,
    required this.cost,
    required this.notes,
    required this.createDateTime,
    required this.expireDateTime,
    this.employeeID = 0, // Default to 0 if not included in API response
    this.recipeID = 0,   // Default to 0 if not included in API response
    required this.ingredientName, // Initialize IngredientName
    required this.ingredientQuantity,
    required this.minAmount,
    required this.maxAmount,
    required this.reorderAmount,
  });

  // Factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      entryID: json['EntryID'],
      quantity: json['Quantity'].toInt(),
      cost: json['Cost'].toDouble(),
      notes: json['Notes'] ?? '', // Default to empty string if null
      createDateTime: DateTime.parse(json['CreateDateTime']),
      expireDateTime: DateTime.parse(json['ExpireDateTime']),
      employeeID: json['EmployeeID'] ?? 0, // Use default if null
      recipeID: json['RecipeID'] ?? 0,     // Use default if null
      ingredientName: json['IngredientName'] ?? '', // Extract IngredientName
      ingredientQuantity: json['IngredientQuantity'].toInt(), // Extract IngredientQuantity
      minAmount: json['MinAmount'].toInt(),  // Extract MinAmount
      maxAmount: json['MaxAmount'].toInt(),  // Extract MaxAmount
      reorderAmount: json['ReorderAmount'].toInt(),  // Extract ReorderAmount
    );
  }

  // Convert Item object to JSON format
  Map<String, dynamic> toJson() => {
    'EntryID': entryID,
    'Quantity': quantity,
    'Cost': cost,
    'Notes': notes,
    'CreateDateTime': createDateTime.toIso8601String(),
    'ExpireDateTime': expireDateTime.toIso8601String(),
    'EmployeeID': employeeID,
    'RecipeID': recipeID,
    'IngredientName': ingredientName, // Add IngredientName to JSON
    'IngredientQuantity': ingredientQuantity,
    'MinAmount': minAmount,
    'MaxAmount': maxAmount,
    'ReorderAmount': reorderAmount,
  };
}