import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';

const Map<int, String> productImages = {
  12: 'assets/sourdough.jpg',
  13: 'assets/choclatechip.jpg',
  14: 'assets/buttercroissant.jpg',
  15: 'assets/blueberrymuffins.jpg',
  16: 'assets/cinnaon.jpg',
  17: 'assets/frecnh.jpg',
  18: 'assets/lemon.jpg',
  19: 'assets/eclair.jpg',
  20: 'assets/pie.jpg',
  21: 'assets/cupcakes.jpg',
  22: 'assets/pie.jpg',
  23: 'assets/almond.jpg',
  24: 'assets/raspberry.jpg',
  25: 'assets/brownies.jpg',
  26: 'assets/macarons.jpg',
};

void showAddRecipeDialog(BuildContext context, VoidCallback onRecipeAdded) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController productIDController = TextEditingController();
  final TextEditingController ingredientIDController = TextEditingController();
  final TextEditingController ingredientQuantityController =
      TextEditingController();
  final TextEditingController ingredientMeasurementController =
      TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController yieldController = TextEditingController();

  List<Map<String, dynamic>> ingredients = [];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Recipe'),
        backgroundColor:
            const Color(0xFFF0d1a0), // Background color of the dialog
        titleTextStyle: const TextStyle(
            color: Color(0xFF6D3200), fontFamily: 'MyFont', fontSize: 24),

        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              // Steps Input
              TextField(
                controller: stepsController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              // Product ID Input
              TextField(
                controller: productIDController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Product ID',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Ingredient ID Input
              TextField(
                controller: ingredientIDController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Ingredient ID',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              // Ingredient Quantity Input
              TextField(
                controller: ingredientQuantityController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Ingredient Quantity',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              // Ingredient Measurement Input
              TextField(
                controller:
                    ingredientMeasurementController, // New measurement controller
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Ingredient Measurement',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: categoryController, // New controller for category
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),

              // TextField for Yield
              TextField(
                controller: yieldController, // New controller for yield
                keyboardType:
                    TextInputType.number, // Set keyboard type to number
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Yield',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final ingredientID =
                      int.tryParse(ingredientIDController.text);
                  final ingredientQuantity =
                      double.tryParse(ingredientQuantityController.text);
                  final ingredientMeasurement =
                      ingredientMeasurementController.text;

                  if (ingredientID != null &&
                      ingredientQuantity != null &&
                      ingredientMeasurement.isNotEmpty) {
                    // Add ingredient to the list with measurement
                    ingredients.add({
                      'IngredientID': ingredientID,
                      'Quantity': ingredientQuantity,
                      'Measurement': ingredientMeasurement,
                    });

                    // Clear the input fields
                    ingredientIDController.clear();
                    ingredientQuantityController.clear();
                    ingredientMeasurementController
                        .clear(); // Clear the measurement field
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D3200),
                  foregroundColor: const Color(0xFFF0d1a0),
                ),
                child: const Text('Add Ingredient'),
              ),
              // Display added ingredients
              ...ingredients.map((ingredient) {
                return Text(
                    '${ingredient['IngredientID']} - ${ingredient['Quantity']} ${ingredient['Measurement']}');
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6D3200), // Text color
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Prepare the recipe data to send to the API
              final name = nameController.text;
              final steps = stepsController.text;
              final productID = int.tryParse(productIDController.text);
              final category = categoryController
                  .text; // Get the category from the controller
              final yieldValue = int.tryParse(yieldController.text) ?? 0;

              if (name.isNotEmpty &&
                  steps.isNotEmpty &&
                  productID != null &&
                  ingredients.isNotEmpty) {
                // Call the API to add the recipe
                try {
                  await addRecipe(name, steps, productID, category, yieldValue,
                      ingredients);
                  onRecipeAdded(); // Callback to refresh or update the UI
                  Navigator.of(context).pop(); // Close the dialog
                } catch (e) {
                  // error
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D3200),
              foregroundColor: const Color(0xFFF0d1a0),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      );
    },
  );
}

class DetailedRecipePage extends StatefulWidget {
  final String recipeName;
  final int recipeID;
  final Function(Item)? onRecipeUpdated;

  const DetailedRecipePage({
    required this.recipeName,
    required this.recipeID,
    super.key,
    this.onRecipeUpdated,
  });

  @override
  _DetailedRecipePageState createState() => _DetailedRecipePageState();
}

class _DetailedRecipePageState extends State<DetailedRecipePage> {
  late Item _recipe; // Assuming Item is the model for your recipes
  late int currYield =
      1; // Initialize with default value to avoid LateInitializationError
  String searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipe();
  }

  Future<void> _fetchRecipe() async {
    try {
      // Fetch the recipe using the recipeID passed to the widget
      final fetchedRecipe = await RecipeApi.fetchRecipeById(widget.recipeID);
      setState(() {
        _recipe = fetchedRecipe;
        currYield = _recipe.yield2; // Initialize currYield properly
        _isLoading = false; // Set loading to false after fetching
      });
    } catch (error) {
      // error
      setState(() {
        _isLoading = false; // Set loading to false even if there's an error
      });
      // Handle the error appropriately (e.g., show an alert)
    }
  }

  void _updateRecipe(Item updatedRecipe) async {
    // Preserve the recipeID before updating
    final int preservedRecipeID = _recipe.recipeID;

    setState(() {
      _recipe = updatedRecipe;
      _recipe.recipeID = preservedRecipeID; // Ensure recipeID is not lost
    });

    // Optionally re-fetch the recipe from the database if needed
    try {
      final fetchedRecipe = await RecipeApi.fetchRecipeById(preservedRecipeID);
      setState(() {
        _recipe = updatedRecipe; // Update state with the fetched recipe
      });
    } catch (error) {
      // error
    }

    if (widget.onRecipeUpdated != null) {
      widget.onRecipeUpdated!(
          updatedRecipe); // Notify parent widget with the updated recipe
    }
  }

// Check if enough stock is available before incrementing the yield
  void _incrementYield(BuildContext context) {
    bool hasEnoughStock = true;
    String insufficientStockMessage = '';

    // Determine the increment based on the current yield
    int incrementValue;

    // For recipes with a base yield greater than 1, increment by that value
    if (currYield % _recipe.yield2 == 0) {
      // Check if current yield is a multiple of the base yield
      incrementValue = _recipe.yield2; // Use the base yield as increment
    } else {
      incrementValue = 1; // Default increment for other recipes
    }

    for (final ingredient in _recipe.ingredients) {
      // Calculate the required amount for the next yield
      double requiredAmount =
          (ingredient.quantity * (currYield + incrementValue)) / _recipe.yield2;

      // Check if the inventory quantity is not null and then compare
      if (ingredient.inventoryQuantity != null &&
          requiredAmount > ingredient.inventoryQuantity!) {
        hasEnoughStock = false;
        // Prepare the message for the dialog
        insufficientStockMessage =
            'Not enough ${ingredient.name} in stock. Required: $requiredAmount, Available: ${ingredient.inventoryQuantity}';
        break; // Stop checking if one ingredient fails
      }
    }

    // If enough stock is available, increment the yield
    if (hasEnoughStock) {
      setState(() {
        currYield += incrementValue; // Increment by determined value
      });
    } else {
      // Show a popup with the insufficient stock message
      _showInsufficientStockDialog(context, insufficientStockMessage);
    }
  }

// Function to show a dialog with the insufficient stock message
  void _showInsufficientStockDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFF0d1a0), // Background color of the dialog
          title: const Text('Insufficient Stock',
              style: TextStyle(fontSize: 30, color: Color(0xFF6D3200))),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6D3200))),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Decrement yield, not going below 1
  void _decrementYield() {
    // Ensure we don't go below the initial yield
    final int incrementValue = _recipe.yield2;
    if (currYield - incrementValue >= _recipe.yield2) {
      setState(() {
        currYield -= incrementValue;
      });
    } else {
      // If decrementing would go below the initial yield, just reset to initial yield
      setState(() {
        currYield = _recipe.yield2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0D1A0), // Same background as ProductPage
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<Item>>(
                future: RecipeApi.getItems(searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    final items = snapshot.data!;
                    final recipe = items
                        .where((item) => item.recipeID == widget.recipeID)
                        .toList();
                    if (recipe.isEmpty) {
                      return const Center(child: Text('Recipe not found'));
                    }

                    final item = recipe.first; // The selected recipe

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the recipe name from the fetched item
                        Text(
                          item.name, // Use item.name instead of widget.recipeName
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200), // Same dark brown color
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),

                        Image.asset(
                          productImages[item.productID] ??
                              'assets/bagel3.jpg', // Dynamic image based on recipeID
                          width: double.infinity,
                          height: 250, // Image height
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Category:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        Text(
                          item.category, // Display the category
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Yield:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 50, // Set the width of the button
                              height: 50, // Set the height of the button
                              child: IconButton(
                                iconSize: 40, // Increase the icon size
                                color: const Color(0xFF6D3200),
                                icon: const Icon(Icons.arrow_left_rounded),
                                onPressed: _decrementYield,
                              ),
                            ),

                            Text(
                              currYield.toString(), // Display current yield
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF6D3200),
                              ),
                            ),

                            SizedBox(
                              width: 50, // Set the width of the button
                              height: 50, // Set the height of the button
                              child: IconButton(
                                iconSize: 40, // Increase the icon size
                                color: const Color(0xFF6D3200),
                                icon: const Icon(Icons.arrow_right_rounded),
                                onPressed: () => _incrementYield(context),
                              ),
                            ),

                            const SizedBox(
                                width:
                                    10), // Add some space between the arrows and the button
                            ElevatedButton(
                              onPressed: () async {

                                // Call the bake function and wait for the result
                                final result = await bake(_recipe, currYield);

                                if (result['success']) {
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Recipe baked successfully'),
                                    ),
                                  );

                                  // Refresh the page to update product quantity
                                  setState(() {

                                  });
                                } 
                                else {
                                  // Show failure message with specific error details
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Insufficient Quantity',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6D3200),
                                          ),
                                        ),
                                        content: Text(
                                          result['message']?.replaceFirst(
                                                  'Exception: ', '') ??
                                              'Failed to bake the recipe',
                                        ),
                                        backgroundColor: const Color(0xFFF0D1A0),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6D3200),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                    0xFF6D3200), // Button background
                                foregroundColor: const Color(
                                    0xFFF0D1A0), // Button text color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10), // Padding for the button
                              ),
                              child: const Text(
                                'Bake It',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ingredients:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (item.ingredients.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                item.ingredients.map<Widget>((ingredient) {
                              final yieldQuantity = ((ingredient.quantity *
                                          currYield) /
                                      _recipe.yield2)
                                  .toStringAsFixed(
                                      1); // Adjust quantity based on currYield, 1 decimal place
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '- $yieldQuantity ${ingredient.measurement} of ${ingredient.name}', // Display ingredient details
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF6D3200),
                                      fontFamily: "MyFont2"),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text(
                            'No ingredients available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6D3200),
                            ),
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Directions:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.steps.replaceAll('\\n', '\n'),
                          style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6D3200),
                              fontFamily: "MyFont2"),
                        ),
                        const SizedBox(
                            height:
                                20), // Extra space before the bottom buttons

                        // Use Align to center the buttons at the bottom
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  // Open the recipe update dialog
                                  showRecipeUpdateDialog(
                                    context,
                                    item, // Pass the current recipe item
                                    (updatedRecipe) {
                                      _updateRecipe(updatedRecipe);
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6D3200),
                                  foregroundColor: const Color(0xFFF0D1A0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add),
                                    SizedBox(width: 8),
                                    Text('Update'),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  height: 20), // Spacing between the buttons
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, true); // Close the page
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6D3200),
                                  foregroundColor: const Color(0xFFEEC07B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFFEEC07B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data found'));
                  }
                },
              ),
      ),
    );
  }
}

