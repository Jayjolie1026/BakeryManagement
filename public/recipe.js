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
        // Extract unique categories from recipes
        const categories = extractCategories(recipes);
        
        // Display categories as buttons
        displayCategories(categories);

    } catch (error) {
        // Log any errors encountered during the fetch process
        console.error("Error loading recipes API:", error);
    }
}

function extractCategories(recipes) {
    const categories = new Set(); // Using Set to avoid duplicates

    // Loop through each recipe and add its category to the Set
    recipes.forEach(recipe => {
        if (recipe.Category) {
            categories.add(recipe.Category); // Add the category to the Set
        }
    });

    return [...categories]; // Convert the Set back to an array
}

function displayCategories(categories) {
    const categoryContainer = document.getElementById('category-container'); // Get the container for categories

    const showAllButton = document.createElement('button');
    showAllButton.classList.add('category-button'); // Add a class for styling
    showAllButton.textContent = 'Show All'; // Set the button text
    showAllButton.onclick = function() {
        displayRecipes(recipes); // When clicked, display all recipes
    };

    categoryContainer.appendChild(showAllButton);

    categories.forEach(category => {
        const categoryButton = document.createElement('button'); // Create a new button element
        categoryButton.classList.add('category-button'); // Add a class to the button
        categoryButton.textContent = category; // Set the button text to the category name

        // Set the button's click action to filter recipes by category
        categoryButton.onclick = function() {
            filterRecipesByCategory(category);
        };

        // Append the button to the category container
        categoryContainer.appendChild(categoryButton);
    });
}
   
function filterRecipesByCategory(category) {
    const filteredRecipes = recipes.filter(recipe => recipe.Category === category);
    displayRecipes(filteredRecipes); // Update the displayed recipes based on the selected category
}




// Function to display recipes as buttons
function displayRecipes(recipesToDisplay) {
    const recipeContainer = document.getElementById('recipe-container'); // Get the container for recipes
    
    // Clear existing recipe buttons from the container
    recipeContainer.innerHTML = '';

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

document.getElementById('add-recipe-button').addEventListener('click', function() {
  window.location.href = 'addFinalproducts.html';  // Redirect to addFinalProduct.html
});

// Calls loadRecipes function when the webpage loads
window.onload = loadRecipes;
