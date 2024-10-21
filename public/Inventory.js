let inventory = []; // Store inventory globally

// Function to load inventory from the API
async function loadInventory() {
    try {
        const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        inventory = await response.json();
        displayInventory(inventory); // Display all inventory items initially
        
        // Extract unique categories and display category buttons
        const categories = extractCategories(inventory);
        displayCategories(categories);
    } catch (error) {
        console.error("Error loading inventory API:", error);
        document.getElementById('errorMessage').textContent = `Error: ${error.message}`;
    }
}

// Function to extract unique categories from the inventory
function extractCategories(inventory) {
    const categories = new Set(); // Using Set to avoid duplicates

    // Loop through each item and add its category to the Set
    inventory.forEach(item => {
        if (item.Category) {
            categories.add(item.Category); // Add the category to the Set
        }
    });

    return [...categories]; // Convert Set back to an array
}

// Function to display category buttons
function displayCategories(categories) {
    const categoryContainer = document.getElementById('category-container'); // Get the container for categories
    
    const showAllButton = document.createElement('button');
    showAllButton.classList.add('category-button');
    showAllButton.textContent = 'Show All'; // Set button text
    showAllButton.onclick = function() {
        displayInventory(inventory); // Display all items when clicked
    };
    
    categoryContainer.appendChild(showAllButton);

    // Create a button for each category
    categories.forEach(category => {
        const categoryButton = document.createElement('button');
        categoryButton.classList.add('category-button');
        categoryButton.textContent = category;

        // Filter inventory when the category button is clicked
        categoryButton.onclick = function() {
            filterInventoryByCategory(category);
        };

        categoryContainer.appendChild(categoryButton); // Append the button to the container
    });
}

// Function to filter inventory by category
function filterInventoryByCategory(category) {
    const filteredInventory = inventory.filter(item => item.Category === category);
    displayInventory(filteredInventory); // Update displayed items based on the selected category
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
            <td>${item.Description || 'N/A'}</td>
            <td>${item.InventoryMeasurement}</td>
            <td>${item.IngredientID}</td>
            <td>${item.IngredientQuantity}</td>
            <td>${item.Cost}</td>
            <td>${item.Notes || 'None'}</td>
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

// Function to filter inventory based on search input
function filterInventory() {
    const searchInput = document.getElementById('searchInput').value.toLowerCase();
    const errorMessage = document.getElementById('errorMessage');
    errorMessage.textContent = ''; // Clear error message

    if (searchInput === '') {
        displayInventory(inventory); // Show all items if search is cleared
        return;
    }

    const filteredInventory = inventory.filter(item => item.IngredientName.toLowerCase().includes(searchInput));

    if (filteredInventory.length === 0) {
        errorMessage.textContent = "Sorry, item does not exist.";
    } else {
        displayInventory(filteredInventory);
    }
}

// Event listener for search button click
document.getElementById('searchButton').addEventListener('click', filterInventory);

// Event listener for Enter key press in the search input
document.getElementById('searchInput').addEventListener('keydown', function(event) {
    if (event.key === 'Enter') {
        filterInventory(); // Trigger search on Enter key press
    }
});

// Load inventory data when the webpage loads
document.addEventListener("DOMContentLoaded", loadInventory);

// Show all inventory items when the search bar is cleared
document.getElementById('searchInput').addEventListener('input', function() {
    if (this.value === '') {
        document.getElementById('errorMessage').textContent = ''; // Clear error message
        displayInventory(inventory); // Show all inventory items
    }
});
