async function fetchInventory() {
  try {
      const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
      if (!response.ok) throw new Error('Error fetching inventory');

      const inventory = await response.json();
      const ingredientSelect = document.getElementById('ingredientSelect');

      inventory.forEach(item => {
          const option = document.createElement('option');
          option.value = item.IngredientID; // Use IngredientID
          option.textContent = `${item.IngredientName}: ${item.Quantity} ${item.InventoryMeasurement}`; // Display measurement
          ingredientSelect.appendChild(option);
      });
  } catch (error) {
      console.error('Error fetching inventory:', error);
  }
}

async function fetchRecipe(recipeID) {
  try {
      await fetchInventory(); // Fetch inventory before recipe

      const response = await fetch(`https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes/${recipeID}`);
      if (!response.ok) throw new Error('Recipe not found');

      const recipe = await response.json();

      if (recipe) {
          document.title = recipe.Name; // Set page title

          let html = `
              <h1>${recipe.Name}</h1>
              <h2>Category: ${recipe.Category}</h2>
              <h2>Yield: ${recipe.Yield}</h2>
              <img src="bread1.png" alt="Recipe Image"> 
              <h3>Ingredients:</h3>
              <ul class="ingredients-list">
          `;

          recipe.Ingredients.forEach(ingredient => {
              html += `<li>${ingredient.Name}: ${ingredient.Quantity} ${ingredient.Measurement || ''}</li>`;
          });

          html += '</ul><h3>Steps:</h3><ul class="steps-list">';
          const steps = recipe.Steps.split('\\n').filter(step => step.trim() !== '');
          steps.forEach(step => {
              html += `<li>${step.trim()}</li>`;
          });

          html += '</ul>';

          document.getElementById('recipeContainer').innerHTML = html;

          // Set the values for the update form
          document.getElementById('name').value = recipe.Name;
          document.getElementById('category').value = recipe.Category;
          document.getElementById('yield').value = recipe.Yield;
          document.getElementById('steps').value = recipe.Steps;
          document.getElementById('recipeID').value = recipe.RecipeID;

      } else {
          document.getElementById('recipeContainer').innerHTML = '<p>No recipe found with that ID.</p>';
      }
  } catch (error) {
      console.error('Error fetching recipe:', error);
      document.getElementById('recipeContainer').innerHTML = `<p>${error.message}. Please try again.</p>`;
  }
}

// Collect added ingredients with correct measurement
document.getElementById('addIngredientBtn').addEventListener('click', () => {
  const ingredientSelect = document.getElementById('ingredientSelect');
  const ingredientQuantity = document.getElementById('ingredientQuantity');
  const selectedIngredientsDiv = document.getElementById('selectedIngredients');

  const selectedOption = ingredientSelect.options[ingredientSelect.selectedIndex];
  if (selectedOption && ingredientQuantity.value) {
      const ingredientName = selectedOption.text.split(':')[0];
      const ingredientEntryID = selectedOption.value;
      const quantity = parseFloat(ingredientQuantity.value); // Ensure quantity is a float
      const measurement = selectedOption.text.split(':')[1].trim().split(' ')[1]; // Get the measurement from the selected option

      if (isNaN(quantity) || quantity <= 0) {
          alert('Please enter a valid quantity.');
          return;
      }

      const ingredientDiv = document.createElement('div');
      ingredientDiv.textContent = `${ingredientName}: ${quantity} ${measurement} (Entry ID: ${ingredientEntryID})`; // Include measurement

      const removeBtn = document.createElement('button');
      removeBtn.textContent = 'Remove';
      removeBtn.onclick = () => {
          selectedIngredientsDiv.removeChild(ingredientDiv);
      };
      ingredientDiv.appendChild(removeBtn);

      selectedIngredientsDiv.appendChild(ingredientDiv);

      // Clear the inputs
      ingredientSelect.selectedIndex = 0;
      ingredientQuantity.value = '';
  } else {
      alert('Please select an ingredient and enter a quantity.');
  }
});

// Update recipe form submission
// Handle the recipe update form submission
document.getElementById('updateRecipeForm').addEventListener('submit', async (event) => {
  event.preventDefault();

  const recipeID = getRecipeIDFromURL(); // Assuming you can extract this from URL or from recipe object
  const recipeName = document.getElementById('name').value;
  const steps = document.getElementById('steps').value.trim().split('\n').map(step => step.trim()).filter(step => step !== '').join('\\n');
  const category = document.getElementById('category').value;
  const yield2 = document.getElementById('yield').value;

  // Prepare the updated recipe object
  const updatedRecipe = {
      name: recipeName,
      steps: steps,
      category: category,
      yield2: yield2,
      ingredients: []  // Initialize empty ingredients array
  };

  // Collect selected ingredients
  const selectedIngredientsDiv = document.getElementById('selectedIngredients');
  const ingredientDivs = selectedIngredientsDiv.children;

  for (const div of ingredientDivs) {
      const text = div.textContent;
      const entryID = text.split('(Entry ID:')[1].replace(')', '').trim();
      const nameQuantity = text.split('(Entry ID:')[0].trim();
      const name = nameQuantity.split(':')[0].trim();
      const quantityMeasurement = nameQuantity.split(':')[1].trim();
      const [quantity, measurement] = quantityMeasurement.split(' ');

      const ingredient = {
          IngredientID: parseInt(entryID),
          Quantity: parseFloat(quantity),
          Measurement: measurement
      };

      updatedRecipe.ingredients.push(ingredient);
  }

  // Send the PUT request to update the recipe
  try {
      const response = await fetch(`https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes/${recipeID}`, {
          method: 'PUT',
          headers: {
              'Content-Type': 'application/json',
          },
          body: JSON.stringify(updatedRecipe),  // Send updated recipe data
      });

      if (!response.ok) {
          const responseBody = await response.text();
          throw new Error('Failed to update recipe: ' + responseBody);
      }

      alert('Recipe updated successfully!');
      window.location.href = `http://127.0.0.1:5500/BakeryManagement/public/instructions.html?ID=${recipeID}`;
  } catch (error) {
      alert('Error updating recipe: ' + error.message);
  }
});


// Handle modal functionality
const updateRecipeBtn = document.getElementById('updateRecipeBtn');
const modal = document.getElementById('updateModal');
const closeBtn = document.querySelector('.close');

updateRecipeBtn.addEventListener('click', () => {
  modal.style.display = 'flex';
});

closeBtn.addEventListener('click', () => {
  modal.style.display = 'none';
});

// Initialize the page
const params = new URLSearchParams(window.location.search);
const recipeID = params.get('ID');
window.onload = () => fetchRecipe(recipeID);
