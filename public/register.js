document.getElementById('addUserForm').addEventListener('submit', async function (event) {
    event.preventDefault(); // Prevent form from submitting the traditional way
  
    const firstName = document.getElementById('firstName').value;
    const lastName = document.getElementById('lastName').value;
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const email = document.getElementById('email').value;
    const phoneNumber = document.getElementById('phoneNumber').value;
    const address = document.getElementById('address').value;
  
    // Construct the user object to be sent to the backend
    const userData = {
        firstName,
        lastName,
        username,
        password,
        email: email ? { emailAddress: email, emailTypeID: 1 } : null,  // Assuming 1 as default email type
        phoneNumber: phoneNumber ? { number: phoneNumber, areaCode: "123", phoneTypeID: 1 } : null, // Assuming default area code and type
        address: address ? { streetAddress: address, city: "City", state: "State", postalCode: "12345", country: "Country", addressTypeID: 1 } : null // Assuming address breakdown
    };
  
    try {
        const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(userData),
        });
  
        if (response.ok) {
            alert('User added successfully!');
            // Optionally reset the form or redirect the user
            document.getElementById('addUserForm').reset();
            window.location.href = "index.html" //direct to the login page (ploy added)
        } else {
            const errorText = await response.text();
            throw new Error(errorText);
        }
    } catch (error) {
        document.getElementById('errorMessage').innerText = `Error: ${error.message}`;
    }
  });