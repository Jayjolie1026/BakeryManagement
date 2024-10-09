let inventory = []; // Store inventory globally

// Function to load inventory from the API
async function loadInventory() {
    try {
        // Fetch inventory data from the backend API
        const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
        
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        
        // Convert the response data to JSON and store it in the global inventory array
        inventory = await response.json();
        
        // Display all inventory items initially
        displayInventory(inventory);
    } catch (error) {
        console.error("Error loading inventory API:", error);
        document.getElementById('errorMessage').textContent = `Error: ${error.message}`;
    }
}

// Function to display inventory items in the table
function displayInventory(inventoryToDisplay) {
    const inventoryBody = document.getElementById('inventoryBody');
    inventoryBody.innerHTML = ''; // Clear previous entries

    inventoryToDisplay.forEach(item => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${item.EntryID}</td>
            <td>${item.IngredientName}</td>
            <td>${item.Category}</td>
            <td>${item.Description || 'N/A'}
            <td>${item.InventoryMeasurement}
            <td>${item.IngredientID}
            <td>${item.IngredientQuantity}</td>
            <td>${item.Cost}</td>
            </td> <!-- Added InventoryMeasurement, default to 'N/A' if empty -->
            <td>${item.Notes || 'None'}</td> <!-- Display 'None' if Notes are missing -->
            <td>${new Date(item.CreateDateTime).toLocaleString()}</td>
            <td>${new Date(item.ExpireDateTime).toLocaleString()}</td>
            <td>${item.MinAmount}</td>
            <td>${item.MaxAmount}</td>
            <td>${item.ReorderAmount}</td>
            <td>${item.VendorID}</td>
        `;
        inventoryBody.appendChild(row);
    });
}

// Function to filter inventory items based on search input
function filterInventory() {
    const searchInput = document.getElementById('searchInput').value.toLowerCase(); // Get search input and convert to lowercase
    const errorMessage = document.getElementById('errorMessage'); // Error message element
    
    // Clear any previous error messages
    errorMessage.textContent = '';

    if (searchInput === '') {
        displayInventory(inventory); // Show all items if search is cleared
        return;
    }

    // Filter the inventory array based on the search input
    const filteredInventory = inventory.filter(item => item.IngredientName.toLowerCase().includes(searchInput));

    if (filteredInventory.length === 0) {
        // Show feedback if no items are found
        errorMessage.textContent = "Sorry, item does not exist.";
    } else {
        // Display the filtered inventory items if found
        displayInventory(filteredInventory);
    }
}

// Event listener for search button click
document.getElementById('searchButton').addEventListener('click', filterInventory);

// Event listener for Enter key press in the search input
document.getElementById('searchInput').addEventListener('keydown', function(event) {
    if (event.key === 'Enter') {
        filterInventory(); // Trigger search when "Enter" key is pressed
    }
});

// Load inventory data when the webpage loads
document.addEventListener("DOMContentLoaded", loadInventory);

// Event listener to show all items when the search bar is cleared
document.getElementById('searchInput').addEventListener('input', function() {
    if (this.value === '') {
        document.getElementById('errorMessage').textContent = ''; // Clear error message
        displayInventory(inventory); // Show all inventory items when the search bar is cleared
    }
});
