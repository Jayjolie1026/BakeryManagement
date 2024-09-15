document.getElementById('registerForm').addEventListener('submit', async (event) => {
    event.preventDefault();
  
    const firstName = document.getElementById('firstName').value;
    const lastName = document.getElementById('lastName').value;
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const email = document.getElementById('email').value;
    const phoneNumber = document.getElementById('phoneNumber').value;
    const address = {
        streetAddress: document.getElementById('streetAddress').value,
        city: document.getElementById('city').value,
        state: document.getElementById('state').value,
        postalCode: document.getElementById('postalCode').value,
        country: document.getElementById('country').value,
    };
  
    try {
        const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ firstName, lastName, username, password, email, phoneNumber, address }),
        });
  
        const result = await response.text();
        document.getElementById('responseMessage').textContent = result;
    } catch (error) {
        console.error('Error:', error);
        document.getElementById('responseMessage').textContent = 'Error registering user.';
    }
  });
  