const express = require('express');
const path = require('path');
const sql = require('mssql');
const bcrypt = require('bcrypt');
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

// Serve static files
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
        const vendors = await pool.request().query('SELECT VendorName FROM tblVendor');
        res.json(vendors.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// POST /vendors: Add a new vendor with email, phone, and address 
app.post('/vendors', async (req, res) => {
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
    const { firstName, lastName, username, password, email, phoneNumber, address } = req.body;

    const newEmployeeID = uuidv4(); // Generate a GUID for the EmployeeID

    try {
        const hashedPassword = await bcrypt.hash(password, 10);

        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
            .input('firstName', sql.VarChar, firstName)
            .input('lastName', sql.VarChar, lastName)
            .input('username', sql.VarChar, username)
            .input('password', sql.VarChar, hashedPassword)
            .query('INSERT INTO tblUsers (EmployeeID, FirstName, LastName, Username, Password) VALUES (@employeeID, @firstName, @lastName, @username, @password)');

        // Add email, phone number, and address to their respective tables
        if (email) {
            await pool.request()
                .input('email', sql.VarChar, email)
                .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
                .query('INSERT INTO tblEmails (EmailAddress, EmployeeID) VALUES (@email, @employeeID)');
        }

        if (phoneNumber) {
            await pool.request()
                .input('phoneNumber', sql.VarChar, phoneNumber)
                .input('employeeID', sql.UniqueIdentifier, newEmployeeID)
                .query('INSERT INTO tblPhoneNumbers (Number, EmployeeID) VALUES (@phoneNumber, @employeeID)');
        }

        if (address) {
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

        res.status(201).send('User added successfully');
    } catch (error) {
        res.status(500).send(error.message);
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

    if (!username || (!firstName && !lastName && !newUsername && !password && !address && !phoneNumbers && !emails)) {
        return res.status(400).send('Username and at least one field to update are required');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Start transaction
        const transaction = new sql.Transaction(pool);
        await transaction.begin();

        const request = new sql.Request(transaction);

        // Update user basic information
        let query = 'UPDATE tblUsers SET ';
        let parameters = [];

        if (firstName) {
            query += 'FirstName = @firstName, ';
            parameters.push({ name: 'firstName', type: sql.VarChar, value: firstName });
        }
        if (lastName) {
            query += 'LastName = @lastName, ';
            parameters.push({ name: 'lastName', type: sql.VarChar, value: lastName });
        }
        if (newUsername) {
            query += 'Username = @newUsername, ';
            parameters.push({ name: 'newUsername', type: sql.VarChar, value: newUsername });
        }
        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            query += 'Password = @password, ';
            parameters.push({ name: 'password', type: sql.VarChar, value: hashedPassword });
        }

        query = query.slice(0, -2);
        query += ' WHERE Username = @username';
        parameters.push({ name: 'username', type: sql.VarChar, value: username });

        parameters.forEach(param => request.input(param.name, param.type, param.value));
        await request.query(query);

        // Update user address
        if (address) {
            for (const addr of address) {
                const addrQuery = `
                    UPDATE tblAddresses 
                    SET StreetAddress = @StreetAddress, City = @City, State = @State, PostalCode = @PostalCode, Country = @Country
                    WHERE AddressID = @AddressID AND EmployeeID = (SELECT EmployeeID FROM tblUsers WHERE Username = @username)`;

                await transaction.request()
                    .input('StreetAddress', sql.VarChar, addr.StreetAddress)
                    .input('City', sql.VarChar, addr.City)
                    .input('State', sql.VarChar, addr.State)
                    .input('PostalCode', sql.VarChar, addr.PostalCode)
                    .input('Country', sql.VarChar, addr.Country)
                    .input('AddressID', sql.Int, addr.AddressID)
                    .input('username', sql.VarChar, username)
                    .query(addrQuery);
            }
        }

        // Update user phone numbers
        if (phoneNumbers) {
            for (const phone of phoneNumbers) {
                const phoneQuery = `
                    UPDATE tblPhoneNumbers 
                    SET AreaCode = @AreaCode, Number = @Number
                    WHERE PhoneNumberID = @PhoneNumberID AND EmployeeID = (SELECT EmployeeID FROM tblUsers WHERE Username = @username)`;

                await transaction.request()
                    .input('AreaCode', sql.VarChar, phone.AreaCode)
                    .input('Number', sql.VarChar, phone.Number)
                    .input('PhoneNumberID', sql.Int, phone.PhoneNumberID)
                    .input('username', sql.VarChar, username)
                    .query(phoneQuery);
            }
        }

        // Update user emails
        if (emails) {
            for (const email of emails) {
                const emailQuery = `
                    UPDATE tblEmails 
                    SET EmailAddress = @EmailAddress
                    WHERE EmailID = @EmailID AND EmployeeID = (SELECT EmployeeID FROM tblUsers WHERE Username = @username)`;

                await transaction.request()
                    .input('EmailAddress', sql.VarChar, email.EmailAddress)
                    .input('EmailID', sql.Int, email.EmailID)
                    .input('username', sql.VarChar, username)
                    .query(emailQuery);
            }
        }

        // Commit transaction
        await transaction.commit();
        res.send('User updated successfully');
    } catch (error) {
        // Rollback transaction in case of error
        await transaction.rollback();
        res.status(500).send(error.message);
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
app.post('/login', async (req, res) => {
    console.log('Request Body:', req.body);
    const { username, password } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        if (pool.connected) {
            console.log('Connected to Azure SQL Server');
        }

        const request = new sql.Request();
        // Adjust the query to select the password_hash column
        const result = await request
            .input('username', sql.VarChar, username)
            .query('SELECT password FROM tblUsers WHERE username = @username'); // Adjusted query

        console.log('testing');
        if (result.recordset.length > 0) {
            const dbPassword = result.recordset[0].password; // Correctly access password_hash
            console.log(`Password from DB: ${dbPassword}`); // Log password from DB for verification

            // Direct comparison of plain-text passwords (for testing purposes)
            if (password === dbPassword) {
                res.send('Authentication successful');
            } else {
                res.status(401).send('Invalid credentials');
            }
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(200).send(error);
    }
});




/* // POST /login: Authenticate user with hashed passwords
app.post('/login', async (req, res) => {
    console.log('Request Body:', req.body);
    const { username, password } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        if (pool.connected) {
            console.log('Connected to Azure SQL Server');
        }

        const request = new sql.Request();
        // Adjust the query to select the password_hash column
        const result = await request
            .input('username', sql.VarChar, username)
            .query('SELECT PasswordHash FROM tblUsers WHERE Username = @username'); // Adjusted query

        console.log('Testing');
        if (result.recordset.length > 0) {
            const dbPasswordHash = result.recordset[0].PasswordHash; // Correctly access PasswordHash

            console.log(`Password hash from DB: ${dbPasswordHash}`); // Log password hash for verification

            // Compare provided password with hashed password from the database
            const match = await bcrypt.compare(password, dbPasswordHash);

            if (match) {
                res.send('Authentication successful');
            } else {
                res.status(401).send('Invalid credentials');
            }
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(200).send(error.message);
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
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM tblIngredients'); // Correct table name
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
    const { name, description, category, measurement, maxAmount, reorderAmount, minAmount, vendorID } = req.body;

    try {
        // Validate VendorID
        const vendorExists = await checkVendorExists(vendorID);
        if (!vendorExists) {
            return res.status(400).send('Invalid VendorID');
        }

        const pool = await sql.connect(dbConfig);
        await pool.request()
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
                VALUES (@name, @description, @category, @measurement, @maxAmount, @reorderAmount, @minAmount, @vendorID)
            `);
        res.status(201).send('Ingredient added');
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
        const result = await pool.request().query('SELECT * FROM tblRecipes');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
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
            .input('name', sql.VarChar, `%${name}%`) // Use % for partial match
            .query('SELECT * FROM tblRecipes WHERE Name LIKE @name');

        if (result.recordset.length > 0) {
            res.json(result.recordset);  // Return all matching recipes
        } else {
            res.status(404).send('No recipes found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// POST /recipes: Create a new recipe
app.post('/recipes', async (req, res) => {
    const { name, steps, product_id } = req.body;

    // Validate required fields
    if (!name || !steps || !product_id) {
        return res.status(400).send('Name, steps, and product ID are required');
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

        // Insert the new recipe
        await pool.request()
            .input('name', sql.VarChar, name)
            .input('steps', sql.Text, steps)
            .input('product_id', sql.Int, product_id)
            .query(`
                INSERT INTO tblRecipes (Name, Steps, ProductID) 
                VALUES (@name, @steps, @product_id)
            `);

        res.status(201).send('Recipe created');
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// PUT /recipes/name/:name: Update a recipe by name
app.put('/recipes/name/:name', async (req, res) => {
    const { name } = req.params;
    const { new_name, steps } = req.body;

    // Validate input
    if (!new_name && !steps) {
        return res.status(400).send('At least one field (new_name or steps) is required for update');
    }
    if (new_name && (typeof new_name !== 'string' || new_name.trim().length === 0)) {
        return res.status(400).send('Valid new_name is required');
    }
    if (steps && (typeof steps !== 'string' || steps.trim().length === 0)) {
        return res.status(400).send('Valid steps are required');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Prepare update query
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
        updateQuery += ' WHERE Name = @name';

        // Execute update query
        const request = pool.request();
        request.input('name', sql.VarChar, name);

        updateParams.forEach(param => {
            request.input(param.name, param.type, param.value);
        });

        const result = await request.query(updateQuery);

        if (result.rowsAffected[0] > 0) {
            res.send('Recipe updated');
        } else {
            res.status(404).send('Recipe not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
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

// GET /inventory: Retrieve all inventory items
app.get('/inventory', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM dbo.tblInventory');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send('Error retrieving inventory: ' + error.message);
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
            .query('SELECT * FROM tblInventory WHERE Name LIKE @name');

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
    const { quantity, notes, cost, create_datetime, expire_datetime, recipe_id } = req.body;

    // Validate input
    if (quantity === undefined || cost === undefined || !create_datetime) {
        return res.status(400).send('Quantity, cost, and create date/time are required');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Check if the RecipeID is valid (if provided)
        if (recipe_id) {
            const recipeCheck = await pool.request()
                .input('recipe_id', sql.Int, recipe_id)
                .query('SELECT COUNT(*) AS count FROM tblRecipes WHERE RecipeID = @recipe_id');
            
            if (recipeCheck.recordset[0].count === 0) {
                return res.status(400).send('Invalid RecipeID');
            }
        }

        // Insert the new inventory item
        await pool.request()
            .input('quantity', sql.Decimal, quantity)
            .input('notes', sql.VarChar, notes)  // Optional field
            .input('cost', sql.Decimal, cost)
            .input('create_datetime', sql.DateTime, create_datetime)
            .input('expire_datetime', sql.DateTime, expire_datetime)  // Optional field
            .input('recipe_id', sql.Int, recipe_id)  // Optional field
            .query(`
                INSERT INTO tblInventory (Quantity, Notes, Cost, CreateDateTime, ExpireDateTime, RecipeID)
                VALUES (@quantity, @notes, @cost, @create_datetime, @expire_datetime, @recipe_id)
            `);
        res.status(201).send('Item added');
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// PUT /inventory/:item_id: Update an inventory item by ID
app.put('/inventory/:item_id', async (req, res) => {
    const { item_id } = req.params;
    const { quantity, notes, cost, create_datetime, expire_datetime, recipe_id } = req.body;

    // Validate input
    if (quantity === undefined && cost === undefined && !create_datetime && !expire_datetime && recipe_id === undefined) {
        return res.status(400).send('At least one field (quantity, cost, create_datetime, expire_datetime, or recipe_id) is required for update');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Check if the RecipeID is valid (if provided)
        if (recipe_id) {
            const recipeCheck = await pool.request()
                .input('recipe_id', sql.Int, recipe_id)
                .query('SELECT COUNT(*) AS count FROM tblRecipes WHERE RecipeID = @recipe_id');
            
            if (recipeCheck.recordset[0].count === 0) {
                return res.status(400).send('Invalid RecipeID');
            }
        }

        // Prepare update query
        let updateQuery = 'UPDATE tblInventory SET ';
        const updateParams = [];

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
        if (recipe_id !== undefined) {
            updateQuery += 'RecipeID = @recipe_id, ';
            updateParams.push({ name: 'recipe_id', value: recipe_id, type: sql.Int });
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
            .query('DELETE FROM tblInventory WHERE Name = @item_name');

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
    const { employee_id } = req.body;

    // Validate input
    if (!employee_id) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.UniqueIdentifier, employee_id)
            .input('create_datetime', sql.DateTime, new Date())
            .query(`
                INSERT INTO tblSessions (EmployeeID, CreateDateTime) 
                VALUES (@employee_id, @create_datetime)
            `);
        
        res.status(201).json({ session_id: result.recordset.insertId, employee_id });
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



app.listen(port, () => {
    console.log(`Server is running on port ${port}`); // Log server start message
});
