document.getElementById('loginForm').addEventListener('submit', async (event) => {
    event.preventDefault(); // Prevent the form from submitting the normal way
  
    // Get the values from the input fields
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
  
    try {
        // Make a POST request to the /login endpoint
        const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, password }), // Send the username and password as JSON
        });
  
        // Parse the response
        const result = await response.text();
  
        if (response.ok) {
            // Login successful; redirect to recipe.html using a GET request
            window.location.href = 'recipe.html'; // This triggers a GET request to the recipe page
        } else {
            // Login failed; display the error message
            document.getElementById('responseMessage').textContent = `Login failed: ${result}`;
        }
    } catch (error) {
        // Handle any network or other errors
        console.error('Error during login:', error);
        document.getElementById('responseMessage').textContent = 'Error during login.';
    }
  });