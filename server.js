const express = require('express');
const path = require('path');
const sql = require('mssql');
const bcrypt = require('bcryptjs');

//const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
//const cors = require('cors'); // Import cors package

const app = express();
const port = process.env.PORT || 3000;

const dbConfig = {
    user: 'BakeryAdmin',
    password: 'cr0ssiant!',
    server: 'bakerymanagementserver.database.windows.net',
    database: 'bakerymanagement',
    options: {
        encrypt: true // For Azure SQL Database
    }
};

app.use(express.json());


app.use(express.static(path.join(__dirname, 'public')));



// Serve index.html for the root route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

console.log('Server is starting.');



  // GET /vendors: Retrieve all vendors Populate list underneath search bar
  app.get('/vendors', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const vendors = await pool.request().query('SELECT * FROM tblVendors');
        res.json(vendors.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// POST /vendors: Add a new vendor with email, phone, and address 
app.post('/vendors', async (req, res) => {
    const {
        VendorName,
        AreaCode,
        PhoneNumber,
        EmailAddress,
        StreetAddress,
        City,
        State,
        PostalCode,
        Country
    } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        const transaction = new sql.Transaction(pool);

        // Begin transaction
        await transaction.begin();

        // Insert Vendor
        const vendorRequest = transaction.request();
        vendorRequest.input('VendorName', sql.VarChar, VendorName);
        const vendorResult = await vendorRequest.query(`
            INSERT INTO tblVendors (VendorName) 
            OUTPUT INSERTED.VendorID 
            VALUES (@VendorName)
        `);

        const vendorID = vendorResult.recordset[0].VendorID;

        // Insert Vendor Email
        if (EmailAddress) {
            await transaction.request()
                .input('VendorID', sql.Int, vendorID)
                .input('EmailAddress', sql.VarChar, EmailAddress)
                .input('TypeID', sql.Int, 1) // Assuming a default TypeID, adjust as needed
                .input('Valid', sql.Bit, 1)  // Assuming the email is valid by default
                .query(`
                    INSERT INTO tblVendorEmails (VendorID, EmailAddress, TypeID, Valid) 
                    VALUES (@VendorID, @EmailAddress, @TypeID, @Valid)
                `);
        }

        // Insert Vendor Phone Number
        if (PhoneNumber && AreaCode) {
            await transaction.request()
                .input('VendorID', sql.Int, vendorID)
                .input('AreaCode', sql.VarChar, AreaCode)
                .input('PhoneNumber', sql.VarChar, PhoneNumber)
                .input('TypeID', sql.Int, 1) // Assuming a default TypeID, adjust as needed
                .input('Valid', sql.Bit, 1)  // Assuming the phone number is valid by default
                .query(`
                    INSERT INTO tblVendorPhoneNumbers (VendorID, AreaCode, Number, TypeID, Valid) 
                    VALUES (@VendorID, @AreaCode, @PhoneNumber, @TypeID, @Valid)
                `);
        }

        // Insert Vendor Address
        if (StreetAddress || City || State || PostalCode || Country) {
            await transaction.request()
                .input('VendorID', sql.Int, vendorID)
                .input('StreetAddress', sql.VarChar, StreetAddress || '')
                .input('City', sql.VarChar, City || '')
                .input('State', sql.VarChar, State || '')
                .input('PostalCode', sql.VarChar, PostalCode || '')
                .input('Country', sql.VarChar, Country || '')
                .input('AddressTypeID', sql.Int, 1) // Assuming a default AddressTypeID, adjust as needed
                .input('Active', sql.Bit, 1)       // Assuming the address is active by default
                .query(`
                    INSERT INTO tblVendorAddresses (VendorID, StreetAddress, City, State, PostalCode, Country, AddressTypeID, Active) 
                    VALUES (@VendorID, @StreetAddress, @City, @State, @PostalCode, @Country, @AddressTypeID, @Active)
                `);
        }

        // Commit the transaction
        await transaction.commit();
        res.status(201).send('Vendor added successfully');
    } catch (error) {
        // Rollback transaction in case of error
        if (transaction) await transaction.rollback();
        res.status(500).send(error.message);
    }
});

      

// DELETE /vendors/:id: Remove a vendor and related data by ID since cascade only need this table
app.delete('/vendors/:id', async (req, res) => {
    const vendor_id = req.params.id;

    if (!vendor_id) {
        return res.status(400).send('Vendor ID is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('VendorID', sql.Int, vendor_id)
            .query('DELETE FROM tblVendors WHERE VendorID = @VendorID');
        
        if (result.rowsAffected[0] > 0) {
            res.status(200).send('Vendor and related data deleted successfully');
        } else {
            res.status(404).send('Vendor not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// PUT /vendors/:id: Update vendor information including name, email, phone, and address
app.put('/vendors/:id', async (req, res) => {
    const vendor_id = req.params.id;
    const {
        VendorName,
        EmailAddress,
        PhoneNumber,
        AreaCode,
        StreetAddress,
        City,
        State,
        PostalCode,
        Country
    } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        const transaction = new sql.Transaction(pool);

        // Begin transaction
        await transaction.begin();

        // Update Vendor Name
        if (VendorName) {
            await transaction.request()
                .input('VendorID', sql.Int, vendor_id)
                .input('VendorName', sql.VarChar, VendorName)
                .query('UPDATE tblVendors SET VendorName = @VendorName WHERE VendorID = @VendorID');
        }

        // Update Vendor Email
        if (EmailAddress) {
            await transaction.request()
                .input('VendorID', sql.Int, vendor_id)
                .input('EmailAddress', sql.VarChar, EmailAddress)
                .query('UPDATE tblVendorEmails SET EmailAddress = @EmailAddress WHERE VendorID = @VendorID');
        }

        // Update Vendor Phone Number
        if (PhoneNumber && AreaCode) {
            await transaction.request()
                .input('VendorID', sql.Int, vendor_id)
                .input('AreaCode', sql.VarChar, AreaCode)
                .input('PhoneNumber', sql.VarChar, PhoneNumber)
                .query('UPDATE tblVendorPhoneNumbers SET AreaCode = @AreaCode, Number = @PhoneNumber WHERE VendorID = @VendorID');
        }

        // Update Vendor Address
        if (StreetAddress || City || State || PostalCode || Country) {
            let updateAddressQuery = 'UPDATE tblVendorAddresses SET ';
            let addressParameters = [];

            if (StreetAddress) {
                updateAddressQuery += 'StreetAddress = @StreetAddress, ';
                addressParameters.push({ name: 'StreetAddress', value: StreetAddress });
            }
            if (City) {
                updateAddressQuery += 'City = @City, ';
                addressParameters.push({ name: 'City', value: City });
            }
            if (State) {
                updateAddressQuery += 'State = @State, ';
                addressParameters.push({ name: 'State', value: State });
            }
            if (PostalCode) {
                updateAddressQuery += 'PostalCode = @PostalCode, ';
                addressParameters.push({ name: 'PostalCode', value: PostalCode });
            }
            if (Country) {
                updateAddressQuery += 'Country = @Country, ';
                addressParameters.push({ name: 'Country', value: Country });
            }

            // Remove trailing comma and space
            updateAddressQuery = updateAddressQuery.slice(0, -2);
            updateAddressQuery += ' WHERE VendorID = @VendorID';

            const addressRequest = transaction.request();
            addressRequest.input('VendorID', sql.Int, vendor_id);
            addressParameters.forEach(param => addressRequest.input(param.name, sql.VarChar, param.value));
            await addressRequest.query(updateAddressQuery);
        }

        // Commit the transaction
        await transaction.commit();
        res.send('Vendor information updated successfully');
    } catch (error) {
        // Rollback transaction in case of error
        if (transaction) await transaction.rollback();
        res.status(500).send(error.message);
    }
});


// GET /vendors/name/:name: Retrieve specific vendors by partial name match for search bar
app.get('/vendors/name/:name', async (req, res) => {
    const vendor_name = req.params.name;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('vendor_name', sql.VarChar, `%${vendor_name}%`)
            .query(`
                SELECT * 
                FROM tblVendors 
                WHERE VendorName LIKE @vendor_name
            `);
        
        if (result.recordset.length > 0) {
            res.json(result.recordset);  // Return all matching vendors
        } else {
            res.status(404).send('No vendors found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// GET /vendors/:id: Retrieve full vendor details by ID
app.get('/vendors/:id', async (req, res) => {
    const vendor_id = req.params.id;

    try {
        const pool = await sql.connect(dbConfig);
        // Query to fetch vendor details along with related data (addresses, phone numbers, emails)
        const result = await pool.request()
            .input('vendor_id', sql.Int, vendor_id)
            .query(`
                SELECT 
                    v.VendorID,
                    v.VendorName,
                    
                    -- Vendor Address Information
                    va.AddressID,
                    va.StreetAddress,
                    va.City,
                    va.State,
                    va.PostalCode,
                    va.Country,
                    at.Description AS AddressType,
                    
                    -- Vendor Phone Numbers
                    vp.PhoneNumberID,
                    vp.AreaCode,
                    vp.Number AS PhoneNumber,
                    pt.Description AS PhoneType,
                    
                    -- Vendor Emails
                    ve.EmailID,
                    ve.EmailAddress,
                    et.Description AS EmailType
                FROM 
                    tblVendors v
                LEFT JOIN 
                    tblVendorAddresses va ON v.VendorID = va.VendorID
                LEFT JOIN 
                    tblAddressTypes at ON va.AddressTypeID = at.AddressTypeID
                LEFT JOIN 
                    tblVendorPhoneNumbers vp ON v.VendorID = vp.VendorID
                LEFT JOIN 
                    tblPhoneTypes pt ON vp.TypeID = pt.TypeID
                LEFT JOIN 
                    tblVendorEmails ve ON v.VendorID = ve.VendorID
                LEFT JOIN 
                    tblEmailTypes et ON ve.TypeID = et.TypeID
                WHERE 
                    v.VendorID = @vendor_id
            `);

        // Check if the vendor was found
        if (result.recordset.length > 0) {
            // Format the response to group related data
            const vendor = {
                VendorID: result.recordset[0].VendorID,
                VendorName: result.recordset[0].VendorName,
                Addresses: [],
                PhoneNumbers: [],
                Emails: []
            };

            result.recordset.forEach(row => {
                // Aggregate addresses
                if (row.AddressID) {
                    vendor.Addresses.push({
                        AddressID: row.AddressID,
                        StreetAddress: row.StreetAddress,
                        City: row.City,
                        State: row.State,
                        PostalCode: row.PostalCode,
                        Country: row.Country,
                        AddressType: row.AddressType
                    });
                }

                // Aggregate phone numbers
                if (row.PhoneNumberID) {
                    vendor.PhoneNumbers.push({
                        PhoneNumberID: row.PhoneNumberID,
                        AreaCode: row.AreaCode,
                        PhoneNumber: row.PhoneNumber,
                        PhoneType: row.PhoneType
                    });
                }

                // Aggregate emails
                if (row.EmailID) {
                    vendor.Emails.push({
                        EmailID: row.EmailID,
                        EmailAddress: row.EmailAddress,
                        EmailType: row.EmailType
                    });
                }
            });

            res.json(vendor);
        } else {
            res.status(404).send('Vendor not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// POST /users: Add a new user
app.post('/users', async (req, res) => {
    console.log('Request body:', req.body);
    const { firstName, lastName, username, password, email, phoneNumber, address } = req.body;

    const newEmployeeID = uuidv4(); // Generate a GUID for the EmployeeID

    try {
        const hashedPassword = await bcrypt.hash(password, 10);

        const pool = await sql.connect(dbConfig);
        console.log('Inserting into tblUsers:', {
            employeeID: newEmployeeID,
            firstName,
            lastName,
            username,
        });

        await pool.request()
            .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
            .input('firstName', sql.VarChar, firstName)
            .input('lastName', sql.VarChar, lastName)
            .input('username', sql.VarChar, username)
            .input('password', sql.VarChar, hashedPassword)
            .query('INSERT INTO tblUsers (EmployeeID, FirstName, LastName, Username, Password) VALUES (@employeeID, @firstName, @lastName, @username, @password)');

        // Add email, phone number, and address to their respective tables
        if (email) {
            console.log('Inserting into tblEmails:', { email, employeeID: newEmployeeID });
            await pool.request()
                .input('emailAddress', sql.VarChar, email.emailAddress)
                .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
                .input('typeID', sql.Int, email.emailTypeID) // The ID from tblEmailTypes
                .input('valid', sql.Bit, 1) // Assuming email is valid by default
                .query('INSERT INTO tblEmails (EmailAddress, EmployeeID, TypeID, Valid) VALUES (@emailAddress, @employeeID, @typeID, @valid)');
        }

        if (phoneNumber) {
            console.log('Inserting into tblPhoneNumbers:', { phoneNumber, employeeID: newEmployeeID });
            await pool.request()
                .input('phoneNumber', sql.VarChar, phoneNumber.number)
                .input('areaCode', sql.VarChar, phoneNumber.areaCode)
                .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
                .input('typeID', sql.Int, phoneNumber.phoneTypeID)
                .input('valid', sql.Bit, 1)
                .query('INSERT INTO tblPhoneNumbers (Number, AreaCode, EmployeeID, TypeID, Valid) VALUES (@phoneNumber, @areaCode, @employeeID, @typeID, @valid)');
        }

        if (address) {
            console.log('Inserting into tblAddresses:', {
                streetAddress: address.streetAddress,
                city: address.city,
                state: address.state,
                postalCode: address.postalCode,
                country: address.country,
                addressTypeID: address.addressTypeID,
                employeeID: newEmployeeID,
            });
            
            await pool.request()
                .input('streetAddress', sql.VarChar, address.streetAddress)
                .input('city', sql.VarChar, address.city)
                .input('state', sql.VarChar, address.state)
                .input('postalCode', sql.VarChar, address.postalCode)
                .input('country', sql.VarChar, address.country)
                .input('addressTypeID', sql.Int, address.addressTypeID)
                .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
                .query('INSERT INTO tblAddresses (StreetAddress, City, State, PostalCode, Country, AddressTypeID, EmployeeID) VALUES (@streetAddress, @city, @state, @postalCode, @country, @addressTypeID, @employeeID)');
        }
        console.log('User added successfully');
        res.status(201).send('User added successfully');
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Endpoint to get emails and phone numbers for a specific employee
app.get('/employee/:id/contacts', async (req, res) => {
    const employeeID = req.params.id;
    console.log(`Fetching contacts for employee ID: ${employeeID}`); // Debug statement
    try {
        const pool = await sql.connect(dbConfig);
        const emails = await pool.request()
            .input('employeeID', sql.UniqueIdentifier, employeeID)
            .query('SELECT EmailAddress, TypeID, Valid FROM tblEmails WHERE EmployeeID = @employeeID');
        console.log('Fetched emails:', emails.recordset);
        const phoneNumbers = await pool.request()
            .input('employeeID', sql.UniqueIdentifier, employeeID)
            .query('SELECT Number, AreaCode, TypeID, Valid FROM tblPhoneNumbers WHERE EmployeeID = @employeeID');
            console.log('Fetched phone numbers:', phoneNumbers.recordset);
        res.json({ emails: emails.recordset, phoneNumbers: phoneNumbers.recordset });
    } catch (error) {
        console.error('Error fetching contacts:', error);
        res.status(500).send('Internal Server Error');
    }
});


// DELETE /users/username/:username: Remove a user by username
app.delete('/users/username/:username', async (req, res) => {
    const username = req.params.username;

    if (!username) {
        return res.status(400).send('Username is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('username', sql.VarChar, username)
            .query('DELETE FROM tblUsers WHERE Username = @username');

        if (result.rowsAffected[0] > 0) {
            res.send('User removed');
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// PUT /users/:username: Update user information, including address, phone number, and email
app.put('/users/:username', async (req, res) => {
    const username = req.params.username;
    const { firstName, lastName, newUsername, password, address, phoneNumbers, emails } = req.body;

    console.log(`Updating user: ${username}`);

    if (!username || (!firstName && !lastName && !newUsername && !password && !address && !phoneNumbers && !emails)) {
        console.log('Validation failed: No fields to update provided');
        return res.status(400).send('Username and at least one field to update are required');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Start transaction
        const transaction = new sql.Transaction(pool);
        await transaction.begin();
        console.log('Transaction started');

        const request = new sql.Request(transaction);

        // Update user basic information
        let query = 'UPDATE tblUsers SET ';
        let parameters = [];

        if (firstName) {
            query += 'FirstName = @firstName, ';
            parameters.push({ name: 'firstName', type: sql.VarChar, value: firstName });
            console.log(`Updating firstName: ${firstName}`);
        }
        if (lastName) {
            query += 'LastName = @lastName, ';
            parameters.push({ name: 'lastName', type: sql.VarChar, value: lastName });
            console.log(`Updating lastName: ${lastName}`);
        }
        if (newUsername) {
            query += 'Username = @newUsername, ';
            parameters.push({ name: 'newUsername', type: sql.VarChar, value: newUsername });
            console.log(`Updating newUsername: ${newUsername}`);
        }
        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            query += 'Password = @password, ';
            parameters.push({ name: 'password', type: sql.VarChar, value: hashedPassword });
            console.log('Updating password');
        }

        query = query.slice(0, -2);
        query += ' WHERE Username = @username';
        parameters.push({ name: 'username', type: sql.VarChar, value: username });

        parameters.forEach(param => request.input(param.name, param.type, param.value));
        console.log('Executing user update query:', query);
        await request.query(query);

        // Update user address
        if (address) {
            console.log(`Updating address for user: ${username}`);
            for (const addr of address) {
                const addrQuery = `
                    UPDATE tblAddresses 
                    SET StreetAddress = @StreetAddress, City = @City, State = @State, PostalCode = @PostalCode, Country = @Country
                    WHERE AddressID = @AddressID AND EmployeeID = (SELECT EmployeeID FROM tblUsers WHERE Username = @username)`;

                const addrRequest = new sql.Request(transaction); // Create a new request for this transaction
                addrRequest.input('StreetAddress', sql.VarChar, addr.StreetAddress);
                addrRequest.input('City', sql.VarChar, addr.City);
                addrRequest.input('State', sql.VarChar, addr.State);
                addrRequest.input('PostalCode', sql.VarChar, addr.PostalCode);
                addrRequest.input('Country', sql.VarChar, addr.Country);
                addrRequest.input('AddressID', sql.Int, addr.AddressID);
                addrRequest.input('username', sql.VarChar, username);
                
                await addrRequest.query(addrQuery);

                console.log(`Updated address: ${JSON.stringify(addr)}`);
            }
        }

        // Commit the transaction
        await transaction.commit();
        console.log('Transaction committed');
        res.status(200).send('User updated successfully');
    } catch (error) {
        console.error('Error updating user:', error);
        // Rollback the transaction in case of error
        await transaction.rollback();
        res.status(500).send('Internal Server Error');
    }
});




app.post('/emails', async (req, res) => {
    const { emailAddress, typeID, employeeID } = req.body;

    if (!emailAddress || !typeID || !employeeID) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        // Connect to the database
        const pool = await sql.connect(dbConfig);

        // Create a request for the query
        const request = pool.request();
        request.input('EmailAddress', sql.VarChar, emailAddress);
        request.input('TypeID', sql.Int, typeID);
        request.input('EmployeeID', sql.UniqueIdentifier, employeeID); // Adjust type based on your schema

        // SQL query to insert the email into tblEmails
        const query = `
            INSERT INTO tblEmails (EmailAddress, TypeID, EmployeeID)
            VALUES (@EmailAddress, @TypeID, @EmployeeID);
        `;

        // Execute the query with parameterized inputs
        await request.query(query);

        res.status(200).json({ message: 'Email added successfully' });
    } catch (error) {
        console.error('Error adding email:', error);
        res.status(500).json({ error: 'An error occurred while adding the email' });
    }
});

app.post('/phonenumbers', async (req, res) => {
    const { areaCode, phoneNumber, typeID, employeeID } = req.body;

    if (!areaCode || !phoneNumber || !typeID || !employeeID) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        // Connect to the database
        const pool = await sql.connect(dbConfig);

        // Create a request for the query
        const request = pool.request();
        request.input('AreaCode', sql.VarChar, areaCode);
        request.input('Number', sql.VarChar, phoneNumber);
        request.input('TypeID', sql.Int, typeID);
        request.input('EmployeeID', sql.UniqueIdentifier, employeeID); // Adjust type based on your schema

        // SQL query to insert the phone number into tblPhoneNumbers
        const query = `
            INSERT INTO tblPhoneNumbers (AreaCode, Number, TypeID, EmployeeID, Valid)
            VALUES (@AreaCode, @PhoneNumber, @TypeID, @EmployeeID, 1);  -- Assuming 'Valid' is a boolean field
        `;

        // Execute the query with parameterized inputs
        await request.query(query);

        res.status(200).json({ message: 'Phone number added successfully' });
    } catch (error) {
        console.error('Error adding phone number:', error);
        res.status(500).json({ error: 'An error occurred while adding the phone number' });
    }
});

// GET /users: Retrieve all users
app.get('/users', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM tblUsers');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// GET /users/employeeid/:id: Retrieve a specific user by EmployeeID
app.get('/users/employeeid/:id', async (req, res) => {
    const employeeId = parseInt(req.params.id, 10); // Convert to integer

    if (isNaN(employeeId)) {
        return res.status(400).send('Invalid EmployeeID');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('EmployeeID', sql.Int, employeeId) // Use sql.Int for EmployeeID
            .query('SELECT * FROM tblUsers WHERE EmployeeID = @EmployeeID');

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// POST /login: Authenticate user without hashing (for testing purposes only)
// app.post('/login', async (req, res) => {
//     console.log('Request Body:', req.body);
//     const { username, password } = req.body;

//     try {
//         const pool = await sql.connect(dbConfig);
//         if (pool.connected) {
//             console.log('Connected to Azure SQL Server');
//         }

//         const request = new sql.Request();
//         // Adjust the query to select the password_hash column
//         const result = await request
//             .input('username', sql.VarChar, username)
//             .query('SELECT password, EmployeeID FROM tblUsers WHERE username = @username'); // Adjusted query

//         console.log('testing');
//         if (result.recordset.length > 0) {
//             const dbPassword = result.recordset[0].password; // Correctly access password_hash
//             const employeeID = result.recordset[0].EmployeeID;
//             console.log(`Password from DB: ${dbPassword}`); // Log password from DB for verification

//             // Direct comparison of plain-text passwords (for testing purposes)
//             if (password === dbPassword) {
//                 res.json({ message: 'Authentication successful', employee_id: employeeID });
//             } else {
//                 res.status(401).send('Invalid credentials');
//             }
//         } else {
//             res.status(404).send('User not found');
//         }
//     } catch (error) {
//         res.status(200).send(error);
//     }
// });




 // POST /login: Authenticate user with hashed passwords
app.post('/login', async (req, res) => {
    console.log('Request Body:', req.body);
    const { username, password } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        if (pool.connected) {
            console.log('Connected to Azure SQL Server');
        }

        const request = new sql.Request();
        // Adjust the query to select the password and EmployeeID
        const result = await request
            .input('username', sql.VarChar, username)
            .query('SELECT Password, EmployeeID FROM tblUsers WHERE Username = @username'); // Adjusted query to include EmployeeID

        console.log('Testing');
        if (result.recordset.length > 0) {
            const dbPassword = result.recordset[0].Password; // Access PasswordHash
            const employeeID = result.recordset[0].EmployeeID; // Access EmployeeID

            console.log(`Password hash from DB: ${dbPassword}`); // Log password hash for verification

            // Compare provided password with hashed password from the database
            const match = await bcrypt.compare(password, dbPassword);

            if (match) {
                // Respond with EmployeeID if the password matches
                res.json({ message: 'Authentication successful', employee_id: employeeID });
            } else {
                res.status(401).send('Invalid credentials');
            }
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});
 

/* const transporter = nodemailer.createTransport({
    service: 'gmail', // Or use another email service
    auth: {
      user: 'your-email@gmail.com',
      pass: 'your-email-password',
    },
  });
  
  // Password Reset Endpoint
  app.post('/reset-password', async (req, res) => {
    const { email } = req.body;
  
    if (!email) {
      return res.status(400).send({ message: 'Email is required' });
    }
  
    try {
      // Connect to your database
      const pool = await sql.connect(dbConfig);
  
      // Check if the email exists in your Users table
      const result = await pool
        .request()
        .input('email', sql.VarChar, email)
        .query('SELECT * FROM Users WHERE email = @email');
  
      if (result.recordset.length === 0) {
        return res.status(404).send({ message: 'Email not found' });
      }
  
      // Generate a reset token (this could also be stored in the database if needed)
      const resetToken = crypto.randomBytes(32).toString('hex');
      const resetLink = `https://yourfrontend.com/reset-password?token=${resetToken}`; // Link to your frontend
  
      // TODO: Save the reset token to the database (with expiration time)
  
      // Send the reset email
      const mailOptions = {
        from: 'your-email@gmail.com',
        to: email,
        subject: 'Password Reset Request',
        text: `You have requested to reset your password. Please click on the link below to reset your password: ${resetLink}`,
      };
  
      await transporter.sendMail(mailOptions);
  
      // Respond with success
      res.status(200).send({ message: 'Password reset link has been sent to your email' });
    } catch (err) {
      console.error('Error processing password reset:', err);
      res.status(500).send({ message: 'An error occurred while processing your request' });
    }
  }); */
  
 




// POST /api/attendance/clockin: Record clock-in time
app.post('/api/attendance/clockin', async (req, res) => {
    const { employeeID } = req.body; // Use camelCase for consistency

    if (!employeeID) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('employeeID', sql.UniqueIdentifier, employeeID) // Use UniqueIdentifier
            .query(`
                INSERT INTO tblEmployeeAttendance (EmployeeID, ClockInTime, Date) 
                VALUES (@employeeID, GETDATE(), CONVERT(date, GETDATE()))
            `);
        res.status(201).json({ message: 'Clock-in recorded successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// POST /api/attendance/clockout: Record clock-out time
app.post('/api/attendance/clockout', async (req, res) => {
    const { employeeID } = req.body;

    if (!employeeID) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('employeeID', sql.UniqueIdentifier, employeeID)
            .query(`
                UPDATE tblEmployeeAttendance
                SET ClockOutTime = GETDATE()
                WHERE EmployeeID = @employeeID AND Date = CONVERT(date, GETDATE()) AND ClockOutTime IS NULL
            `);
        res.status(200).json({ message: 'Clock-out recorded successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Update Clock Out
app.put('/api/employee-attendance/:attendance_id/clock-out', async (req, res) => {
    const { attendance_id } = req.params;
    const { clock_out_time } = req.body;

    // Validate input
    if (!clock_out_time) {
        return res.status(400).json({ error: 'Clock-out time is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('attendance_id', sql.Int, attendance_id)
            .input('clock_out_time', sql.DateTime, clock_out_time) // Use DateTime for both date and time
            .query(`
                UPDATE tblEmployeeAttendance
                SET ClockOutTime = @clock_out_time
                WHERE AttendanceID = @attendance_id
            `);

        if (result.rowsAffected[0] === 0) {
            res.status(404).json({ message: 'Record not found' });
        } else {
            res.json({ attendance_id, clock_out_time });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/employee-attendance/:attendance_id/clock-in', async (req, res) => {
    const { attendance_id } = req.params;
    const { clock_in_time } = req.body;

    // Validate input
    if (!clock_in_time) {
        return res.status(400).json({ error: 'Clock-in time is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('attendance_id', sql.Int, attendance_id)
            .input('clock_in_time', sql.DateTime, clock_in_time) // Use DateTime for both date and time
            .query(`
                UPDATE tblEmployeeAttendance
                SET ClockInTime = @clock_in_time
                WHERE AttendanceID = @attendance_id
            `);

        if (result.rowsAffected[0] === 0) {
            res.status(404).json({ message: 'Record not found' });
        } else {
            res.json({ attendance_id, clock_in_time });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});




// Get all attendance
app.get('/api/attendance', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM tblEmployeeAttendance');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get specific attendance by EmployeeID
app.get('/api/attendance/:employee_id', async (req, res) => {
    const { employee_id } = req.params;

    // Validate input
    if (!employee_id) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.UniqueIdentifier, employee_id) // Use UniqueIdentifier for GUIDs
            .query('SELECT * FROM tblEmployeeAttendance WHERE EmployeeID = @employee_id');

        if (result.recordset.length > 0) {
            res.json(result.recordset);
        } else {
            res.status(404).json({ message: 'Attendance record not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});



// Ingredients API Calls


// GET /ingredients: Retrieve all ingredients
app.get('/ingredients', async (req, res) => {
    try {
        console.log("hello");
        const pool = await sql.connect(dbConfig);
        console.log("b");
        const result = await pool.request().query('SELECT * FROM dbo.tblIngredients'); // Correct table name
        console.log("c");
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// GET /ingredients/name/:name: Retrieve ingredients by partial name match for search bar
app.get('/ingredients/name/:name', async (req, res) => {
    const ingredientName = req.params.name;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('ingredientName', sql.VarChar, `%${ingredientName}%`)
            .query(`
                SELECT * 
                FROM tblIngredients 
                WHERE Name LIKE @ingredientName
            `);
        
        if (result.recordset.length > 0) {
            res.json(result.recordset);  // Return all matching ingredients
        } else {
            res.status(404).send('No ingredients found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});

const checkVendorExists = async (vendorID) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('vendorID', sql.Int, vendorID)
            .query('SELECT COUNT(*) AS count FROM tblVendors WHERE VendorID = @vendorID');
        
        return result.recordset[0].count > 0;
    } catch (error) {
        throw new Error('Error validating VendorID: ' + error.message);
    }
};



// POST /ingredients: Add a new ingredient
app.post('/ingredients', async (req, res) => {
    console.log(req.body);
    const { name, description, category, measurement, maxAmount, reorderAmount, minAmount, vendorID } = req.body;

    try {
        // Validate VendorID
        const vendorExists = await checkVendorExists(vendorID);
        if (!vendorExists) {
            return res.status(400).send('Invalid VendorID');
        }

        const pool = await sql.connect(dbConfig);
        const transaction = new sql.Transaction(pool);
        await transaction.begin();

        const request = new sql.Request(transaction);

         const result = await request
            .input('name', sql.VarChar, name)
            .input('description', sql.VarChar, description)
            .input('category', sql.VarChar, category)
            .input('measurement', sql.VarChar, measurement)
            .input('maxAmount', sql.Decimal(10, 2), maxAmount)
            .input('reorderAmount', sql.Decimal(10, 2), reorderAmount)
            .input('minAmount', sql.Decimal(10, 2), minAmount)
            .input('vendorID', sql.Int, vendorID)
            .query(`
                INSERT INTO tblIngredients (Name, Description, Category, Measurement, MaxAmount, ReorderAmount, MinAmount, VendorID) 
                VALUES (@name, @description, @category, @measurement, @maxAmount, @reorderAmount, @minAmount, @vendorID);
                SELECT SCOPE_IDENTITY() AS IngredientID
            `);
        await transaction.commit();

       const ingredientID = result.recordset[0].IngredientID;

        res.status(201).json({ message: 'Ingredient added', ingredientID });
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// PUT /ingredients/:id: Update an existing ingredient
app.put('/ingredients/:id', async (req, res) => {
    const ingredientID = req.params.id;
    const { name, description, category, measurement, maxAmount, reorderAmount, minAmount, vendorID } = req.body;

    try {
        // Validate VendorID
        const vendorExists = await checkVendorExists(vendorID);
        if (!vendorExists) {
            return res.status(400).send('Invalid VendorID');
        }

        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('ingredientID', sql.Int, ingredientID)
            .input('name', sql.VarChar, name)
            .input('description', sql.VarChar, description)
            .input('category', sql.VarChar, category)
            .input('measurement', sql.VarChar, measurement)
            .input('maxAmount', sql.Decimal(10, 2), maxAmount)
            .input('reorderAmount', sql.Decimal(10, 2), reorderAmount)
            .input('minAmount', sql.Decimal(10, 2), minAmount)
            .input('vendorID', sql.Int, vendorID)
            .query(`
                UPDATE tblIngredients 
                SET Name = @name, 
                    Description = @description, 
                    Category = @category, 
                    Measurement = @measurement, 
                    MaxAmount = @maxAmount, 
                    ReorderAmount = @reorderAmount, 
                    MinAmount = @minAmount, 
                    VendorID = @vendorID
                WHERE IngredientID = @ingredientID
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Ingredient updated');
        } else {
            res.status(404).send('Ingredient not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// DELETE /ingredients/:name: Remove an ingredient by name
app.delete('/ingredients/:name', async (req, res) => {
    const { name } = req.params;

    if (!name) {
        return res.status(400).send('Ingredient name is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .query(`
                DELETE FROM tblIngredients
                WHERE Name = @name
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Ingredient removed');
        } else {
            res.status(404).send('Ingredient not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// Recipe API Calls

// GET /recipes: Retrieve all recipes
app.get('/recipes', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query(`
            SELECT 
                r.RecipeID, r.Name, r.Steps, r.ProductID,
                ri.IngredientID, i.Name AS IngredientName, ri.Quantity AS IngredientQuantity
            FROM tblRecipes r
            LEFT JOIN tblRecipeIngredients ri ON r.RecipeID = ri.RecipeID
            LEFT JOIN tblIngredients i ON ri.IngredientID = i.IngredientID
        `);

        const recipes = result.recordset.reduce((acc, row) => {
            let recipe = acc.find(r => r.RecipeID === row.RecipeID);
            if (!recipe) {
                recipe = {
                    RecipeID: row.RecipeID,
                    Name: row.Name,
                    Steps: row.Steps,
                    ProductID: row.ProductID,
                    Ingredients: []
                };
                acc.push(recipe);
            }
            if (row.IngredientID) {
                recipe.Ingredients.push({
                    IngredientID: row.IngredientID,
                    Name: row.IngredientName,
                    Quantity: row.IngredientQuantity
                });
            }
            return acc;
        }, []);

        res.json(recipes);
    } catch (error) {
        res.status(500).send('Error retrieving recipes: ' + error.message);
    }
});

app.get('/recipes/:productID', async (req, res) => {
    try {
        const productID = req.params.productID;
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('ProductID', sql.Int, productID)
            .query(`
                SELECT 
                    r.RecipeID, r.Name, r.Steps, r.ProductID,
                    ri.IngredientID, i.Name AS IngredientName, ri.Quantity AS IngredientQuantity
                FROM tblRecipes r
                LEFT JOIN tblRecipeIngredients ri ON r.RecipeID = ri.RecipeID
                LEFT JOIN tblIngredients i ON ri.IngredientID = i.IngredientID
                WHERE r.ProductID = @ProductID
            `);

        const recipes = result.recordset.reduce((acc, row) => {
            let recipe = acc.find(r => r.RecipeID === row.RecipeID);
            if (!recipe) {
                recipe = {
                    RecipeID: row.RecipeID,
                    Name: row.Name,
                    Steps: row.Steps,
                    ProductID: row.ProductID,
                    Ingredients: []
                };
                acc.push(recipe);
            }
            if (row.IngredientID) {
                recipe.Ingredients.push({
                    IngredientID: row.IngredientID,
                    Name: row.IngredientName,
                    Quantity: row.IngredientQuantity
                });
            }
            return acc;
        }, []);

        res.json(recipes);
    } catch (error) {
        res.status(500).send('Error retrieving recipes: ' + error.message);
    }
});




// GET /recipes/search/:name: Search for recipes by partial name
app.get('/recipes/search/:name', async (req, res) => {
    const { name } = req.params;

    if (!name) {
        return res.status(400).send('Search term is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, `%${name}%`)
            .query(`
                SELECT 
                    r.RecipeID, r.Name, r.Steps, r.ProductID,
                    ri.IngredientID, i.Name AS IngredientName, ri.Quantity AS IngredientQuantity
                FROM tblRecipes r
                LEFT JOIN tblRecipeIngredients ri ON r.RecipeID = ri.RecipeID
                LEFT JOIN tblIngredients i ON ri.IngredientID = i.IngredientID
                WHERE r.Name LIKE @name
            `);

        const recipes = result.recordset.reduce((acc, row) => {
            let recipe = acc.find(r => r.RecipeID === row.RecipeID);
            if (!recipe) {
                recipe = {
                    RecipeID: row.RecipeID,
                    Name: row.Name,
                    Steps: row.Steps,
                    ProductID: row.ProductID,
                    Ingredients: []
                };
                acc.push(recipe);
            }
            if (row.IngredientID) {
                recipe.Ingredients.push({
                    IngredientID: row.IngredientID,
                    Name: row.IngredientName,
                    Quantity: row.IngredientQuantity
                });
            }
            return acc;
        }, []);

        if (recipes.length > 0) {
            res.json(recipes);
        } else {
            res.status(404).send('No recipes found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});





// POST /recipes: Create a new recipe
app.post('/recipes', async (req, res) => {
    const { name, steps, product_id, ingredients } = req.body; // Expecting ingredients array [{ IngredientID, Quantity }]

    if (!name || !steps || !product_id || !Array.isArray(ingredients)) {
        return res.status(400).send('Name, steps, product ID, and ingredients are required');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Check if the ProductID exists
        const productCheckResult = await pool.request()
            .input('product_id', sql.Int, product_id)
            .query('SELECT COUNT(*) AS Count FROM tblFinalProducts WHERE ProductID = @product_id');

        if (productCheckResult.recordset[0].Count === 0) {
            return res.status(400).send('Invalid ProductID');
        }

        // Insert the new recipe and get the new RecipeID
        const recipeResult = await pool.request()
            .input('name', sql.VarChar, name)
            .input('steps', sql.Text, steps)
            .input('product_id', sql.Int, product_id)
            .query(`
                INSERT INTO tblRecipes (Name, Steps, ProductID) 
                OUTPUT inserted.RecipeID
                VALUES (@name, @steps, @product_id)
            `);

        const newRecipeID = recipeResult.recordset[0].RecipeID;

        // Insert ingredients into tblRecipeIngredients
        for (const ingredient of ingredients) {
            await pool.request()
                .input('recipe_id', sql.Int, newRecipeID)
                .input('ingredient_id', sql.Int, ingredient.IngredientID)
                .input('quantity', sql.Decimal, ingredient.Quantity)
                .query(`
                    INSERT INTO tblRecipeIngredients (RecipeID, IngredientID, Quantity) 
                    VALUES (@recipe_id, @ingredient_id, @quantity)
                `);
        }

        res.status(201).send('Recipe created with ingredients');
    } catch (error) {
        res.status(500).send('Error creating recipe: ' + error.message);
    }
});





// PUT /recipes/name/:name: Update a recipe by name
app.put('/recipes/name/:name', async (req, res) => {
    const { name } = req.params;
    const { new_name, steps, ingredients } = req.body; // Expecting ingredients array [{ IngredientID, Quantity }]

    if (!new_name && !steps && !Array.isArray(ingredients)) {
        return res.status(400).send('At least one field (new_name, steps, or ingredients) is required for update');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Fetch the RecipeID using the current recipe name
        const recipeResult = await pool.request()
            .input('name', sql.VarChar, name)
            .query('SELECT RecipeID FROM tblRecipes WHERE Name = @name');

        if (recipeResult.recordset.length === 0) {
            return res.status(404).send('Recipe not found');
        }

        const recipeID = recipeResult.recordset[0].RecipeID;

        // Update recipe details
        if (new_name || steps) {
            let updateQuery = 'UPDATE tblRecipes SET ';
            const updateParams = [];

            if (new_name) {
                updateQuery += 'Name = @new_name, ';
                updateParams.push({ name: 'new_name', value: new_name, type: sql.VarChar });
            }
            if (steps) {
                updateQuery += 'Steps = @steps, ';
                updateParams.push({ name: 'steps', value: steps, type: sql.Text });
            }

            // Remove trailing comma and space
            updateQuery = updateQuery.slice(0, -2);
            updateQuery += ' WHERE RecipeID = @recipe_id';

            const request = pool.request();
            request.input('recipe_id', sql.Int, recipeID);
            updateParams.forEach(param => {
                request.input(param.name, param.type, param.value);
            });

            await request.query(updateQuery);
        }

        // Update ingredients
        if (Array.isArray(ingredients)) {
            // Clear current ingredients
            await pool.request()
                .input('recipe_id', sql.Int, recipeID)
                .query('DELETE FROM tblRecipeIngredients WHERE RecipeID = @recipe_id');

            // Insert new ingredients
            for (const ingredient of ingredients) {
                await pool.request()
                    .input('recipe_id', sql.Int, recipeID)
                    .input('ingredient_id', sql.Int, ingredient.IngredientID)
                    .input('quantity', sql.Decimal, ingredient.Quantity)
                    .query(`
                        INSERT INTO tblRecipeIngredients (RecipeID, IngredientID, Quantity) 
                        VALUES (@recipe_id, @ingredient_id, @quantity)
                    `);
            }
        }

        res.send('Recipe updated');
    } catch (error) {
        res.status(500).send('Error updating recipe: ' + error.message);
    }
});




// DELETE /recipes/name/:name: Delete a recipe by name
app.delete('/recipes/name/:name', async (req, res) => {
    const { name } = req.params;

    // Validate input
    if (!name) {
        return res.status(400).send('Recipe name is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .query(`
                DELETE FROM tblRecipes 
                WHERE Name = @name
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Recipe deleted');
        } else {
            res.status(404).send('Recipe not found');
        }
    } catch (error) {
        res.status(500).send('Error deleting recipe: ' + error.message);
    }
});





//Inventory Calls

// GET /inventory: Retrieve all inventory items with ingredient names
app.get('/inventory', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query(`
           SELECT inv.EntryID, inv.Quantity, inv.Notes, inv.Cost, inv.CreateDateTime, inv.ExpireDateTime,
                   ing.Name AS IngredientName, inv.Quantity AS IngredientQuantity, ing.MinAmount,ing.MaxAmount, ing.ReorderAmount, ing.VendorID
            FROM dbo.tblInventory inv
            JOIN dbo.tblIngredients ing ON inv.IngredientID = ing.IngredientID
        `);
        
        res.json(result.recordset);
    } catch (error) {
        console.error('Error retrieving inventory items:', error); // Log any errors
        res.status(500).send('Error retrieving inventory items: ' + error.message);
    }
});


// GET /inventory/name/:name: Retrieve inventory items by partial name match
app.get('/inventory/name/:name', async (req, res) => {
    const { name } = req.params;

    if (!name) {
        return res.status(400).send('Search term is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, `%${name}%`)  // Using LIKE for partial match
            .query(`
                SELECT inv.EntryID, inv.Quantity, inv.Notes, inv.Cost, inv.CreateDateTime, inv.ExpireDateTime,
                   ing.Name AS IngredientName, inv.Quantity AS IngredientQuantity, ing.MinAmount,ing.MaxAmount, ing.ReorderAmount
            FROM dbo.tblInventory inv
            JOIN dbo.tblIngredients ing ON inv.IngredientID = ing.IngredientID
                WHERE ing.Name LIKE @name
            `);

        if (result.recordset.length > 0) {
            res.json(result.recordset);  // Return all matching items
        } else {
            res.status(404).send('No inventory items found');
        }
    } catch (error) {
        res.status(500).send('Error retrieving inventory items: ' + error.message);
    }
});




// POST /inventory: Add a new inventory item
app.post('/inventory', async (req, res) => {
    const { ingredient_id, quantity, notes, cost, create_datetime, expire_datetime, recipe_id } = req.body;

    // Validate input
    if (ingredient_id === undefined || quantity === undefined || cost === undefined || !create_datetime) {
        return res.status(400).send('IngredientID, quantity, cost, and create date/time are required');
    }

    try {
        // Parse the incoming date strings into JavaScript Date objects
        const createDate = new Date(create_datetime);
        const expireDate = expire_datetime ? new Date(expire_datetime) : null;

        if (isNaN(createDate.getTime())) {
            return res.status(400).send('Invalid create date/time format');
        }

        const pool = await sql.connect(dbConfig);

        // Insert the new inventory item
        await pool.request()
            .input('ingredient_id', sql.Int, ingredient_id)
            .input('quantity', sql.Decimal, quantity)
            .input('notes', sql.VarChar, notes)  // Optional field
            .input('cost', sql.Decimal, cost)
            .input('create_datetime', sql.DateTime, createDate)
            .input('expire_datetime', sql.DateTime, expireDate)  // Optional field
            .query(`
                INSERT INTO tblInventory (IngredientID, Quantity, Notes, Cost, CreateDateTime, ExpireDateTime)
                VALUES (@ingredient_id, @quantity, @notes, @cost, @create_datetime, @expire_datetime)
            `);
        res.status(201).send('Item added');
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// PUT /inventory/:item_id: Update an inventory item by ID
app.put('/inventory/:item_id', async (req, res) => {
    const { item_id } = req.params;
    const { ingredient_id, quantity, notes, cost, create_datetime, expire_datetime } = req.body;

    // Validate input
    if (quantity === undefined && cost === undefined && !create_datetime && !expire_datetime  && ingredient_id === undefined) {
        return res.status(400).send('At least one field (ingredient_id, quantity, cost, create_datetime, expire_datetime, or recipe_id) is required for update');
    }

    try {
        const pool = await sql.connect(dbConfig);

    

        // Prepare update query
        let updateQuery = 'UPDATE tblInventory SET ';
        const updateParams = [];

        if (ingredient_id !== undefined) {
            updateQuery += 'IngredientID = @ingredient_id, ';
            updateParams.push({ name: 'ingredient_id', value: ingredient_id, type: sql.Int });
        }
        if (quantity !== undefined) {
            updateQuery += 'Quantity = @quantity, ';
            updateParams.push({ name: 'quantity', value: quantity, type: sql.Decimal });
        }
        if (notes !== undefined) {
            updateQuery += 'Notes = @notes, ';
            updateParams.push({ name: 'notes', value: notes, type: sql.VarChar });
        }
        if (cost !== undefined) {
            updateQuery += 'Cost = @cost, ';
            updateParams.push({ name: 'cost', value: cost, type: sql.Decimal });
        }
        if (create_datetime !== undefined) {
            updateQuery += 'CreateDateTime = @create_datetime, ';
            updateParams.push({ name: 'create_datetime', value: create_datetime, type: sql.DateTime });
        }
        if (expire_datetime !== undefined) {
            updateQuery += 'ExpireDateTime = @expire_datetime, ';
            updateParams.push({ name: 'expire_datetime', value: expire_datetime, type: sql.DateTime });
        }
        

        // Remove trailing comma and space
        updateQuery = updateQuery.slice(0, -2);
        updateQuery += ' WHERE EntryID = @item_id';

        // Execute update query
        const request = pool.request();
        request.input('item_id', sql.Int, item_id);

        updateParams.forEach(param => {
            request.input(param.name, param.type, param.value);
        });

        const result = await request.query(updateQuery);

        if (result.rowsAffected[0] > 0) {
            res.send('Inventory item updated');
        } else {
            res.status(404).send('Inventory item not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// DELETE /inventory/name/:item_name: Remove an item by name
app.delete('/inventory/name/:item_name', async (req, res) => {
    const { item_name } = req.params;

    if (!item_name) {
        return res.status(400).send('Item name is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('item_name', sql.VarChar, item_name)
            .query(`
                DELETE FROM tblInventory
                WHERE EntryID IN (
                    SELECT inv.EntryID
                    FROM dbo.tblInventory inv
                    JOIN dbo.tblIngredients ing ON inv.IngredientID = ing.IngredientID
                    WHERE ing.Name = @item_name
                )
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Item deleted');
        } else {
            res.status(404).send('Item not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// POST /sessions/start: Create a new session for a user
app.post('/sessions/start', async (req, res) => {
    console.log('Received /sessions/start request');
    console.log('Request body:', req.body);
    const { employee_id } = req.body;

    // Validate input
    if (!employee_id) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        console.log('Employee ID:', employee_id);
        const createDateTime = new Date();
        console.log('CreateDateTime:', new Date());
        const result = await pool.request()
            .input('employee_id', sql.UniqueIdentifier, employee_id)
            .input('create_datetime', sql.DateTime, createDateTime)
            .input('last_activity_datetime', sql.DateTime, new Date()) // Add LastActivityDateTime
            .query(`
                INSERT INTO tblSessions (EmployeeID, CreateDateTime, LastActivityDateTime) 
                VALUES (@employee_id, @create_datetime, @last_activity_datetime)
            `);
        console.log('Session created successfully'); // Log successful session creation
        console.log('Result:', result); // Log the result of the query
        res.status(201).json({
            message: 'Session created successfully',
            employee_id: employee_id
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// PUT /sessions/:session_id/update: Update the last activity time for a session
app.put('/sessions/:session_id/update', async (req, res) => {
    const { session_id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('session_id', sql.Int, session_id)
            .input('last_activity_datetime', sql.DateTime, new Date())
            .query(`
                UPDATE tblSessions 
                SET LastActivityDateTime = @last_activity_datetime 
                WHERE SessionID = @session_id
            `);
        
        if (result.rowsAffected[0] > 0) {
            res.send('Session updated');
        } else {
            res.status(404).json({ message: 'Session not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.use('/sessions/validate', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .query(`
                DELETE FROM tblSessions 
                WHERE LastActivityDateTime < DATEADD(MINUTE, -30, GETDATE())
            `);
        
        res.send('Inactive sessions removed');
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});




// GET /sessions: Retrieve all active sessions
app.get('/sessions', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM tblSessions');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /sessions/:employee_id: Retrieve active sessions for a specific employee
app.get('/sessions/:employee_id', async (req, res) => {
    const { employee_id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.UniqueIdentifier, employee_id)
            .query('SELECT * FROM tblSessions WHERE EmployeeID = @employee_id');
        
        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE /sessions/:session_id: End a session
app.delete('/sessions/:session_id', async (req, res) => {
    const { session_id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('session_id', sql.Int, session_id)
            .query('DELETE FROM tblSessions WHERE SessionID = @session_id');
        
        if (result.rowsAffected[0] > 0) {
            res.send('Session ended');
        } else {
            res.status(404).json({ message: 'Session not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});



// Final Product API Calls
// GET /finalproducts: Retrieve all final products
app.get('/finalproducts', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM tblFinalProducts');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send('Error retrieving final products: ' + error.message);
    }
});

// GET /finalproducts/:id: Retrieve a specific final product by ProductID
app.get('/finalproducts/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM tblFinalProducts WHERE ProductID = @id');

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('Final product not found');
        }
    } catch (error) {
        res.status(500).send('Error retrieving final product: ' + error.message);
    }
});

// POST /finalproducts: Create a new final product
app.post('/finalproducts', async (req, res) => {
    const { name, description, maxAmount, remakeAmount, minAmount, quantity, price } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('name', sql.VarChar, name)
            .input('description', sql.Text, description || null)
            .input('maxAmount', sql.Decimal(10,2), maxAmount || null)
            .input('remakeAmount', sql.Decimal(10,2), remakeAmount || null)
            .input('minAmount', sql.Decimal(10,2), minAmount || null)
            .input('quantity', sql.Int, quantity)
            .input('price', sql.Decimal(10, 2), price)
            .query(`
                INSERT INTO tblFinalProducts (Name, Description, MaxAmount, RemakeAmount, MinAmount, Quantity, Price) 
                VALUES (@name, @description, @maxAmount, @remakeAmount, @minAmount, @quantity, @price)
            `);

        res.status(201).send('Final product created');
    } catch (error) {
        console.error('Detailed error:', error);
        res.status(500).send('Error creating final product: ' + error.message);
    }
});

// PUT /finalproducts/:id: Update a specific final product by ProductID
app.put('/finalproducts/:id', async (req, res) => {
    const { id } = req.params;
    console.log(req.body);
    const { Name, Description, MaxAmount, RemakeAmount, MinAmount, Quantity, Price } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('name', sql.VarChar, Name || null)
            .input('description', sql.Text, Description || null)
            .input('maxAmount', sql.Decimal(10, 2), MaxAmount || null)
            .input('remakeAmount', sql.Decimal(10, 2), RemakeAmount || null)
            .input('minAmount', sql.Decimal(10, 2), MinAmount || null)
            .input('quantity', sql.Int, Quantity || null)
            .input('price', sql.Decimal(10, 2), Price || null)
            .query(`
                UPDATE tblFinalProducts 
                SET 
                    Name = ISNULL(@name, Name), 
                    Description = ISNULL(@description, Description), 
                    MaxAmount = ISNULL(@maxAmount, MaxAmount), 
                    RemakeAmount = ISNULL(@remakeAmount, RemakeAmount), 
                    MinAmount = ISNULL(@minAmount, MinAmount), 
                    Quantity = ISNULL(@quantity, Quantity), 
                    Price = ISNULL(@price, Price)
                WHERE ProductID = @id
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Final product updated');
        } else {
            res.status(404).send('Final product not found');
        }
    } catch (error) {
        res.status(500).send('Error updating final product: ' + error.message);
    }
});


// DELETE /finalproducts/:id: Delete a specific final product by ProductID
app.delete('/finalproducts/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM tblFinalProducts WHERE ProductID = @id');

        if (result.rowsAffected[0] > 0) {
            res.send('Final product deleted');
        } else {
            res.status(404).send('Final product not found');
        }
    } catch (error) {
        res.status(500).send('Error deleting final product: ' + error.message);
    }
});

// GET /finalproducts/search/:name: Search for final products by partial name
app.get('/finalproducts/search/:name', async (req, res) => {
    const { name } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, `%${name}%`) // Use % for partial matching
            .query('SELECT * FROM tblFinalProducts WHERE Name LIKE @name');

        if (result.recordset.length > 0) {
            res.json(result.recordset);  // Return all matching final products
        } else {
            res.status(404).send('No final products found');
        }
    } catch (error) {
        res.status(500).send('Error searching final products: ' + error.message);
    }
});

// GET /finalproducts: Retrieve all final products with quantity check
app.get('/finalproducts', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM tblFinalProducts');
        
        // Add a warning if Quantity is below RemakeAmount
        const productsWithWarnings = result.recordset.map(product => {
            if (product.Quantity < product.RemakeAmount) {
                return {
                    ...product,
                    warning: 'Quantity is below the remake amount. Consider restocking.'
                };
            }
            return product;
        });

        res.json(productsWithWarnings);
    } catch (error) {
        res.status(500).send('Error retrieving final products: ' + error.message);
    }
});

// GET /finalproducts/:id: Retrieve a specific final product by ProductID with quantity check
app.get('/finalproducts/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM tblFinalProducts WHERE ProductID = @id');

        if (result.recordset.length > 0) {
            const product = result.recordset[0];

            // Check if Quantity is below RemakeAmount
            if (product.Quantity <= product.RemakeAmount) {
                product.warning = 'Quantity is below the remake amount. Consider restocking.';
            }

            if (product.Quantity <= product.MinAmount) {
                product.warning = 'Quantity is very low. Need to remake IMMEDIATELY';
            }

            res.json(product);
        } else {
            res.status(404).send('Final product not found');
        }
    } catch (error) {
        res.status(500).send('Error retrieving final product: ' + error.message);
    }
});





app.listen(port, () => {
    console.log(`Server is running on port ${port}`); // Log server start message
});
