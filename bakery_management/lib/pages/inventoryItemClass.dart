// Item model for inventory items
class Item {
  int? entryID;
  final int quantity;
  final double cost;
  final String notes;
  final DateTime createDateTime;
  final DateTime expireDateTime;
  final int employeeID; // Optional if included in API response
  final int recipeID;   // Optional if included in API response
  final String ingredientName;
  final double minAmount;
  final double maxAmount;
  final double reorderAmount;
  int? vendorID;

  // Constructor
  Item({
    this.entryID,
    required this.quantity,
    required this.cost,
    required this.notes,
    required this.createDateTime,
    required this.expireDateTime,
    this.employeeID = 0, // Default to 0 if not included in API response
    this.recipeID = 0,   // Default to 0 if not included in API response
    required this.ingredientName, // Initialize IngredientName
    required this.minAmount,
    required this.maxAmount,
    required this.reorderAmount,
    this.vendorID,
  });

  // Factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      entryID: json['EntryID'],
      quantity: json['Quantity'].toInt(),
      cost: json['Cost'].toDouble(),
      notes: json['Notes'] ?? '', // Default to empty string if null
      createDateTime: json['CreateDateTime'] != null && json['CreateDateTime'].isNotEmpty
          ? DateTime.parse(json['CreateDateTime'])
          : DateTime(0000, 1, 1),
      expireDateTime: json['ExpireDateTime'] != null && json['ExpireDateTime'].isNotEmpty
          ? DateTime.parse(json['ExpireDateTime'])
          : DateTime(0000, 1, 1),
      employeeID: json['EmployeeID'] ?? 0, // Use default if null
      recipeID: json['RecipeID'] ?? 0,     // Use default if null
      ingredientName: json['IngredientName'] ?? '', // Extract IngredientName
      minAmount: json['MinAmount'].toDouble(),  // Extract MinAmount
      maxAmount: json['MaxAmount'].toDouble(),  // Extract MaxAmount
      reorderAmount: json['ReorderAmount'].toDouble(),  // Extract ReorderAmount
      vendorID: json['VendorID'].toInt(),
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
    'MinAmount': minAmount,
    'MaxAmount': maxAmount,
    'ReorderAmount': reorderAmount,
    'VendorID': vendorID,
  };
}