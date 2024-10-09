let recipes = []; // Store recipes globally

// Function to load recipes from the API
async function loadRecipes() {
    try {
        // Use fetch API to get data from the specified endpoint
        const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');
        
        // Check if the response is successful
        if (!response.ok) {
            throw new Error('Network response was not ok'); // Throw an error if the response is not okay
        }
        
        // Convert the response data to JSON and store it in the global recipes array
        recipes = await response.json();
        
        // Call displayRecipes function to show all recipes initially
        displayRecipes(recipes);
    } catch (error) {
        // Log any errors encountered during the fetch process
        console.error("Error loading recipes API:", error);
    }
}
//begin from 33 -41
// Function to display recipes as buttons
function displayRecipes(recipesToDisplay) {
    const recipeContainer = document.getElementById('recipe-container'); // Get the container for recipes
    
    // Clear existing recipe buttons from the container
    recipeContainer.querySelectorAll('.recipe-button').forEach(button => button.remove());

    // Create and append buttons for each recipe in the recipesToDisplay array
    recipesToDisplay.forEach(recipe => {
        const recipeButton = document.createElement('button'); // Create a new button element
        recipeButton.classList.add('recipe-button'); // Add a class to the button
        
        // Create an image element for the recipe
        const recipeImage = document.createElement('img');
        recipeImage.src = `assets/${recipe.RecipeID}.jpg`; // Set the image source to the recipe's image URL
        recipeImage.alt = `${recipe.Name} Image`; // Add alt text for accessibility
        recipeImage.classList.add('recipe-image'); // Add a class to the image for styling
        
        recipeImage.onerror = function(){
            recipeImage.src = 'assets/noIMG.jpg';
        };


        // Optionally, add a span to hold the recipe name (this part is optional, can be removed)
        const recipeName = document.createElement('span');
        recipeName.textContent = recipe.Name; // Set the text to the recipe name
        recipeName.classList.add('recipe-name'); // Add a class for styling if needed
    
        // Set the button's click action to redirect to the recipe instructions
        recipeButton.onclick = function() {
            window.location.href = `instructions.html?ID=${recipe.RecipeID}`;
        };
    
        // Append the image (and the name if you want to) to the button
        recipeButton.appendChild(recipeImage);
        recipeButton.appendChild(recipeName); // Remove this line if you don't want text
    
        // Append the button to the recipe container
        recipeContainer.appendChild(recipeButton);
    });
}

// Function to filter recipes based on search input
function filterRecipes() {
    const searchInput = document.getElementById('search-input').value.toLowerCase(); // Get the search input and convert to lowercase
    
    // Filter the recipes array to include only those that match the search input
    const filteredRecipes = recipes.filter(recipe => recipe.Name.toLowerCase().includes(searchInput));
    
    // Call displayRecipes to update the displayed recipes based on the filter
    displayRecipes(filteredRecipes);
}

// Calls loadRecipes function when the webpage loads
window.onload = loadRecipes;


// // Function to add a new recipe
// async function addRecipe() {
//   // Get the input values
//   const recipeName = document.getElementById('new-recipe-name').value;
//   const recipeSteps = document.getElementById('new-recipe-steps').value;
//   const productId = document.getElementById('new-recipe-product-id').value;

//   // Gather ingredients
//   const ingredients = Array.from(document.querySelectorAll('.ingredient')).map(ingredient => ({
//       IngredientID: parseInt(ingredient.querySelector('.ingredient-id').value),
//       Quantity: parseFloat(ingredient.querySelector('.ingredient-quantity').value)
//   }));

//   // Create a new recipe object
//   const newRecipe = {
//       name: recipeName,
//       steps: recipeSteps,
//       product_id: parseInt(productId),
//       ingredients: ingredients
//   };

//   try {
//       // Send a POST request to the backend API
//       const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes', {
//           method: 'POST',
//           headers: {
//               'Content-Type': 'application/json'
//           },
//           body: JSON.stringify(newRecipe) // Convert the new recipe object to a JSON string
//       });

//       // Check if the response is successful
//       if (response.ok) {
//           // Successfully added the recipe
//           const result = await response.text(); // Optionally read response
//           console.log(result);
//           alert('Recipe added successfully!');

//           // Clear the form inputs
//           document.getElementById('new-recipe-name').value = '';
//           document.getElementById('new-recipe-steps').value = '';
//           document.getElementById('new-recipe-product-id').value = '';
//           document.querySelectorAll('.ingredient-id').forEach(input => input.value = '');
//           document.querySelectorAll('.ingredient-quantity').forEach(input => input.value = '');
//           hideAddRecipeForm(); // Hide the form after submission
//       } else {
//           // Handle any errors from the server
//           const errorText = await response.text();
//           console.error('Error adding recipe:', errorText);
//           alert('Failed to add recipe: ' + errorText);
//       }
//   } catch (error) {
//       console.error("Error adding recipe:", error);
//       alert('Error adding recipe: ' + error.message);
//   }
// }

// // Function to add a new ingredient input field
// function addIngredient() {
//   const ingredientList = document.getElementById('ingredient-list');
//   const ingredientDiv = document.createElement('div');
//   ingredientDiv.className = 'ingredient';
//   ingredientDiv.innerHTML = `
//       <input type="number" placeholder="Ingredient ID" class="ingredient-id" required>
//       <input type="number" placeholder="Quantity" class="ingredient-quantity" required>
//       <button type="button" onclick="removeIngredient(this)">Remove</button>
//   `;
//   ingredientList.appendChild(ingredientDiv);
// }

// // Function to remove an ingredient input field
// function removeIngredient(button) {
//   const ingredientDiv = button.parentElement; // Get the parent div
//   ingredientDiv.remove(); // Remove the ingredient div from the DOM
// }

// // Function to hide the Add Recipe form
// function hideAddRecipeForm() {
//   document.getElementById('add-recipe-form').style.display = 'none'; // Hide the form
// }