void showRecipeUpdateDialog(
    BuildContext context, Item recipe, ValueChanged<Item> onRecipeUpdated) {
  // Create a string representation of ingredients including measurement
  String ingredientsString = recipe.ingredients.map((ingredient) {
    return '${ingredient.ingredientID}:${ingredient.name}:${ingredient.quantity}:${ingredient.measurement}'; // Include measurement
  }).join(', ');

  TextEditingController nameController =
      TextEditingController(text: recipe.name);
  TextEditingController stepsController =
      TextEditingController(text: recipe.steps);
  TextEditingController ingredientsController =
      TextEditingController(text: ingredientsString);
  TextEditingController categoryController =
      TextEditingController(text: recipe.category);
  TextEditingController yieldController =
      TextEditingController(text: recipe.yield2.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Example color
        titleTextStyle: const TextStyle(
            color: Color(0xFF6D3200), fontFamily: 'MyFont', fontSize: 24.0),
        title: const Text('Update Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Editable Fields for Recipe
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: ingredientsController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText:
                      'Ingredients (format: ID:name:quantity:measurement, ...)',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: stepsController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
                maxLines: 5, // Allow multiline for recipe steps
              ),
              TextField(
                controller: categoryController, // New category controller
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: yieldController, // New yield controller
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Yield',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
                // Optional: limit input to numbers
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog without changes
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6D3200), // Text color
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update the recipe with new values
                int yieldValue = int.tryParse(yieldController.text) ??
                    0; // Default to 0 if parsing fails

                // Create the updated recipe
                final updatedRecipe = Item(
                  recipeID: recipe.recipeID,
                  name: nameController.text,
                  steps: stepsController.text,
                  productID: recipe.productID,
                  ingredients: ingredientsController.text
                      .split(',')
                      .map((ingredientString) {
                    final parts = ingredientString.split(':');

                    // Assuming you're using the format ID:name:quantity:measurement for updating ingredients
                    if (parts.length == 4) {
                      // Adjust this back to 4 for updates
                      return Ingredient(
                        ingredientID: int.parse(parts[0].trim()),
                        name: parts[1].trim(),
                        quantity: int.parse(parts[2].trim()),
                        measurement: parts[3].trim(),
                        // entryID and inventoryQuantity are not included for updates
                      );
                    } else {
                      throw Exception(
                          'Invalid ingredient format. Expected format: ID:name:quantity:measurement');
                    }
                  }).toList(),
                  category: categoryController.text,
                  yield2: yieldValue,
                );

                // Validate required fields
                if (updatedRecipe.name.isEmpty ||
                    updatedRecipe.steps.isEmpty ||
                    updatedRecipe.productID == null ||
                    updatedRecipe.category.isEmpty ||
                    updatedRecipe.yield2 <= 0 ||
                    updatedRecipe.ingredients.isEmpty) {
                  throw Exception(
                      'Name, steps, product ID, category, yield, and ingredients are required');
                }

                // Prepare ingredients for the API call
                List<Map<String, dynamic>> ingredientsForApi =
                    updatedRecipe.ingredients.map((ingredient) {
                  return {
                    'IngredientID': ingredient.ingredientID,
                    'Name': ingredient.name,
                    'Quantity': ingredient.quantity,
                    'Measurement': ingredient.measurement,
                    // Don't include entryID and inventoryQuantity for updates
                  };
                }).toList();

                // Call the API to update the recipe
                await RecipeApi().updateRecipe(
                  updatedRecipe.recipeID,
                  updatedRecipe.name,
                  updatedRecipe.steps,
                  ingredientsForApi,
                  updatedRecipe.productID,
                  updatedRecipe.category,
                  updatedRecipe.yield2,
                );

                // Call the update callback
                onRecipeUpdated(updatedRecipe);

                // Close the dialog
                Navigator.pop(context, updatedRecipe);
              } catch (error) {
                // Handle error appropriately, e.g., show a snackbar or dialog
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D3200),
              foregroundColor: const Color(0xFFF0d1a0),
            ),
            child: const Text('Save Changes'),
          )
        ],
      );
    },
  );
}
