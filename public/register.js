document.getElementById('addUserForm').addEventListener('submit', async function (event) {
  event.preventDefault(); // Prevent form submission

  const password = document.getElementById('password').value;
  const passwordError = document.getElementById('passwordError');

  // Strong password pattern: at least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
  const passwordPattern = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$/;

  if (!passwordPattern.test(password)) {
      passwordError.style.display = 'block'; // Show error message
      return; // Stop submission if password is not strong
  } else {
      passwordError.style.display = 'none'; // Hide error if valid
  }

  // Collect form data
  const firstName = document.getElementById('firstName').value;
  const lastName = document.getElementById('lastName').value;
  const username = document.getElementById('username').value;
  const email = document.getElementById('email').value;
  const phoneNumber = document.getElementById('phoneNumber').value;
  const address = document.getElementById('address').value;

  const userData = {
      firstName,
      lastName,
      username,
      password,
      email: email ? { emailAddress: email, emailTypeID: 1 } : null,
      phoneNumber: phoneNumber ? { number: phoneNumber, areaCode: "123", phoneTypeID: 1 } : null,
      address: address ? { streetAddress: address, city: "City", state: "State", postalCode: "12345", country: "Country", addressTypeID: 1 } : null
  };

  try {
      const response = await fetch('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/users', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(userData),
      });

      if (response.ok) {
          alert('User added successfully!');
          document.getElementById('addUserForm').reset();
          window.location.href = "index.html"; // Redirect to login page
      } else {
          const errorText = await response.text();
          throw new Error(errorText);
      }
  } catch (error) {
      alert(`Error: ${error.message}`);
  }
});
