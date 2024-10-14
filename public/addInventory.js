document.getElementById('ingredientInventoryForm').addEventListener('submit', async (event) => {
  event.preventDefault(); // Prevent page reload

  // Clear previous messages
  document.getElementById('resultMessage').textContent = '';
  document.getElementById('errorMessage').textContent = '';

  // Get form input values
  const name = document.getElementById('name').value;
  const description = document.getElementById('description').value;
  const category = document.getElementById('category').value;
  const measurement = document.getElementById('measurement').value;
  const maxAmount = document.getElementById('maxAmount').value;
  const reorderAmount = document.getElementById('reorderAmount').value;
  const minAmount = document.getElementById('minAmount').value;
  const vendorID = document.getElementById('vendorID').value;

  const quantity = document.getElementById('quantity').value;
  const notes = document.getElementById('notes').value;
  const cost = document.getElementById('cost').value;
  const createDateTime = document.getElementById('create_datetime').value;
  const expireDateTime = document.getElementById('expire_datetime').value;

  try {
      // Step 1: Post to /ingredients API
      const ingredientResponse = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/ingredients', {
          method: 'POST',
          headers: {
              'Content-Type': 'application/json'
          },
          body: JSON.stringify({
              name, description, category, measurement, maxAmount, reorderAmount, minAmount, vendorID
          })
      });

      if (!ingredientResponse.ok) {
          throw new Error('Failed to add ingredient');
      }

      const ingredientData = await ingredientResponse.json();
      const ingredientID = ingredientData.ingredientID; // Extract the new IngredientID

      // Step 2: Post to /inventory API using IngredientID from the first call
      const inventoryResponse = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory', {
          method: 'POST',
          headers: {
              'Content-Type': 'application/json'
          },
          body: JSON.stringify({
              ingredient_id: ingredientID,
              quantity,
              notes,
              cost,
              create_datetime: createDateTime,
              expire_datetime: expireDateTime,
              measurement
          })
      });

      if (!inventoryResponse.ok) {
          throw new Error('Failed to add inventory');
      }

      // Success message
      document.getElementById('resultMessage').textContent = 'Ingredient and Inventory added successfully!';
  } catch (error) {
      // Display error message
      document.getElementById('errorMessage').textContent = error.message;
  }
});

// Function to load vendors from the API
async function loadVendors() {
  try {
      const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors');
      
      if (!response.ok) {
          throw new Error('Failed to load vendors');
      }
      
      const vendors = await response.json();
      
      const vendorSelect = document.getElementById('vendorID');
      
      // Clear any existing options
      vendorSelect.innerHTML = '<option value="">Select a vendor</option>';
      
      // Populate the dropdown with vendor options
      vendors.forEach(vendor => {
          const option = document.createElement('option');
          option.value = vendor.VendorID;  // Assuming the response contains a VendorID field
          option.textContent = vendor.VendorName;  // Assuming the response contains a Name field
          vendorSelect.appendChild(option);
      });
      
  } catch (error) {
      console.error("Error loading vendors:", error);
      document.getElementById('addInventoryError').textContent = `Error: ${error.message}`;
  }
}

// Load vendors when the webpage loads
document.addEventListener("DOMContentLoaded", loadVendors);